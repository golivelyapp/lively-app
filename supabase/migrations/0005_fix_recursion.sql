-- ============================================================================
-- Fix RLS infinite recursion + simplify attachments policies.
--
-- Root cause:
--   * `channel_members` had a policy that SELECT'd from `channel_members`,
--     triggering RLS re-evaluation → infinite recursion.
--   * `attachments` SELECT policy referenced `messages` → `channel_members`,
--     which triggered the recursion whenever we inserted an attachment
--     row (PostgREST's default return=representation reads the inserted
--     row back, triggering SELECT policies).
--
-- Fix pattern: wrap RLS lookups in SECURITY DEFINER functions so the
-- inner query bypasses RLS and can never re-enter the same policy.
-- ============================================================================

-- ---------------------------------------------------------------------------
-- Helper functions
-- ---------------------------------------------------------------------------

create or replace function is_channel_member(cid uuid) returns boolean
language sql stable security definer set search_path = public
as $$
  select exists (
    select 1 from channel_members
    where channel_id = cid
      and profile_id = auth.uid()
      and left_at is null
  );
$$;

create or replace function is_channel_member_active(cid uuid) returns boolean
language sql stable security definer set search_path = public
as $$
  select exists (
    select 1 from channel_members
    where channel_id = cid
      and profile_id = auth.uid()
      and left_at is null
  );
$$;

-- ---------------------------------------------------------------------------
-- channel_members — remove the self-referential policy, keep only the
-- "your own row" policy. Peer visibility now goes through
-- is_channel_member() which is SECURITY DEFINER so it bypasses RLS.
-- ---------------------------------------------------------------------------
drop policy if exists "cm peers read"  on channel_members;
drop policy if exists "cm self all"    on channel_members;

create policy "cm self all" on channel_members
  for all using (profile_id = auth.uid());

create policy "cm peers read" on channel_members
  for select using (is_channel_member(channel_id));

-- ---------------------------------------------------------------------------
-- messages — replace the inline subquery with the helper function.
-- ---------------------------------------------------------------------------
drop policy if exists "messages channel read"  on messages;
drop policy if exists "messages send"          on messages;
drop policy if exists "messages own edit"      on messages;
drop policy if exists "messages own delete"    on messages;

create policy "messages channel read" on messages
  for select using (is_channel_member(channel_id));

create policy "messages send" on messages
  for insert with check (
    sender_id = auth.uid() and is_channel_member(channel_id)
  );

create policy "messages own edit"   on messages for update using (sender_id = auth.uid());
create policy "messages own delete" on messages for delete using (sender_id = auth.uid());

-- ---------------------------------------------------------------------------
-- message_reactions — same treatment.
-- ---------------------------------------------------------------------------
drop policy if exists "reactions channel read" on message_reactions;
drop policy if exists "reactions self all"     on message_reactions;

create policy "reactions self all" on message_reactions
  for all using (profile_id = auth.uid());

create policy "reactions channel read" on message_reactions
  for select using (
    message_id in (
      select id from messages
      where is_channel_member(channel_id)
    )
  );

-- ---------------------------------------------------------------------------
-- attachments — simplify to owner-only. Cross-table concerns (event
-- galleries, message attachments) are enforced at the storage bucket
-- level, not here. This table is metadata; not readable by peers.
-- ---------------------------------------------------------------------------
drop policy if exists "attachments public read"  on attachments;
drop policy if exists "attachments admin all"    on attachments;
drop policy if exists "attachments owner read"   on attachments;
drop policy if exists "attachments owner write"  on attachments;

create policy "attachments owner all" on attachments
  for all using (
    (owner_type = 'profile'          and owner_id = auth.uid())
    or (owner_type = 'host_application' and owner_id in (
          select id from host_applications where profile_id = auth.uid()))
    or (owner_type = 'message'       and owner_id in (
          select id from messages where sender_id = auth.uid()))
    or (owner_type = 'event'         and owner_id in (
          select id from events where host_id = auth.uid()))
  );

create policy "attachments admin all" on attachments
  for all using (is_admin());

-- Sanity check
select tablename, policyname, cmd
from pg_policies
where schemaname = 'public' and tablename in (
  'channel_members','messages','message_reactions','attachments'
)
order by tablename, policyname;
