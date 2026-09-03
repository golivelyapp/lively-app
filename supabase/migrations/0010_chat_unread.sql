-- ============================================================================
-- Per-user unread counts for event chats.
--
-- Uses `channel_members.last_read_at` (already in the schema from 0001)
-- as the "up to here" marker per user per channel. Messages by the
-- caller themselves are excluded from their own unread count.
--
-- One RPC returns a row per event the caller is a member of, so the
-- client fetches every count in a single round-trip.
-- ============================================================================

create or replace function my_unread_counts()
returns table(event_id uuid, unread_count integer)
language sql stable security definer set search_path = public as $$
  select
    c.event_id,
    (
      select count(*)::integer
      from messages m
      where m.channel_id = c.id
        and m.deleted_at is null
        and m.created_at > cm.last_read_at
        and (m.sender_id is null or m.sender_id <> auth.uid())
    ) as unread_count
  from channel_members cm
  join channels c on c.id = cm.channel_id
  where cm.profile_id = auth.uid()
    and cm.left_at is null
    and c.type = 'event_chat'
    and c.event_id is not null;
$$;

notify pgrst, 'reload schema';
