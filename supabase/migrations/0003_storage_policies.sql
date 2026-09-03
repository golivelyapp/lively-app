-- ============================================================================
-- Re-apply storage.objects policies that got dropped when buckets were
-- recreated via the Studio UI. Idempotent — drop-if-exists + create.
-- ============================================================================

-- ---------------------------------------------------------------------------
-- READ policies
-- ---------------------------------------------------------------------------
drop policy if exists "public buckets read" on storage.objects;
create policy "public buckets read"
  on storage.objects for select
  using (bucket_id in ('avatars', 'event_covers', 'event_gallery'));

drop policy if exists "verifications owner read" on storage.objects;
create policy "verifications owner read"
  on storage.objects for select
  using (
    bucket_id = 'verifications'
    and (
      auth.uid()::text = (storage.foldername(name))[1]
      or exists (select 1 from profiles where id = auth.uid() and is_admin)
    )
  );

drop policy if exists "message attachments channel read" on storage.objects;
create policy "message attachments channel read"
  on storage.objects for select
  using (
    bucket_id = 'message_attachments'
    and (storage.foldername(name))[1]::uuid in (
      select channel_id from channel_members
      where profile_id = auth.uid() and left_at is null
    )
  );

-- ---------------------------------------------------------------------------
-- WRITE policies
-- ---------------------------------------------------------------------------
drop policy if exists "avatars owner insert" on storage.objects;
create policy "avatars owner insert"
  on storage.objects for insert
  with check (
    bucket_id = 'avatars'
    and auth.uid()::text = (storage.foldername(name))[1]
  );

drop policy if exists "avatars owner update" on storage.objects;
create policy "avatars owner update"
  on storage.objects for update
  using (
    bucket_id = 'avatars'
    and auth.uid()::text = (storage.foldername(name))[1]
  );

drop policy if exists "avatars owner delete" on storage.objects;
create policy "avatars owner delete"
  on storage.objects for delete
  using (
    bucket_id = 'avatars'
    and auth.uid()::text = (storage.foldername(name))[1]
  );

drop policy if exists "event covers host insert" on storage.objects;
create policy "event covers host insert"
  on storage.objects for insert
  with check (
    bucket_id in ('event_covers', 'event_gallery')
    and (storage.foldername(name))[1]::uuid in (
      select id from events where host_id = auth.uid()
    )
  );

drop policy if exists "event covers host manage" on storage.objects;
create policy "event covers host manage"
  on storage.objects for all
  using (
    bucket_id in ('event_covers', 'event_gallery')
    and (storage.foldername(name))[1]::uuid in (
      select id from events where host_id = auth.uid()
    )
  );

drop policy if exists "verifications owner insert" on storage.objects;
create policy "verifications owner insert"
  on storage.objects for insert
  with check (
    bucket_id = 'verifications'
    and auth.uid()::text = (storage.foldername(name))[1]
  );

drop policy if exists "message attachments sender insert" on storage.objects;
create policy "message attachments sender insert"
  on storage.objects for insert
  with check (
    bucket_id = 'message_attachments'
    and (storage.foldername(name))[1]::uuid in (
      select channel_id from channel_members
      where profile_id = auth.uid() and left_at is null
    )
  );

-- Sanity check — list current policies afterwards.
select policyname, cmd
from pg_policies
where schemaname = 'storage'
order by policyname;
