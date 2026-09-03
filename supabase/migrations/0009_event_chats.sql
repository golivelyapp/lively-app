-- ============================================================================
-- Persist event group chats through Supabase.
--
-- 1) Every event has exactly one `channels` row of type 'event_chat'.
-- 2) The host + every active RSVPer is a row in `channel_members`.
-- 3) Cancelling an RSVP sets `channel_members.left_at`, revoking read
--    access via the existing RLS (messages channel read).
-- 4) `messages` is added to the supabase_realtime publication so the
--    client can subscribe to INSERTs without polling.
--
-- All triggers are SECURITY DEFINER so they can insert into channels /
-- channel_members bypassing the caller's RLS. Backfills are idempotent.
-- ============================================================================

-- ---------------------------------------------------------------------------
-- Trigger: on events insert, create the event's chat channel + add the host.
-- ---------------------------------------------------------------------------
create or replace function tg_events_ensure_chat_channel() returns trigger
language plpgsql security definer set search_path = public as $$
declare
  cid uuid;
begin
  insert into channels (type, event_id)
  values ('event_chat', new.id)
  on conflict (event_id, type) do nothing;

  select id into cid from channels
    where event_id = new.id and type = 'event_chat';

  if new.host_id is not null and cid is not null then
    insert into channel_members (channel_id, profile_id)
    values (cid, new.host_id)
    on conflict (channel_id, profile_id) do update
      set left_at = null;
  end if;

  return new;
end;
$$;

drop trigger if exists on_event_insert_ensure_chat on events;
create trigger on_event_insert_ensure_chat
  after insert on events
  for each row execute function tg_events_ensure_chat_channel();

-- ---------------------------------------------------------------------------
-- Trigger: on rsvps insert/update, keep channel_members in sync.
--   * active RSVP  → ensure member row (un-mark left_at if returning)
--   * cancelled    → set left_at on the member row
-- ---------------------------------------------------------------------------
create or replace function tg_rsvps_sync_channel_member() returns trigger
language plpgsql security definer set search_path = public as $$
declare
  cid uuid;
begin
  select id into cid from channels
    where event_id = new.event_id and type = 'event_chat';
  if cid is null then
    insert into channels (type, event_id) values ('event_chat', new.event_id)
    on conflict (event_id, type) do nothing;
    select id into cid from channels
      where event_id = new.event_id and type = 'event_chat';
  end if;

  if new.cancelled_at is null then
    insert into channel_members (channel_id, profile_id)
    values (cid, new.profile_id)
    on conflict (channel_id, profile_id) do update
      set left_at = null;
  else
    update channel_members
      set left_at = now()
      where channel_id = cid
        and profile_id = new.profile_id
        and left_at is null;
  end if;

  return new;
end;
$$;

drop trigger if exists on_rsvp_ins_sync_member on rsvps;
drop trigger if exists on_rsvp_upd_sync_member on rsvps;
create trigger on_rsvp_ins_sync_member after insert on rsvps
  for each row execute function tg_rsvps_sync_channel_member();
create trigger on_rsvp_upd_sync_member after update on rsvps
  for each row execute function tg_rsvps_sync_channel_member();

-- ---------------------------------------------------------------------------
-- Backfill 1: create channels for existing events that don't have one.
-- ---------------------------------------------------------------------------
insert into channels (type, event_id)
select 'event_chat', e.id
  from events e
  left join channels c
    on c.event_id = e.id and c.type = 'event_chat'
  where c.id is null;

-- ---------------------------------------------------------------------------
-- Backfill 2: hosts + active RSVPers become channel_members.
-- ---------------------------------------------------------------------------
insert into channel_members (channel_id, profile_id)
select c.id, e.host_id
  from events e
  join channels c on c.event_id = e.id and c.type = 'event_chat'
  where e.host_id is not null
on conflict (channel_id, profile_id) do nothing;

insert into channel_members (channel_id, profile_id)
select c.id, r.profile_id
  from rsvps r
  join channels c on c.event_id = r.event_id and c.type = 'event_chat'
  where r.cancelled_at is null
on conflict (channel_id, profile_id) do nothing;

-- ---------------------------------------------------------------------------
-- Enable realtime on messages (idempotent).
-- ---------------------------------------------------------------------------
do $$
begin
  begin
    alter publication supabase_realtime add table messages;
  exception
    when duplicate_object then null;
    when others then null;
  end;
end $$;

-- Force PostgREST to re-scan.
notify pgrst, 'reload schema';
