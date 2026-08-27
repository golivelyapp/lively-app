-- ============================================================================
-- Storage buckets + access policies.
--
-- Public buckets = anyone can read (avatars + event covers/gallery are shown
-- to other members). Private buckets = only the owner + admins can read
-- (ID scans, live selfies, message attachments).
-- ============================================================================

-- Create buckets (idempotent).
insert into storage.buckets (id, name, public) values
  ('avatars',             'avatars',             true),
  ('event_covers',        'event_covers',        true),
  ('event_gallery',       'event_gallery',       true),
  ('verifications',       'verifications',       false),
  ('message_attachments', 'message_attachments', false)
on conflict (id) do nothing;

-- ---------------------------------------------------------------------------
-- READ policies
-- ---------------------------------------------------------------------------

-- Public buckets: anyone can read.
create policy "public buckets read"
  on storage.objects for select
  using (bucket_id in ('avatars', 'event_covers', 'event_gallery'));

-- Verifications: only the owner (path prefix = auth.uid()::text) + admins.
-- Convention: upload path is `<user_uuid>/<filename>` for verifications.
create policy "verifications owner read"
  on storage.objects for select
  using (
    bucket_id = 'verifications'
    and (
      auth.uid()::text = (storage.foldername(name))[1]
      or exists (select 1 from profiles where id = auth.uid() and is_admin)
    )
  );

-- Message attachments: only channel members of the message can read.
-- Convention: path is `<channel_uuid>/<message_uuid>/<filename>`.
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

-- Avatars: authenticated users can upload their own (path = <uid>/*).
create policy "avatars owner insert"
  on storage.objects for insert
  with check (
    bucket_id = 'avatars'
    and auth.uid()::text = (storage.foldername(name))[1]
  );
create policy "avatars owner update"
  on storage.objects for update
  using (
    bucket_id = 'avatars'
    and auth.uid()::text = (storage.foldername(name))[1]
  );
create policy "avatars owner delete"
  on storage.objects for delete
  using (
    bucket_id = 'avatars'
    and auth.uid()::text = (storage.foldername(name))[1]
  );

-- Event covers/gallery: hosts write to their event's folder (path = <event_id>/*).
create policy "event covers host insert"
  on storage.objects for insert
  with check (
    bucket_id in ('event_covers', 'event_gallery')
    and (storage.foldername(name))[1]::uuid in (
      select id from events where host_id = auth.uid()
    )
  );
create policy "event covers host manage"
  on storage.objects for all
  using (
    bucket_id in ('event_covers', 'event_gallery')
    and (storage.foldername(name))[1]::uuid in (
      select id from events where host_id = auth.uid()
    )
  );

-- Verifications: users upload to their own folder.
create policy "verifications owner insert"
  on storage.objects for insert
  with check (
    bucket_id = 'verifications'
    and auth.uid()::text = (storage.foldername(name))[1]
  );

-- Message attachments: senders upload to a channel folder they're in.
create policy "message attachments sender insert"
  on storage.objects for insert
  with check (
    bucket_id = 'message_attachments'
    and (storage.foldername(name))[1]::uuid in (
      select channel_id from channel_members
      where profile_id = auth.uid() and left_at is null
    )
  );

-- Admins have full control for cleanup/moderation.
create policy "storage admin all"
  on storage.objects for all
  using (exists (select 1 from profiles where id = auth.uid() and is_admin));
