-- ============================================================================
-- Migrate events from client-side mocks to real Supabase rows.
--
-- Changes:
--   * events.host_id becomes nullable — supports "system-curated" events
--     while we're pre-launch. Real hosts will set host_id on their own events.
--   * events gains denormalised display columns (cover_image_url,
--     host_display_*, attendee_avatar_urls). Real hosts populate these
--     from their profile at Create Event time. System seeds populate directly.
--   * events gains male_rsvp_count / female_rsvp_count counters, updated
--     via trigger from `rsvps` so client-side reads stay one query.
--   * events gets a "neighbourhood" text field for display convenience.
--   * Seed 12 real events across categories, gender policies, and dates.
-- ============================================================================

alter table events alter column host_id drop not null;

alter table events add column if not exists cover_image_url text;
alter table events add column if not exists neighbourhood text;
alter table events add column if not exists host_display_name text;
alter table events add column if not exists host_display_photo_url text;
alter table events add column if not exists host_display_bio text;
alter table events add column if not exists host_display_rating numeric(2,1);
alter table events add column if not exists host_display_events_hosted int default 0;
alter table events add column if not exists host_display_verified boolean default true;
alter table events add column if not exists attendee_avatar_urls text[] default '{}'::text[];
alter table events add column if not exists male_rsvp_count int not null default 0;
alter table events add column if not exists female_rsvp_count int not null default 0;

-- --------------------------------------------------------------------------
-- Trigger: keep event counters in sync with rsvps table.
-- Runs SECURITY DEFINER so it can update event rows the user can't touch.
-- --------------------------------------------------------------------------
create or replace function tg_recalc_event_rsvp_counts() returns trigger
language plpgsql security definer set search_path = public as $$
declare
  target_event_id uuid;
begin
  target_event_id := coalesce(new.event_id, old.event_id);
  update events set
    male_rsvp_count = (
      select count(*) from rsvps r
      join profiles p on p.id = r.profile_id
      where r.event_id = target_event_id
        and r.cancelled_at is null
        and p.gender = 'male'
    ),
    female_rsvp_count = (
      select count(*) from rsvps r
      join profiles p on p.id = r.profile_id
      where r.event_id = target_event_id
        and r.cancelled_at is null
        and p.gender = 'female'
    )
  where id = target_event_id;
  return null;
end;
$$;

drop trigger if exists on_rsvp_recalc_counts_ins on rsvps;
drop trigger if exists on_rsvp_recalc_counts_upd on rsvps;
create trigger on_rsvp_recalc_counts_ins after insert on rsvps
  for each row execute function tg_recalc_event_rsvp_counts();
create trigger on_rsvp_recalc_counts_upd after update on rsvps
  for each row execute function tg_recalc_event_rsvp_counts();

-- --------------------------------------------------------------------------
-- Seed events. All start within the next 2 weeks so filters "This
-- weekend" and "Next week" have data.
-- --------------------------------------------------------------------------
--
-- Trick: use CTEs to look up category/locality/city UUIDs by their
-- stable code strings — so this script is idempotent + doesn't hardcode
-- UUIDs.
-- --------------------------------------------------------------------------

-- Wipe any prior seed events (idempotent re-runs). Only removes rows
-- with null host_id (system seeds); user-created events are safe.
delete from events where host_id is null;

with lookup as (
  select
    (select id from cities where code = 'bengaluru') as city_id,
    (select id from localities where slug = 'koramangala') as loc_kora,
    (select id from localities where slug = 'hsr-layout')  as loc_hsr,
    (select id from localities where slug = 'indiranagar') as loc_indi,
    (select id from localities where slug = 'jayanagar')   as loc_jaya,
    (select id from activity_categories where code = 'art')             as cat_art,
    (select id from activity_categories where code = 'sports')          as cat_sports,
    (select id from activity_categories where code = 'food_and_drinks') as cat_food,
    (select id from activity_categories where code = 'outdoors')        as cat_outdoors,
    (select id from activity_categories where code = 'music')           as cat_music,
    (select id from activity_categories where code = 'board_games')     as cat_board,
    (select id from activity_categories where code = 'wellness')        as cat_wellness
)
insert into events (
  host_id, title, description, category_id, gender_policy_code,
  city_id, locality_id, neighbourhood, venue_name, venue_address,
  start_time, duration_minutes, total_spots, price_rupees,
  is_published, published_at,
  cover_image_url, host_display_name, host_display_photo_url,
  host_display_bio, host_display_rating, host_display_events_hosted,
  host_display_verified, attendee_avatar_urls
)
select * from (values
  (null::uuid, 'Sunday Art Jam — Paint, Sip & Chill',
   'Bring your creative energy — we''re painting on canvas with acrylics, paired with good coffee and better conversations. No experience needed. Materials provided.',
   (select cat_art from lookup), 'women_only',
   (select city_id from lookup), (select loc_kora from lookup), 'Koramangala',
   'The Hive', '39, 1st A Main Rd, 5th Block, Koramangala, Bengaluru 560034',
   now() + interval '2 days' + interval '16 hours', 150, 20, 349,
   true, now(),
   'https://images.unsplash.com/photo-1513364776144-60967b0f800f?w=800',
   'Meera S.', 'https://i.pravatar.cc/150?img=47',
   'Painter and creative host. Loves calm afternoons and messy palettes.',
   4.9, 8, true,
   array['https://i.pravatar.cc/150?img=12','https://i.pravatar.cc/150?img=25','https://i.pravatar.cc/150?img=33','https://i.pravatar.cc/150?img=41']),

  (null, 'Beer & Board Games Night',
   'Settlers of Catan, Codenames, Wavelength, Exploding Kittens — 15+ games. Teams randomized so you meet new people. All skill levels welcome.',
   (select cat_board from lookup), 'everyone',
   (select city_id from lookup), (select loc_indi from lookup), 'Indiranagar',
   'Toit Brewpub', '298, 100 Feet Rd, Indiranagar, Bengaluru 560038',
   now() + interval '4 days' + interval '19 hours', 180, 24, 0,
   true, now(),
   'https://images.unsplash.com/photo-1610890716171-6b1bb98ffd09?w=800',
   'Arjun K.', 'https://i.pravatar.cc/150?img=14',
   'Board game hoarder, pub quiz enthusiast, hosts weekly game nights.',
   4.7, 12, true,
   array['https://i.pravatar.cc/150?img=5','https://i.pravatar.cc/150?img=8','https://i.pravatar.cc/150?img=19','https://i.pravatar.cc/150?img=22']),

  (null, 'Sunrise Yoga at Cubbon Park',
   'Morning yoga in the park, surrounded by trees instead of screens. Bring your own mat or we have a few extras. All levels welcome.',
   (select cat_wellness from lookup), 'everyone',
   (select city_id from lookup), (select loc_kora from lookup), 'Cubbon Park',
   'Cubbon Park', 'Band Stand Area, Kasturba Road, Cubbon Park, Bengaluru 560001',
   now() + interval '3 days' + interval '6 hours', 90, 30, 0,
   true, now(),
   'https://images.unsplash.com/photo-1545389336-cf090694435e?w=800',
   'Riya M.', 'https://i.pravatar.cc/150?img=45',
   'Certified instructor, slow flow specialist, morning person.',
   4.8, 5, true,
   array['https://i.pravatar.cc/150?img=27','https://i.pravatar.cc/150?img=38','https://i.pravatar.cc/150?img=49']),

  (null, 'Badminton Doubles — HSR Courts',
   'Doubles matches with randomized partners. All skill levels. 4 courts booked for 2 hours. Rackets available if you don''t have one.',
   (select cat_sports from lookup), 'everyone',
   (select city_id from lookup), (select loc_hsr from lookup), 'HSR Layout',
   'Shuttle Zone', 'Sector 2, HSR Layout, Bengaluru 560102',
   now() + interval '2 days' + interval '7 hours', 120, 16, 199,
   true, now(),
   'https://images.unsplash.com/photo-1626224583764-f87db24ac4ea?w=800',
   'Vikram D.', 'https://i.pravatar.cc/150?img=13',
   'Weekend player. Believes doubles is the most fun format.',
   4.6, 3, true,
   array['https://i.pravatar.cc/150?img=5','https://i.pravatar.cc/150?img=8']),

  (null, 'Women''s Book Club — September Pick',
   'This month we''re reading Shuggie Bain by Douglas Stuart. Come even if you haven''t finished it — no spoiler police here. Judgment-free reading community.',
   (select cat_art from lookup), 'women_only',
   (select city_id from lookup), (select loc_kora from lookup), 'Koramangala',
   'Atta Galatta', '134, KHB Colony, 5th Block, Koramangala, Bengaluru 560034',
   now() + interval '5 days' + interval '11 hours', 120, 12, 149,
   true, now(),
   'https://images.unsplash.com/photo-1521056787327-165eefc12a2e?w=800',
   'Ananya R.', 'https://i.pravatar.cc/150?img=48',
   'Reader, quiet-cafe hunter, occasional writer.',
   5.0, 6, true,
   array['https://i.pravatar.cc/150?img=12','https://i.pravatar.cc/150?img=25','https://i.pravatar.cc/150?img=33']),

  (null, 'Pottery & Clay — Make Your Own Mug',
   'Hands in clay, phone in pocket. We''re making mugs from scratch — wedging, centering, pulling. Zero experience needed.',
   (select cat_art from lookup), 'everyone',
   (select city_id from lookup), (select loc_indi from lookup), 'Indiranagar',
   'Claystation Studio', '12th Main, HAL 2nd Stage, Indiranagar, Bengaluru 560038',
   now() + interval '6 days' + interval '15 hours', 150, 16, 499,
   true, now(),
   'https://images.unsplash.com/photo-1565193286369-a75c4ea24ef7?w=800',
   'Meera S.', 'https://i.pravatar.cc/150?img=47',
   'Painter and creative host. Loves calm afternoons and messy palettes.',
   4.9, 8, true,
   array['https://i.pravatar.cc/150?img=12','https://i.pravatar.cc/150?img=25','https://i.pravatar.cc/150?img=33','https://i.pravatar.cc/150?img=41']),

  (null, 'Friday Night Pub Quiz',
   '5 rounds. Pop culture, sports, Bangalore trivia, science, mystery round. Teams of 4-5. Winning team gets bragging rights.',
   (select cat_board from lookup), 'everyone',
   (select city_id from lookup), (select loc_indi from lookup), 'Indiranagar',
   'The Humming Tree', '12th Main, HAL 2nd Stage, Indiranagar, Bengaluru 560008',
   now() + interval '4 days' + interval '19 hours' + interval '30 minutes', 150, 30, 0,
   true, now(),
   'https://images.unsplash.com/photo-1543007630-9710e4a00a20?w=800',
   'Arjun K.', 'https://i.pravatar.cc/150?img=14',
   'Board game hoarder, pub quiz enthusiast, hosts weekly game nights.',
   4.7, 12, true,
   array['https://i.pravatar.cc/150?img=22','https://i.pravatar.cc/150?img=29','https://i.pravatar.cc/150?img=36','https://i.pravatar.cc/150?img=44']),

  (null, 'Agara Lake Sunset Walk',
   'Walk, talk, breathe. We meet at the main entrance, walk the loop together, and grab chai at the end. No agenda, no icebreaker games.',
   (select cat_outdoors from lookup), 'everyone',
   (select city_id from lookup), (select loc_hsr from lookup), 'HSR Layout',
   'Agara Lake', 'Agara Lake Walking Path, HSR Layout, Bengaluru 560102',
   now() + interval '2 days' + interval '17 hours', 90, 20, 0,
   true, now(),
   'https://images.unsplash.com/photo-1502680390469-be75c86b636f?w=800',
   'Sneha P.', 'https://i.pravatar.cc/150?img=32',
   'New host. Loves walking-and-talking as a social format.',
   4.5, 2, true,
   array['https://i.pravatar.cc/150?img=5','https://i.pravatar.cc/150?img=8']),

  (null, 'Women''s Cooking Night — South Indian Thali',
   'We''re making a full thali from scratch — sambar, rasam, poriyal, rice, papad, and payasam. Divide and conquer style.',
   (select cat_food from lookup), 'women_only',
   (select city_id from lookup), (select loc_jaya from lookup), 'Jayanagar',
   'Divya''s Home Kitchen', 'Address shared with confirmed attendees',
   now() + interval '3 days' + interval '17 hours', 180, 10, 399,
   true, now(),
   'https://images.unsplash.com/photo-1567337710282-00832b415979?w=800',
   'Divya N.', 'https://i.pravatar.cc/150?img=44',
   'Home cook. Believes filter coffee is a personality trait.',
   4.8, 4, true,
   array['https://i.pravatar.cc/150?img=12','https://i.pravatar.cc/150?img=25','https://i.pravatar.cc/150?img=33']),

  (null, 'Indie Music Listening Session',
   'Each person brings one song that changed their life. We listen together, the person explains why it matters, we discuss. No mainstream Bollywood.',
   (select cat_music from lookup), 'everyone',
   (select city_id from lookup), (select loc_kora from lookup), 'Koramangala',
   'Fandom at Gilly''s', '413, 100 Feet Rd, 4th Block, Koramangala, Bengaluru 560034',
   now() + interval '2 days' + interval '18 hours', 150, 25, 199,
   true, now(),
   'https://images.unsplash.com/photo-1470229722913-7c0e2dbbafd3?w=800',
   'Karthik V.', 'https://i.pravatar.cc/150?img=60',
   'Vinyl collector. Runs a small listening room on the side.',
   4.6, 7, true,
   array['https://i.pravatar.cc/150?img=22','https://i.pravatar.cc/150?img=29','https://i.pravatar.cc/150?img=36']),

  (null, 'Climbing & Bouldering for Beginners',
   'Never climbed before? Perfect. The gym instructor takes us through safety, basic technique, and then we climb.',
   (select cat_sports from lookup), 'everyone',
   (select city_id from lookup), (select loc_indi from lookup), 'Indiranagar',
   'Boulder Box', '3rd Cross, 6th Main, HAL 2nd Stage, Indiranagar, Bengaluru 560038',
   now() + interval '5 days' + interval '10 hours', 120, 14, 349,
   true, now(),
   'https://images.unsplash.com/photo-1522163182402-834f871fd851?w=800',
   'Priya L.', 'https://i.pravatar.cc/150?img=32',
   'Climber. Loves the moment before you commit to a hold.',
   4.7, 3, true,
   array['https://i.pravatar.cc/150?img=5','https://i.pravatar.cc/150?img=8']),

  (null, 'Late Night Chaai & Deep Conversations',
   'No icebreakers. No networking. Just a table, chai, and a conversation starter deck — 50 questions from what''s a hill you''ll die on to what would your 15-year-old self think of you now.',
   (select cat_food from lookup), 'everyone',
   (select city_id from lookup), (select loc_hsr from lookup), 'HSR Layout',
   'Third Wave Coffee', '27th Main Rd, 1st Sector, HSR Layout, Bengaluru 560102',
   now() + interval '4 days' + interval '21 hours', 120, 15, 0,
   true, now(),
   'https://images.unsplash.com/photo-1571934811356-5cc061b6821f?w=800',
   'Rohit S.', 'https://i.pravatar.cc/150?img=52',
   'Question collector. Believes chai + strangers = magic.',
   4.9, 5, true,
   array['https://i.pravatar.cc/150?img=22','https://i.pravatar.cc/150?img=29','https://i.pravatar.cc/150?img=36','https://i.pravatar.cc/150?img=44'])
) as t;

-- Sanity check
select count(*) as event_count from events where host_id is null;
