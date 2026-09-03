-- ============================================================================
-- Storage RLS reset — v2
--
-- RCA:
--   * Dashboard upload works (service_role bypasses RLS) → schema is fine.
--   * Flutter upload fails with "database schema is invalid or incompatible"
--     → the error is being thrown during RLS policy evaluation, not from
--     an actual schema mismatch.
--
-- Hypothesis: one of my earlier policies referenced other public tables
--   (events, channel_members, profiles) which under RLS may fail to
--   resolve schema during storage-api evaluation. Rewriting all storage
--   policies to be SELF-CONTAINED (only bucket_id + auth.uid() + path
--   parsing) — no cross-table references.
--
-- We enforce cross-table concerns (attendee-only read of event chat
-- attachments, host-only cover uploads) at the API layer in Dart
-- instead. Storage RLS becomes purely about "who owns the folder".
-- ============================================================================

-- Drop every custom policy we've added so far.
drop policy if exists "public buckets read"            on storage.objects;
drop policy if exists "verifications owner read"       on storage.objects;
drop policy if exists "message attachments channel read" on storage.objects;
drop policy if exists "avatars owner insert"           on storage.objects;
drop policy if exists "avatars owner update"           on storage.objects;
drop policy if exists "avatars owner delete"           on storage.objects;
drop policy if exists "event covers host insert"       on storage.objects;
drop policy if exists "event covers host manage"       on storage.objects;
drop policy if exists "verifications owner insert"     on storage.objects;
drop policy if exists "message attachments sender insert" on storage.objects;
drop policy if exists "storage admin all"              on storage.objects;

-- ---------------------------------------------------------------------------
-- READ
-- ---------------------------------------------------------------------------

-- Anyone (even unauthenticated) can read from public buckets. Necessary
-- so avatars + event covers can render in the app UI without a signed URL.
create policy "public bucket read"
  on storage.objects for select
  using (bucket_id in ('avatars', 'event_covers', 'event_gallery'));

-- Private buckets: you can read files you own (path starts with your uid).
create policy "private owner read"
  on storage.objects for select
  to authenticated
  using (
    bucket_id in ('verifications', 'message_attachments')
    and auth.uid()::text = (storage.foldername(name))[1]
  );

-- ---------------------------------------------------------------------------
-- WRITE
-- ---------------------------------------------------------------------------

-- Any authenticated user can write to their own folder in any bucket.
-- The folder MUST start with their auth.uid() as the first segment.
create policy "owner folder insert"
  on storage.objects for insert
  to authenticated
  with check (
    bucket_id in ('avatars','event_covers','event_gallery','verifications','message_attachments')
    and auth.uid()::text = (storage.foldername(name))[1]
  );

create policy "owner folder update"
  on storage.objects for update
  to authenticated
  using (
    bucket_id in ('avatars','event_covers','event_gallery','verifications','message_attachments')
    and auth.uid()::text = (storage.foldername(name))[1]
  );

create policy "owner folder delete"
  on storage.objects for delete
  to authenticated
  using (
    bucket_id in ('avatars','event_covers','event_gallery','verifications','message_attachments')
    and auth.uid()::text = (storage.foldername(name))[1]
  );

-- Sanity check
select policyname, cmd from pg_policies
where schemaname = 'storage' order by policyname;
