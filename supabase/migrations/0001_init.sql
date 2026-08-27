-- ============================================================================
-- LIVELY — INITIAL SCHEMA (v0.2)
-- ============================================================================
--
-- Design principles applied throughout:
--   * Every soft-deletable table carries created_at / updated_at / deleted_at
--   * Lookup tables instead of enums for anything that might grow
--   * Unified channels + messages model for every conversation type
--   * Unified attachments table for every uploaded file
--   * Multi-city ready from day one (cities + localities as real tables)
--   * metadata jsonb escape hatch on profiles / events / notifications
--   * RLS policies are the security boundary — one named policy per intent
--
-- ============================================================================

create extension if not exists "uuid-ossp";
create extension if not exists "pgcrypto";

-- ============================================================================
-- CLOSED ENUMS (won't grow — kept as postgres enums for compactness)
-- ============================================================================

create type gender as enum ('male', 'female', 'other');

create type review_status as enum (
  'draft',           -- filling out onboarding
  'submitted',       -- selfie submitted, awaiting admin
  'under_review',    -- admin has picked it up
  'approved',
  'rejected'
);

create type host_status as enum (
  'none',
  'applied',
  'under_review',
  'approved',
  'rejected',
  'suspended'
);

create type channel_type as enum (
  'event_chat',       -- group chat for one event
  'direct_message',   -- 1:1 opened after mutual wave
  'host_broadcast',   -- future: hosts messaging past attendees
  'group'             -- future: standing interest-based groups
);

create type report_status as enum ('open', 'actioned', 'dismissed');

create type report_target_type as enum ('profile', 'event', 'message');

create type attachment_owner_type as enum (
  'profile',
  'event',
  'message',
  'host_application'
);

-- ============================================================================
-- LAYER 1 — GEOGRAPHY
-- ============================================================================

create table cities (
  id uuid primary key default uuid_generate_v4(),
  code text not null unique,             -- 'bengaluru'
  name text not null,                    -- 'Bengaluru'
  country_code text not null default 'IN',
  timezone text not null default 'Asia/Kolkata',
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table localities (
  id uuid primary key default uuid_generate_v4(),
  city_id uuid not null references cities(id) on delete cascade,
  name text not null,                    -- 'Koramangala'
  slug text not null,                    -- 'koramangala'
  display_order int not null default 100,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (city_id, slug)
);
create index localities_city_active_order_idx on localities(city_id, is_active, display_order);

-- ============================================================================
-- LAYER 2 — TAXONOMY (lookup tables)
-- ============================================================================

create table activity_categories (
  id uuid primary key default uuid_generate_v4(),
  code text not null unique,             -- 'board_games'
  label text not null,                   -- 'Board Games'
  icon_name text not null,               -- Material icon name string
  display_order int not null default 100,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table event_gender_policies (
  code text primary key,                 -- 'everyone' | 'women_only' | 'men_only'
  label text not null,
  display_order int not null default 100
);

create table report_kinds (
  code text primary key,                 -- 'harassment' | 'spam' | ...
  label text not null,
  display_order int not null default 100
);

create table notification_types (
  code text primary key,                 -- 'rsvp_reminder' | ...
  label text not null,
  default_title_template text,
  default_body_template text,
  push_enabled_by_default boolean not null default true,
  email_enabled_by_default boolean not null default false
);

-- ============================================================================
-- LAYER 3 — IDENTITY
-- ============================================================================

create table profiles (
  id uuid primary key references auth.users(id) on delete cascade,

  -- required onboarding
  name text,
  date_of_birth date,
  gender gender,
  city_id uuid references cities(id) on delete set null,
  locality_id uuid references localities(id) on delete set null,
  bio text,
  activities uuid[] default '{}'::uuid[],    -- FK-by-array to activity_categories.id
  -- Photos are in attachments table; the "primary" avatar + selfie are
  -- surfaced via a view for convenience.

  -- optional profile enhancements
  height_cm int check (height_cm is null or height_cm between 100 and 250),
  traits text[] default '{}'::text[],
  company text,
  profession text,
  relationship_status text,
  musicians jsonb default '[]'::jsonb,
  movies jsonb default '[]'::jsonb,
  dishes jsonb default '[]'::jsonb,
  socials jsonb default '[]'::jsonb,

  -- meta / lifecycle
  review_status review_status not null default 'draft',
  host_status host_status not null default 'none',
  is_admin boolean not null default false,
  privacy_blurred boolean not null default false,
  metadata jsonb not null default '{}'::jsonb,

  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz,
  approved_at timestamptz,
  rejected_at timestamptz,
  rejection_reason text
);
create index profiles_review_status_idx on profiles(review_status) where deleted_at is null;
create index profiles_city_locality_idx on profiles(city_id, locality_id) where deleted_at is null;
create index profiles_host_status_idx on profiles(host_status) where deleted_at is null;

-- ============================================================================
-- LAYER 4 — EVENTS
-- ============================================================================

create table events (
  id uuid primary key default uuid_generate_v4(),
  host_id uuid not null references profiles(id) on delete cascade,

  title text not null,
  description text not null default '',
  category_id uuid not null references activity_categories(id),
  gender_policy_code text not null default 'everyone' references event_gender_policies(code),

  city_id uuid not null references cities(id),
  locality_id uuid references localities(id),
  venue_name text not null,
  venue_address text not null,
  venue_lat double precision,
  venue_lng double precision,

  start_time timestamptz not null,
  duration_minutes int not null check (duration_minutes between 30 and 600),

  total_spots int not null check (total_spots between 4 and 50),
  price_rupees int not null default 0 check (price_rupees >= 0),

  is_published boolean not null default false,
  published_at timestamptz,
  cancelled_at timestamptz,
  cancellation_reason text,

  metadata jsonb not null default '{}'::jsonb,

  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz
);
create index events_start_time_idx on events(start_time) where deleted_at is null;
create index events_locality_start_idx on events(locality_id, start_time)
  where deleted_at is null and is_published = true and cancelled_at is null;
create index events_category_start_idx on events(category_id, start_time)
  where deleted_at is null and is_published = true and cancelled_at is null;
create index events_host_id_idx on events(host_id) where deleted_at is null;

-- ============================================================================
-- LAYER 5 — RSVPS + WAVES
-- ============================================================================

create table rsvps (
  id uuid primary key default uuid_generate_v4(),
  event_id uuid not null references events(id) on delete cascade,
  profile_id uuid not null references profiles(id) on delete cascade,
  created_at timestamptz not null default now(),
  cancelled_at timestamptz,
  attended boolean,                    -- host marks post-event for reliability
  unique (event_id, profile_id)
);
create index rsvps_event_active_idx on rsvps(event_id) where cancelled_at is null;
create index rsvps_profile_active_idx on rsvps(profile_id) where cancelled_at is null;

create table waves (
  id uuid primary key default uuid_generate_v4(),
  from_profile_id uuid not null references profiles(id) on delete cascade,
  to_profile_id uuid not null references profiles(id) on delete cascade,
  via_event_id uuid references events(id) on delete set null,
  created_at timestamptz not null default now(),
  unique (from_profile_id, to_profile_id, via_event_id),
  check (from_profile_id <> to_profile_id)
);
create index waves_to_profile_idx on waves(to_profile_id);

-- ============================================================================
-- LAYER 6 — CONVERSATIONS (unified)
-- ============================================================================
-- Every conversation type is a `channel`. Event chats, DMs, and future
-- broadcast/group channels all share the same shape. Adding a new chat
-- feature is one row in `channel_type` + client code, never a schema
-- rewrite.

create table channels (
  id uuid primary key default uuid_generate_v4(),
  type channel_type not null,
  event_id uuid references events(id) on delete cascade,   -- for event_chat
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  archived_at timestamptz,
  unique (event_id, type)     -- one event_chat per event
);
create index channels_event_idx on channels(event_id) where event_id is not null;

create table channel_members (
  id uuid primary key default uuid_generate_v4(),
  channel_id uuid not null references channels(id) on delete cascade,
  profile_id uuid not null references profiles(id) on delete cascade,
  role text not null default 'member' check (role in ('member', 'admin')),
  joined_at timestamptz not null default now(),
  left_at timestamptz,
  last_read_at timestamptz not null default now(),
  unique (channel_id, profile_id)
);
create index channel_members_profile_active_idx on channel_members(profile_id) where left_at is null;
create index channel_members_channel_active_idx on channel_members(channel_id) where left_at is null;

create table messages (
  id uuid primary key default uuid_generate_v4(),
  channel_id uuid not null references channels(id) on delete cascade,
  sender_id uuid references profiles(id) on delete set null,   -- null = system
  body text not null,
  is_system boolean not null default false,
  reply_to_id uuid references messages(id) on delete set null, -- future threading
  metadata jsonb not null default '{}'::jsonb,
  edited_at timestamptz,
  created_at timestamptz not null default now(),
  deleted_at timestamptz
);
create index messages_channel_created_idx on messages(channel_id, created_at desc);

create table message_reactions (
  id uuid primary key default uuid_generate_v4(),
  message_id uuid not null references messages(id) on delete cascade,
  profile_id uuid not null references profiles(id) on delete cascade,
  emoji text not null,
  created_at timestamptz not null default now(),
  unique (message_id, profile_id, emoji)
);

-- ============================================================================
-- LAYER 7 — ATTACHMENTS (unified file store)
-- ============================================================================
-- Every uploaded file — avatar, event cover, ID scan, message photo —
-- lives here. Owner is polymorphic. Storage cleanup + moderation scans
-- + orphan detection all query this one place.

create table attachments (
  id uuid primary key default uuid_generate_v4(),
  owner_type attachment_owner_type not null,
  owner_id uuid not null,
  purpose text not null,                 -- 'avatar', 'selfie', 'cover', 'gallery', 'id_scan', 'live_selfie', 'message_image'
  storage_bucket text not null,          -- 'avatars' | 'event_covers' | 'verifications' | 'message_attachments'
  storage_path text not null,            -- path within the bucket
  mime_type text,
  bytes int,
  width int,
  height int,
  is_public boolean not null default false,
  created_at timestamptz not null default now(),
  deleted_at timestamptz
);
create index attachments_owner_idx on attachments(owner_type, owner_id) where deleted_at is null;

-- Convenience: which attachment is the "primary" of a purpose for an owner?
-- e.g., the primary avatar of a profile. Just the most-recent non-deleted.
create or replace view current_attachments as
select distinct on (owner_type, owner_id, purpose)
  owner_type, owner_id, purpose, storage_bucket, storage_path, is_public, id as attachment_id
from attachments
where deleted_at is null
order by owner_type, owner_id, purpose, created_at desc;

-- ============================================================================
-- LAYER 8 — REPORTS
-- ============================================================================

create table reports (
  id uuid primary key default uuid_generate_v4(),
  reporter_id uuid not null references profiles(id) on delete cascade,
  target_type report_target_type not null,
  target_id uuid not null,                       -- polymorphic
  kind_code text not null references report_kinds(code),
  detail text,
  status report_status not null default 'open',
  created_at timestamptz not null default now(),
  actioned_at timestamptz,
  action_taken text
);
create index reports_status_created_idx on reports(status, created_at desc);
create index reports_target_idx on reports(target_type, target_id);

-- ============================================================================
-- LAYER 9 — NOTIFICATIONS
-- ============================================================================

create table notifications (
  id uuid primary key default uuid_generate_v4(),
  profile_id uuid not null references profiles(id) on delete cascade,
  type_code text not null references notification_types(code),
  title text not null,
  body text not null,
  data jsonb not null default '{}'::jsonb,       -- polymorphic (event_id, from_profile_id, channel_id, ...)
  read_at timestamptz,
  created_at timestamptz not null default now()
);
create index notifications_profile_created_idx on notifications(profile_id, created_at desc);
create index notifications_unread_idx on notifications(profile_id) where read_at is null;

create table push_tokens (
  id uuid primary key default uuid_generate_v4(),
  profile_id uuid not null references profiles(id) on delete cascade,
  token text not null,
  platform text not null check (platform in ('android', 'ios', 'web')),
  updated_at timestamptz not null default now(),
  unique (profile_id, token)
);

create table notification_preferences (
  profile_id uuid not null references profiles(id) on delete cascade,
  type_code text not null references notification_types(code),
  push_enabled boolean not null default true,
  email_enabled boolean not null default false,
  updated_at timestamptz not null default now(),
  primary key (profile_id, type_code)
);

-- ============================================================================
-- LAYER 10 — HOST LIFECYCLE
-- ============================================================================

create table host_applications (
  id uuid primary key default uuid_generate_v4(),
  profile_id uuid not null references profiles(id) on delete cascade,
  event_theme text,
  instagram_url text,
  motivation text,
  status host_status not null default 'applied',
  submitted_at timestamptz not null default now(),
  reviewed_at timestamptz,
  rejection_reason text
);
create index host_applications_profile_idx on host_applications(profile_id);
create index host_applications_status_idx on host_applications(status);

create table host_status_history (
  id uuid primary key default uuid_generate_v4(),
  profile_id uuid not null references profiles(id) on delete cascade,
  from_status host_status,
  to_status host_status not null,
  changed_by uuid references profiles(id) on delete set null,
  reason text,
  changed_at timestamptz not null default now()
);
create index host_status_history_profile_idx on host_status_history(profile_id, changed_at desc);

-- ============================================================================
-- LAYER 11 — OPS
-- ============================================================================

create table activity_log (
  id uuid primary key default uuid_generate_v4(),
  actor_id uuid references profiles(id) on delete set null,
  action text not null,                          -- 'profile.approved', 'event.cancelled', 'report.actioned'
  target_type text,
  target_id uuid,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);
create index activity_log_actor_created_idx on activity_log(actor_id, created_at desc);
create index activity_log_target_idx on activity_log(target_type, target_id);

create table feature_flags (
  code text primary key,                         -- 'dating_layer' | 'payments' | ...
  label text not null,
  is_enabled_globally boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table feature_flag_overrides (
  flag_code text not null references feature_flags(code) on delete cascade,
  profile_id uuid not null references profiles(id) on delete cascade,
  is_enabled boolean not null,
  created_at timestamptz not null default now(),
  primary key (flag_code, profile_id)
);

create table idempotency_keys (
  key text primary key,
  profile_id uuid not null references profiles(id) on delete cascade,
  endpoint text not null,
  response jsonb,
  created_at timestamptz not null default now()
);
create index idempotency_keys_created_idx on idempotency_keys(created_at);

-- ============================================================================
-- VIEWS (the read contract for clients)
-- ============================================================================

-- Fast headcount + gender split per event.
create or replace view event_capacity as
select
  e.id as event_id,
  count(r.*) filter (where r.cancelled_at is null) as rsvp_count,
  count(r.*) filter (where r.cancelled_at is null and p.gender = 'male') as male_count,
  count(r.*) filter (where r.cancelled_at is null and p.gender = 'female') as female_count,
  e.total_spots - count(r.*) filter (where r.cancelled_at is null) as spots_remaining
from events e
left join rsvps r on r.event_id = e.id
left join profiles p on p.id = r.profile_id
where e.deleted_at is null
group by e.id;

-- Mutual waves — the "DM is unlocked" projection.
create or replace view mutual_waves as
select
  least(w1.from_profile_id, w1.to_profile_id) as profile_a,
  greatest(w1.from_profile_id, w1.to_profile_id) as profile_b,
  min(w1.created_at) as matched_at
from waves w1
join waves w2
  on w1.from_profile_id = w2.to_profile_id
 and w1.to_profile_id = w2.from_profile_id
where w1.from_profile_id < w1.to_profile_id
group by 1, 2;

-- Public projection of a profile — what other approved members can see.
create or replace view profiles_public as
select
  p.id,
  p.name,
  p.date_of_birth,
  p.gender,
  p.city_id,
  p.locality_id,
  p.bio,
  p.activities,
  p.host_status,
  p.privacy_blurred,
  p.created_at,
  (select storage_path from current_attachments
    where owner_type = 'profile' and owner_id = p.id and purpose = 'avatar') as avatar_path
from profiles p
where p.deleted_at is null and p.review_status = 'approved';

-- ============================================================================
-- HELPER FUNCTIONS
-- ============================================================================

create or replace function is_admin() returns boolean
language sql stable security definer set search_path = public
as $$
  select coalesce((select is_admin from profiles where id = auth.uid()), false);
$$;

create or replace function is_approved() returns boolean
language sql stable security definer set search_path = public
as $$
  select coalesce(
    (select review_status = 'approved' from profiles where id = auth.uid()),
    false
  );
$$;

create or replace function tg_updated_at() returns trigger
language plpgsql as $$
begin new.updated_at = now(); return new; end;
$$;

create trigger cities_updated_at         before update on cities         for each row execute function tg_updated_at();
create trigger localities_updated_at     before update on localities     for each row execute function tg_updated_at();
create trigger activity_cats_updated_at  before update on activity_categories for each row execute function tg_updated_at();
create trigger profiles_updated_at       before update on profiles       for each row execute function tg_updated_at();
create trigger events_updated_at         before update on events         for each row execute function tg_updated_at();
create trigger feature_flags_updated_at  before update on feature_flags  for each row execute function tg_updated_at();

-- Auto-create a profile row when a Supabase Auth user signs up.
create or replace function tg_on_auth_user_created() returns trigger
language plpgsql security definer set search_path = public as $$
begin
  insert into profiles (id) values (new.id) on conflict do nothing;
  return new;
end;
$$;
create trigger on_auth_user_created after insert on auth.users
  for each row execute function tg_on_auth_user_created();

-- When an event is created, spin up its channel + welcome system message.
create or replace function tg_on_event_created() returns trigger
language plpgsql security definer set search_path = public as $$
declare new_channel uuid;
begin
  insert into channels (type, event_id) values ('event_chat', new.id)
    returning id into new_channel;
  insert into messages (channel_id, sender_id, body, is_system)
  values (
    new_channel, null,
    'Welcome! This is the group chat for ' || new.title ||
    ' on ' || to_char(new.start_time at time zone 'Asia/Kolkata', 'DD Mon') ||
    '. Everyone here is verified. Be respectful and have fun.',
    true
  );
  return new;
end;
$$;
create trigger on_event_created after insert on events
  for each row execute function tg_on_event_created();

-- When an RSVP is inserted or cancelled, add channel membership + system message.
create or replace function tg_on_rsvp_changed() returns trigger
language plpgsql security definer set search_path = public as $$
declare
  uname text;
  ch uuid;
begin
  select coalesce(name, 'Someone') into uname from profiles where id = new.profile_id;
  select id into ch from channels where event_id = new.event_id and type = 'event_chat' limit 1;

  if (tg_op = 'INSERT') then
    -- Join the channel
    insert into channel_members (channel_id, profile_id) values (ch, new.profile_id)
      on conflict (channel_id, profile_id) do update set left_at = null, last_read_at = now();
    -- Post system message
    insert into messages (channel_id, sender_id, body, is_system)
    values (ch, null, uname || ' just RSVP''d and joined the chat.', true);

  elsif (tg_op = 'UPDATE' and old.cancelled_at is null and new.cancelled_at is not null) then
    -- Leave the channel (soft — keeps history)
    update channel_members set left_at = now()
      where channel_id = ch and profile_id = new.profile_id and left_at is null;
    -- Post system message
    insert into messages (channel_id, sender_id, body, is_system)
    values (ch, null, uname || ' cancelled their RSVP.', true);

  elsif (tg_op = 'UPDATE' and old.cancelled_at is not null and new.cancelled_at is null) then
    -- Re-joining after cancel
    insert into channel_members (channel_id, profile_id) values (ch, new.profile_id)
      on conflict (channel_id, profile_id) do update set left_at = null, last_read_at = now();
    insert into messages (channel_id, sender_id, body, is_system)
    values (ch, null, uname || ' rejoined the chat.', true);
  end if;
  return new;
end;
$$;
create trigger on_rsvp_insert after insert on rsvps
  for each row execute function tg_on_rsvp_changed();
create trigger on_rsvp_update after update on rsvps
  for each row execute function tg_on_rsvp_changed();

-- Log every profile review_status transition.
create or replace function tg_log_profile_review() returns trigger
language plpgsql security definer set search_path = public as $$
begin
  if old.review_status is distinct from new.review_status then
    insert into activity_log (actor_id, action, target_type, target_id, metadata)
    values (
      auth.uid(),
      'profile.review_status_changed',
      'profile',
      new.id,
      jsonb_build_object('from', old.review_status, 'to', new.review_status)
    );
    -- Set the approval/rejection timestamps
    if new.review_status = 'approved' and old.review_status <> 'approved' then
      new.approved_at = now();
    elsif new.review_status = 'rejected' and old.review_status <> 'rejected' then
      new.rejected_at = now();
    end if;
  end if;
  return new;
end;
$$;
create trigger profile_review_log before update on profiles
  for each row execute function tg_log_profile_review();

-- Log every host_status transition.
create or replace function tg_log_host_status() returns trigger
language plpgsql security definer set search_path = public as $$
begin
  if old.host_status is distinct from new.host_status then
    insert into host_status_history (profile_id, from_status, to_status, changed_by)
    values (new.id, old.host_status, new.host_status, auth.uid());
  end if;
  return new;
end;
$$;
create trigger profile_host_status_log after update on profiles
  for each row execute function tg_log_host_status();

-- Auto-populate notification_preferences with defaults on first sign-in.
create or replace function tg_ensure_notification_prefs() returns trigger
language plpgsql security definer set search_path = public as $$
begin
  insert into notification_preferences (profile_id, type_code, push_enabled, email_enabled)
  select new.id, nt.code, nt.push_enabled_by_default, nt.email_enabled_by_default
  from notification_types nt
  on conflict do nothing;
  return new;
end;
$$;
create trigger ensure_notification_prefs after insert on profiles
  for each row execute function tg_ensure_notification_prefs();

-- ============================================================================
-- SEED DATA — lookup tables
-- ============================================================================

insert into cities (code, name, country_code, timezone) values
  ('bengaluru', 'Bengaluru', 'IN', 'Asia/Kolkata')
on conflict (code) do nothing;

insert into localities (city_id, name, slug, display_order)
select c.id, x.name, x.slug, x.ord from cities c, (values
  ('Koramangala', 'koramangala', 10),
  ('HSR Layout', 'hsr-layout', 20),
  ('Indiranagar', 'indiranagar', 30),
  ('BTM Layout', 'btm-layout', 40),
  ('Whitefield', 'whitefield', 50),
  ('Bellandur', 'bellandur', 60),
  ('JP Nagar', 'jp-nagar', 70),
  ('Marathahalli', 'marathahalli', 80),
  ('Electronic City', 'electronic-city', 90),
  ('Jayanagar', 'jayanagar', 100),
  ('Yelahanka', 'yelahanka', 110),
  ('Hebbal', 'hebbal', 120),
  ('Madiwala', 'madiwala', 130)
) as x(name, slug, ord)
where c.code = 'bengaluru'
on conflict do nothing;

insert into activity_categories (code, label, icon_name, display_order) values
  ('art',             'Art',            'palette_outlined',            10),
  ('sports',          'Sports',         'sports_basketball_outlined',  20),
  ('food_and_drinks', 'Food & Drinks',  'restaurant_outlined',         30),
  ('outdoors',        'Outdoors',       'terrain_outlined',            40),
  ('music',           'Music',          'graphic_eq_outlined',         50),
  ('board_games',     'Board Games',    'casino_outlined',             60),
  ('clubbing',        'Clubbing',       'nightlife_outlined',          70),
  ('wellness',        'Wellness',       'self_improvement_outlined',   80),
  ('movies',          'Movies',         'movie_outlined',              90)
on conflict (code) do nothing;

insert into event_gender_policies (code, label, display_order) values
  ('everyone',   'Everyone',   10),
  ('women_only', 'Women only', 20),
  ('men_only',   'Men only',   30)
on conflict (code) do nothing;

insert into report_kinds (code, label, display_order) values
  ('harassment',    'Harassment',    10),
  ('spam',          'Spam',          20),
  ('impersonation', 'Impersonation', 30),
  ('safety',        'Safety concern',40),
  ('other',         'Other',         50)
on conflict (code) do nothing;

insert into notification_types (code, label, default_title_template, default_body_template, push_enabled_by_default) values
  ('rsvp_reminder',       'Event reminder',           '{{event_title}} starts soon', '{{event_title}} is coming up. Don''t forget!', true),
  ('chat_mention',        'Chat mention',             'New message in {{channel_name}}', '{{sender}}: {{preview}}', true),
  ('wave_received',       'Someone waved',            'You got a wave from {{name}}', 'Wave back to open a chat.', true),
  ('host_status',         'Host application update',  'Your host application', '{{message}}', true),
  ('event_starting_soon', 'Event starting soon',      '{{event_title}} starts in 1 hour', 'See you at {{venue}}!', true),
  ('event_cancelled',     'Event cancelled',          '{{event_title}} was cancelled', '{{reason}}', true),
  ('profile_approved',    'Welcome to Lively',        'You''re in!', 'Your profile is approved. Start browsing events.', true),
  ('profile_rejected',    'Profile needs updates',    'Almost there', '{{reason}}', true)
on conflict (code) do nothing;

insert into feature_flags (code, label, is_enabled_globally) values
  ('dating_layer',         'Dating layer (Phase 3)',   false),
  ('payments',             'Paid events',              false),
  ('host_broadcasts',      'Host broadcast channels',  false),
  ('interest_groups',      'Standing interest groups', false)
on conflict (code) do nothing;

-- ============================================================================
-- ROW LEVEL SECURITY
-- ============================================================================

alter table profiles                enable row level security;
alter table host_applications       enable row level security;
alter table host_status_history     enable row level security;
alter table events                  enable row level security;
alter table rsvps                   enable row level security;
alter table channels                enable row level security;
alter table channel_members         enable row level security;
alter table messages                enable row level security;
alter table message_reactions       enable row level security;
alter table attachments             enable row level security;
alter table waves                   enable row level security;
alter table reports                 enable row level security;
alter table notifications           enable row level security;
alter table push_tokens             enable row level security;
alter table notification_preferences enable row level security;
alter table activity_log            enable row level security;
alter table feature_flag_overrides  enable row level security;
alter table idempotency_keys        enable row level security;

-- Lookup tables — everyone can read, only admins can write.
alter table cities                enable row level security;
alter table localities            enable row level security;
alter table activity_categories   enable row level security;
alter table event_gender_policies enable row level security;
alter table report_kinds          enable row level security;
alter table notification_types    enable row level security;
alter table feature_flags         enable row level security;

create policy "cities read"                 on cities                for select using (true);
create policy "cities admin write"          on cities                for all using (is_admin());
create policy "localities read"             on localities            for select using (true);
create policy "localities admin write"      on localities            for all using (is_admin());
create policy "activity_cats read"          on activity_categories   for select using (true);
create policy "activity_cats admin write"   on activity_categories   for all using (is_admin());
create policy "gender_policies read"        on event_gender_policies for select using (true);
create policy "gender_policies admin write" on event_gender_policies for all using (is_admin());
create policy "report_kinds read"           on report_kinds          for select using (true);
create policy "report_kinds admin write"    on report_kinds          for all using (is_admin());
create policy "notification_types read"     on notification_types    for select using (true);
create policy "notification_types admin write" on notification_types for all using (is_admin());
create policy "feature_flags read"          on feature_flags         for select using (true);
create policy "feature_flags admin write"   on feature_flags         for all using (is_admin());

-- profiles
create policy "profiles self all"    on profiles for all    using (id = auth.uid());
create policy "profiles peer read"   on profiles for select using (
  is_approved() and review_status = 'approved' and deleted_at is null
);
create policy "profiles admin all"   on profiles for all    using (is_admin());

-- host_applications
create policy "host_apps self all"   on host_applications for all using (profile_id = auth.uid());
create policy "host_apps admin all"  on host_applications for all using (is_admin());

-- host_status_history — read your own, admins see all
create policy "host_hist self read"  on host_status_history for select using (profile_id = auth.uid());
create policy "host_hist admin all"  on host_status_history for all    using (is_admin());

-- events
create policy "events public read"   on events for select using (
  is_approved() and is_published and cancelled_at is null and deleted_at is null
);
create policy "events host manage"   on events for all using (host_id = auth.uid());
create policy "events admin all"     on events for all using (is_admin());

-- rsvps
create policy "rsvps self all"       on rsvps for all using (profile_id = auth.uid());
create policy "rsvps event peers read" on rsvps for select using (
  is_approved() and event_id in (
    select event_id from rsvps where profile_id = auth.uid() and cancelled_at is null
  )
);
create policy "rsvps host read"      on rsvps for select using (
  event_id in (select id from events where host_id = auth.uid())
);
create policy "rsvps admin all"      on rsvps for all using (is_admin());

-- channels — you can see channels you're a member of
create policy "channels member read" on channels for select using (
  id in (select channel_id from channel_members where profile_id = auth.uid() and left_at is null)
);
create policy "channels admin all"   on channels for all using (is_admin());

-- channel_members — see + edit your own row, see other members of channels you're in
create policy "cm self all"          on channel_members for all using (profile_id = auth.uid());
create policy "cm peers read"        on channel_members for select using (
  channel_id in (select channel_id from channel_members where profile_id = auth.uid() and left_at is null)
);

-- messages — read messages of channels you're an active member of; write as yourself
create policy "messages channel read"  on messages for select using (
  channel_id in (select channel_id from channel_members where profile_id = auth.uid() and left_at is null)
);
create policy "messages send"          on messages for insert with check (
  sender_id = auth.uid() and
  channel_id in (select channel_id from channel_members where profile_id = auth.uid() and left_at is null)
);
create policy "messages own edit"      on messages for update using (sender_id = auth.uid());
create policy "messages own delete"    on messages for delete using (sender_id = auth.uid());

-- message_reactions — read reactions in channels you're in, add/remove your own
create policy "reactions channel read" on message_reactions for select using (
  message_id in (
    select m.id from messages m
    where m.channel_id in (select channel_id from channel_members where profile_id = auth.uid() and left_at is null)
  )
);
create policy "reactions self all"     on message_reactions for all using (profile_id = auth.uid());

-- attachments — public ones are readable by all approved users; private ones by the owner or admins
create policy "attachments public read"  on attachments for select using (is_public and deleted_at is null);
create policy "attachments admin all"    on attachments for all using (is_admin());
-- Owner-based read: profile attachments visible to the owner + peers (via profiles_public view)
create policy "attachments owner read" on attachments for select using (
  (owner_type = 'profile' and owner_id = auth.uid()) or
  (owner_type = 'event' and owner_id in (select id from events where host_id = auth.uid())) or
  (owner_type = 'message' and owner_id in (
    select m.id from messages m
    where m.channel_id in (select channel_id from channel_members where profile_id = auth.uid() and left_at is null)
  )) or
  (owner_type = 'host_application' and owner_id in (select id from host_applications where profile_id = auth.uid()))
);
create policy "attachments owner write" on attachments for insert with check (
  (owner_type = 'profile' and owner_id = auth.uid()) or
  (owner_type = 'event' and owner_id in (select id from events where host_id = auth.uid())) or
  (owner_type = 'message' and owner_id in (
    select m.id from messages m where m.sender_id = auth.uid()
  )) or
  (owner_type = 'host_application' and owner_id in (select id from host_applications where profile_id = auth.uid()))
);

-- waves
create policy "waves send"           on waves for insert with check (from_profile_id = auth.uid());
create policy "waves involved read"  on waves for select using (
  from_profile_id = auth.uid() or to_profile_id = auth.uid()
);
create policy "waves admin all"      on waves for all using (is_admin());

-- reports
create policy "reports self all"     on reports for all using (reporter_id = auth.uid());
create policy "reports admin all"    on reports for all using (is_admin());

-- notifications
create policy "notifs self all"      on notifications for all using (profile_id = auth.uid());
create policy "notifs admin all"     on notifications for all using (is_admin());

-- push_tokens
create policy "push_tokens self all" on push_tokens for all using (profile_id = auth.uid());

-- notification_preferences
create policy "notif_prefs self all" on notification_preferences for all using (profile_id = auth.uid());

-- activity_log — admins only (or your own for future in-app history feature)
create policy "activity_log admin all" on activity_log for all using (is_admin());
create policy "activity_log self read" on activity_log for select using (actor_id = auth.uid());

-- feature_flag_overrides
create policy "flag_overrides self read" on feature_flag_overrides for select using (profile_id = auth.uid());
create policy "flag_overrides admin all" on feature_flag_overrides for all using (is_admin());

-- idempotency_keys
create policy "idem self all" on idempotency_keys for all using (profile_id = auth.uid());
