-- ============================================================================
-- Persist the profile's avatar URL directly on the profiles row.
--
-- Before this migration: the avatar was uploaded to Storage + tracked in
-- `attachments`, but the resulting public URL was never written back to
-- `profiles`. Every display site fell back to placeholders after the
-- local draft state was wiped (app kill).
--
-- Trigger: when a user creates an event we mirror name/photo/bio into
-- the denormalised `host_display_*` columns so the Home feed's event
-- card can show the host without a per-row join.
-- ============================================================================

alter table profiles
  add column if not exists avatar_url text;

-- ---------------------------------------------------------------------------
-- Trigger: populate events.host_display_* from profiles on insert.
-- COALESCE preserves any explicit values the client happened to send.
-- ---------------------------------------------------------------------------
create or replace function tg_events_populate_host_display() returns trigger
language plpgsql security definer set search_path = public as $$
declare
  p profiles%rowtype;
begin
  if new.host_id is null then
    return new;
  end if;
  select * into p from profiles where id = new.host_id;
  if p.id is null then
    return new;
  end if;
  new.host_display_name       := coalesce(new.host_display_name, p.name);
  new.host_display_photo_url  := coalesce(new.host_display_photo_url, p.avatar_url);
  new.host_display_bio        := coalesce(new.host_display_bio, p.bio);
  return new;
end;
$$;

drop trigger if exists on_events_populate_host on events;
create trigger on_events_populate_host
  before insert on events
  for each row execute function tg_events_populate_host_display();

-- ---------------------------------------------------------------------------
-- Backfill: user-created events that predate this trigger get the same
-- treatment. Seed events (host_id null) are left alone.
-- ---------------------------------------------------------------------------
update events e
set
  host_display_name       = coalesce(e.host_display_name, p.name),
  host_display_photo_url  = coalesce(e.host_display_photo_url, p.avatar_url),
  host_display_bio        = coalesce(e.host_display_bio, p.bio)
from profiles p
where e.host_id = p.id
  and (
    e.host_display_name is null
    or e.host_display_photo_url is null
    or e.host_display_bio is null
  );

notify pgrst, 'reload schema';
