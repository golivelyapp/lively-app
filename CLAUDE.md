# Lively — Project Reference

> **Read this first.** This file is the running memory of the project. Every Claude Code session should update the SESSION LOG at the bottom before finishing. Never delete prior entries.

---

## 1. What the app is

**Lively** is a Flutter mobile app for **discovering and hosting real-world social events in Bangalore, India** — think small-group meetups (art, sports, food & drinks, outdoors, music, board games, clubbing, wellness, movies). Users onboard with a curated profile, browse a feed of upcoming events, RSVP, chat with attendees, and can apply to become verified hosts to publish their own events.

**It is NOT a dating app.** The `pubspec.yaml` still says "Lively — dating app" — that description is stale and should be updated.

- **Target platform:** Android (primary alpha), iOS-capable.
- **Distribution:** Alpha via APK / Firebase App Distribution.
- **City scope:** Bangalore only for launch (14 seeded localities).
- **Support / admin email:** `golively.app@gmail.com`.
- **Android package:** `com.lively.lively`.
- **Deep-link scheme:** `lively://login-callback/` (Supabase OAuth redirect).

---

## 2. Tech stack

| Layer | Choice |
|---|---|
| Framework | Flutter 3.47.1 / Dart SDK `>=3.8.0 <4.0.0` |
| State | `flutter_riverpod ^2.5.1` (Provider, StateProvider, Notifier, FutureProvider, StreamProvider) |
| Routing | `go_router ^17.5.0` with `StatefulShellRoute.indexedStack` + `refreshListenable` |
| Models | `freezed ^4.0.0` + `json_serializable` (code-generated) |
| Backend | Supabase (`supabase_flutter ^2.5.6`) — Auth, Postgres+PostgREST, Storage |
| Auth | Google OAuth + Apple OAuth via `signInWithOAuth` |
| Images | `cached_network_image`, `image_picker` |
| Local storage | `hive_flutter` (unused so far, kept for future) |
| HTTP | `dio` (unused so far) |
| Anim | `flutter_animate` |
| Misc | `share_plus`, `url_launcher` |
| Icons | `flutter_launcher_icons` |
| Build hygiene | `analysis_options.yaml`: `strict-casts`, `strict-inference`, `strict-raw-types`, `prefer_const_constructors`, `avoid_dynamic_calls`, `always_declare_return_types` |

**Env is required at build time** — Supabase URL + anon key are compiled in via `--dart-define-from-file=.env.json`. Missing the flag makes the app throw on startup (splash hang symptom).

```bash
flutter build apk --debug --dart-define-from-file=.env.json
flutter run --dart-define-from-file=.env.json
```

---

## 3. Folder structure (`lib/`)

```
lib/
├── main.dart                  # runApp entry — asserts Env then initialises Supabase
├── app.dart                   # MaterialApp.router; watches profileHydrationProvider
│
├── core/                      # cross-cutting infra
│   ├── api/
│   │   ├── env.dart           # Env class — reads dart-define values
│   │   └── supabase_client.dart  # SupabaseService.initialize() + client accessor
│   ├── router/
│   │   ├── app_router.dart    # GoRouter + AuthStatus redirect logic
│   │   ├── route_paths.dart   # RoutePaths constants
│   │   └── main_shell.dart    # bottom NavigationBar shell (4 tabs)
│   ├── theme/
│   │   ├── app_theme.dart     # ThemeData.light (SF Pro Display)
│   │   ├── app_colors.dart    # every hex value
│   │   ├── app_spacing.dart   # spacing + radius tokens
│   │   ├── app_text_styles.dart  # AppTextStyles
│   │   └── app_gradients.dart # cta / marketing gradients
│   ├── data/
│   │   └── bangalore_localities.dart  # 14 localities
│   ├── utils/
│   │   ├── submission_guard.dart  # runGuarded() — loading + error SnackBar
│   │   └── photo_image_provider.dart  # NetworkImage vs FileImage switch
│   └── widgets/
│       ├── gradient_button.dart      # coral→magenta pill CTA
│       ├── pill_toggle.dart          # black-fill selected pill
│       ├── discount_badge.dart       # "Save X%" pill
│       ├── locality_picker_sheet.dart
│       └── constellation_graphic.dart # animated splash graphic
│
└── features/                  # each vertical slice
    ├── auth/
    │   ├── repositories/
    │   │   ├── auth_repository.dart      # OAuth sign-in / signOut
    │   │   └── profile_repository.dart   # profiles CRUD, photos, city/localities
    │   └── providers/
    │       └── auth_state_provider.dart  # authStateProvider, currentProfileProvider
    │
    ├── onboarding/
    │   ├── screens/                     # intro, splash, basics, profile_picture,
    │   │                                # chip_select_step, single_text_step (bio),
    │   │                                # selfie_verification, socials, height,
    │   │                                # prompt_list_step
    │   ├── models/                      # onboarding_draft (freezed), onboarding_step,
    │   │                                # onboarding_enums, onboarding_options
    │   ├── providers/
    │   │   ├── onboarding_draft_controller.dart  # Notifier<OnboardingDraft>
    │   │   └── profile_hydration.dart   # mirrors Supabase profile → draft on cold start
    │   └── repositories/
    │       └── supabase_onboarding_repository.dart  # LEGACY — see Known Issues
    │
    ├── home/
    │   ├── screens/                     # home_screen, event_detail_screen
    │   ├── widgets/                     # event_card, attendee_avatar_stack,
    │   │                                # gender_balance_bar, filter chips
    │   ├── models/                      # event (freezed), event_category
    │   ├── providers/event_providers.dart  # feed + filters + rsvp controller
    │   └── repositories/
    │       ├── event_repository.dart              # abstract
    │       └── supabase_event_repository.dart     # concrete: fetch / rsvp / createEvent
    │
    ├── profile/
    │   ├── screens/                     # you_screen, host_verification_screen,
    │   │                                # awaiting_review_screen, create_event_screen,
    │   │                                # profile_enhance_screens (7 enhancement flows)
    │   ├── providers/host_verification_provider.dart
    │   └── models/host_verification_status.dart
    │
    ├── chats/
    │   ├── screens/                     # chats_screen (2-tab), event_chat_screen
    │   ├── providers/event_chat_provider.dart  # ChatController (async family) +
    │   │                                # unread providers + inbox realtime watcher
    │   ├── repositories/
    │   │   └── supabase_chat_repository.dart   # ensureChannel, streamMessages,
    │   │                                       # sendMessage, name cache,
    │   │                                       # markChannelRead, unread RPC
    │   └── models/chat_message.dart     # id, senderId, status, clientTempId
    │
    ├── people/
    │   └── screens/people_screen.dart   # attendees list — uses mock names
    │
    └── notifications/
        └── notifications_screen.dart    # placeholder — no push wired
```

---

## 4. Screens

### Onboarding (pinned when `review_status ∈ {draft, submitted, under_review, rejected}`)

| Screen | Purpose |
|---|---|
| `splash_screen.dart` | Tap-to-continue with `ConstellationGraphic` |
| `intro_screen.dart` | Marketing intro; CTA → login |
| `login_screen.dart` (auth feature) | Google / Apple OAuth; 45 s timeout with resume-detect cancel |
| `basics_screen.dart` | Name, DOB, locality (Bangalore sheet), gender |
| `profile_picture_screen.dart` | Primary avatar upload |
| `chip_select_step_screen.dart` | Activities (max 3 of 9) |
| `single_text_step_screen.dart` | Bio |
| `selfie_verification_screen.dart` | Selfie for review |
| `awaiting_review_screen.dart` | Pinned while review in progress; preview-mode auto-approves after 4 s |
| `socials_screen.dart` / `height_screen.dart` / `prompt_list_step_screen.dart` | Optional profile enhancement steps |

### Main app (behind bottom `NavigationBar` in `main_shell.dart`)

| Tab | Route | Screen |
|---|---|---|
| Home | `/home` | `home_screen.dart` — filter chips + event feed |
| People | `/people` | `people_screen.dart` — attendees from past RSVPs (mock names) |
| Chats | `/chats` | `chats_screen.dart` — 2-tab (Events / Direct) |
| You | `/you` | `you_screen.dart` — profile header, reliability, host card, cards for MoreAboutYou / Favourites / Socials, settings + sign-out |

### Detail / action screens

- `event/:id` → `event_detail_screen.dart` — RSVP CTA, host card, meta.
- `chats/:id` → `event_chat_screen.dart` — group chat for an event.
- `create-event` → `create_event_screen.dart` — 6-step wizard (Basics · WhenWhere · Capacity · Pricing · Photos · Preview).
- `host-verification` → `host_verification_screen.dart` — ID + selfie flow; writes `host_status='under_review'` then auto-approves in preview mode.
- `profile/edit/*` → the seven `profile_enhance_screens.dart` flows (Height, Traits, Work, Musicians, Movies, Dishes, Socials).

---

## 5. Shared components (where each is used)

| Component | Used in |
|---|---|
| `GradientButton` | Primary CTA on almost every full-screen flow (login, onboarding steps, create-event, host-verification) |
| `PillToggle` | Gender picker (basics), category filters (home), gender-policy picker (create-event) |
| `DiscountBadge` | Event pricing display when women/men price is lower than `price_rupees` |
| `LocalityPickerSheet` | Basics screen + create-event `WhenWhere` step |
| `ConstellationGraphic` | Splash |
| `AttendeeAvatarStack` | `event_card`, `event_detail_screen` |
| `GenderBalanceBar` | `event_card`, `event_detail_screen` |
| `EventCard` | Home feed + You-tab "upcoming RSVPs" |
| `runGuarded()` (util) | Every Supabase write in onboarding + create-event so failures surface via SnackBar |
| `photoImageProvider()` (util) | Anywhere a photo may be either a network URL or a local file path |

---

## 6. Theme tokens

### Colors (`lib/core/theme/app_colors.dart`)

**Brand**

| Token | Hex | Notes |
|---|---|---|
| `coral` | `#FF7A59` | CTA gradient start |
| `magenta` | `#C2255F` | CTA gradient end |
| `pinkBgStart` | `#D6217E` | Marketing background start |
| `plumBgEnd` | `#6B1B6B` | Marketing background end |
| `pink` | `#E91E8C` | Accent / like state |
| `pinkTint` | `#FCE4EC` | Women-only tag background |
| `goldTint` | `#FFF6E5` | Verified / premium tint |
| `black` | `#141416` | Primary dark |
| `gold` | `#F2B705` | Verified badge |

**Structural**

| Token | Hex |
|---|---|
| `background` | `#FFFFFF` |
| `surface` | `#F7F5F6` |
| `surfaceAlt` | `#EFEEF0` |
| `lockChip` | `#F0F0F2` |
| `textPrimary` | `#1A1A1E` |
| `textSecondary` | `#6B6B72` |
| `textOnDark` | `#FFFFFF` |
| `border` | `#E5E5EA` |
| `error` | `#FF3B30` |

**Semantic / balance**

| Token | Hex |
|---|---|
| `success` | `#1F9D55` |
| `warning` | `#E85D2A` |
| `balanceWomen` | `#9BC5A9` |
| `balanceMen` | `#9FB8E5` |
| `pass` | `#9E9EA6` |
| `like` | same as `pink` |

### Spacing + radius (`app_spacing.dart`)

| Token | px |
|---|---|
| `xs` | 4 |
| `sm` | 8 |
| `md` | 16 |
| `lg` | 24 |
| `xl` | 32 |
| `xxl` | 48 |
| `radiusSm` | 8 |
| `radiusMd` | 16 |
| `radiusLg` | 24 |
| `radiusFull` | 999 |

### Text styles (`app_text_styles.dart`) — font family: **SF Pro Display**

| Style | Size / weight / height |
|---|---|
| `displayLg` | 32 / w700 / 1.2 |
| `headline` | 22 / w600 / 1.25 |
| `body` | 16 / w400 / 1.4 |
| `bodySecondary` | 14 / w400 / 1.4 |
| `button` | 16 / w600 |
| `caption` | 12 / w500 |

### Gradients (`app_gradients.dart`)

- `cta`: linear `coral → magenta`
- `marketingBackground`: linear `pinkBgStart → plumBgEnd`
- `marketingBlob`: radial soft blob for hero backgrounds

---

## 7. Navigation

Router lives in `lib/core/router/app_router.dart`. Uses **`GoRouter`** with a `refreshListenable` (`_AuthChangeNotifier`) that fires on any auth-state change.

### Route paths (`route_paths.dart`)

| Const | Path |
|---|---|
| `splash` | `/` |
| `intro` | `/intro` |
| `login` | `/login` |
| `onboardingBasics` | `/onboarding/basics` |
| `onboardingProfilePicture` | `/onboarding/profile-picture` |
| `onboardingActivities` | `/onboarding/activities` |
| `onboardingBio` | `/onboarding/bio` |
| `onboardingSelfie` | `/onboarding/selfie` |
| `awaitingReview` | `/awaiting-review` |
| `home` | `/home` |
| `people` | `/people` |
| `chats` | `/chats` |
| `you` | `/you` |
| `eventDetail` | `/event/:id` |
| `eventChat` | `/chats/:id` |
| `createEvent` | `/create-event` |
| `hostVerification` | `/host-verification` |
| `profileEditHeight`, `profileEditTraits`, `profileEditWork`, `profileEditMusicians`, `profileEditMovies`, `profileEditDishes`, `profileEditSocials` | `/profile/edit/*` |

### Redirect logic

Derived by `authStateProvider` → one of:

- `unauthenticated` → sends to `/intro` or `/login`.
- `onboarding` (`review_status = draft`) → pins to the correct onboarding step.
- `awaitingReview` (`review_status ∈ {submitted, under_review, rejected}`) → pins to `/awaiting-review`.
- `authenticated` (`review_status = approved`) → releases into the shell (`/home` default).

### Shell (`main_shell.dart`)

Bottom `NavigationBar` with 4 destinations using `StatefulShellRoute.indexedStack`. Selected pill uses `AppColors.pink.withOpacity(0.12)` (deprecated API — analyzer warns).

---

## 8. Supabase

### Client (`lib/core/api/supabase_client.dart`)

```dart
SupabaseService.initialize();   // called from main()
SupabaseService.client;         // shared SupabaseClient
```

### Environment (`lib/core/api/env.dart`)

Reads the following via `String.fromEnvironment`:

| Name | Purpose |
|---|---|
| `SUPABASE_URL` | Supabase project URL — REQUIRED |
| `SUPABASE_ANON_KEY` | Public anon key — REQUIRED |
| `AUTH_REDIRECT_URL` | Defaults to `lively://login-callback/` |
| `SKIP_ONBOARDING` | Debug shortcut into shell |
| `PREVIEW_MODE` | Auto-approves review / host flows after 4 s |

**Env storage:** `.env.json` at project root (gitignored). Example template lives at `.env.json.example`. `SUPABASE_SERVICE_ROLE_KEY` is only ever needed for admin scripts and must live in a separate gitignored `.env` — never in `.env.json`, never in chat, never in git.

### Storage buckets

| Bucket | Public? | Path convention |
|---|---|---|
| `avatars` | public | `<uid>/*.jpg` |
| `event_covers` | public | `<uid>/<epoch>_cover.<ext>` |
| `event_gallery` | public | `<uid>/*` |
| `verifications` | private | `<uid>/*` |
| `message_attachments` | private | `<uid>/*` |

RLS: policies enforce `(storage.foldername(name))[1] = auth.uid()` on write. See `supabase/migrations/0003_storage_policies.sql` + `0004_storage_policies_v2.sql`.

### Migrations (in order)

| File | Purpose |
|---|---|
| `0001_init.sql` | Full schema (28 tables + enums) |
| `0002_storage.sql` | Bucket creation |
| `0003_storage_policies.sql` | Initial storage RLS |
| `0004_storage_policies_v2.sql` | Self-contained RLS: only `bucket_id`, `auth.uid()`, path parsing (no cross-table refs) |
| `0005_fix_recursion.sql` | `SECURITY DEFINER` helpers to break `channel_members` RLS recursion |
| `0006_events_seed.sql` | 12 seeded events + denormalised `host_display_*` columns + `tg_recalc_event_rsvp_counts` trigger; idempotent (`delete where host_id is null`) |
| `0007_gender_pricing.sql` | Adds `price_rupees_women` + `price_rupees_men` + non-negative checks + backfill from `price_rupees`. **Must end with `notify pgrst, 'reload schema';`** if applied via SQL editor. |
| `0008_fix_rsvp_recursion.sql` | Fixes 42P17 infinite recursion in `rsvps event peers read`. New `my_active_rsvp_event_ids()` SECURITY DEFINER helper; the policy uses it instead of a self-referential subquery. Same pattern 0005 used for `channel_members`. |
| `0009_event_chats.sql` | Trigger `tg_events_ensure_chat_channel` (creates the `event_chat` channels row + adds host as member on event insert). Trigger `tg_rsvps_sync_channel_member` (on RSVP insert/update: upserts membership; on cancel: sets `left_at`). Backfills channels + members for existing events and active RSVPs. Adds `messages` to the `supabase_realtime` publication so `client.from('messages').stream(...)` delivers INSERTs. Idempotent. |
| `0010_chat_unread.sql` | `my_unread_counts()` RPC returns `(event_id, unread_count)` for each channel the caller is a member of. Counts only `created_at > channel_members.last_read_at` and excludes the caller's own sends. One round-trip drives every unread badge. |

### Table schemas referenced by client code

**`profiles`** (see `profile_repository.dart`, `you_screen.dart`, hydration)
```
id (uuid, PK, FK auth.users), name, date_of_birth, gender,
city_id, locality_id, bio, activities uuid[],
height_cm, traits text[], company, profession, relationship_status,
musicians jsonb, movies jsonb, dishes jsonb, socials jsonb,
review_status enum('draft','submitted','under_review','approved','rejected'),
host_status  enum('none','id_submitted','under_review','approved','rejected'),
is_admin bool, privacy_blurred bool, metadata jsonb,
created_at, updated_at, deleted_at, approved_at, rejected_at, rejection_reason
```

**`events`** (see `supabase_event_repository.dart`)
```
id, host_id → profiles.id, title, description,
category_id → activity_categories.id,
gender_policy_code → event_gender_policies.code,
city_id, locality_id, venue_name, venue_address, venue_lat, venue_lng,
start_time timestamptz, duration_minutes (30–600),
total_spots (4–50),
price_rupees, price_rupees_women, price_rupees_men,   -- last two from 0007
is_published, published_at, cancelled_at, cancellation_reason,
metadata jsonb, created_at, updated_at, deleted_at
-- 0006 adds denormalised columns:
neighbourhood, cover_image_url,
host_display_name, host_display_photo_url, host_display_verified,
host_display_bio, host_display_events_hosted, host_display_rating,
male_rsvp_count, female_rsvp_count, attendee_avatar_urls text[]
```

**`rsvps`**
```
id, event_id, profile_id, created_at, cancelled_at, attended
UNIQUE (event_id, profile_id)
```

**`activity_categories`** — lookup with `code` (art, sports, food_and_drinks, outdoors, music, board_games, clubbing, wellness, movies).

**`cities`** — lookup, `code` = `bengaluru` for launch.

**`localities`** — 14 seeded Bangalore neighbourhoods.

**`event_gender_policies`** — codes: `everyone`, `women_only`, `men_only`.

**`attachments`** — polymorphic photo store (owner_type + owner_id + bucket + path).

**Others in `0001_init.sql`** (not yet wired into UI): `waves`, `channels`, `channel_members`, `messages`, `message_reactions`, `reports`, `notifications`, `push_tokens`, `notification_preferences`, `host_applications`, `host_status_history`, `activity_log`, `feature_flags`, `feature_flag_overrides`, `idempotency_keys`, `report_kinds`, `notification_types`.

---

## 9. Native / build config

- **Android manifest** (`android/app/src/main/AndroidManifest.xml`): permissions `INTERNET`, `CAMERA`, `READ_MEDIA_IMAGES`, `READ_EXTERNAL_STORAGE (≤SDK32)`. Intent filter for `lively://login-callback` deep link.
- **Gradle** (`android/app/build.gradle.kts`): `applicationId = "com.lively.lively"`, JVM 17, currently signed with **debug keystore** even for `release` (TODO: real signing config before Play Store).
- **`.gitignore` protects**: `.env`, `.env.json`, `*.jks`, `*.keystore`, `google-services.json`, `GoogleService-Info.plist`.
- **Web docs** (unrelated to Flutter build): `docs/index.html`, `docs/privacy.html`, `docs/terms.html`.

---

## 10. Known bugs / incomplete features

**OPEN — mid-investigation:**
- **Chats tab renders as blank white above the nav bar** (no title, no sub-tabs, no rows, no empty state) after the 2026-09-02 chat overhaul. Cold-launch logcat shows no Flutter exception. A diagnostic build is currently deployed with `chatInboxWatcherProvider` watches removed from both `MainShell` and `_EventChatsTab`, unread hard-coded to `0`, and `print('[Lively] _EventChatsTab.build …')` breadcrumbs added — awaiting the user's logcat while tapping the Chats tab. Prime suspect: the sync body of `chatInboxWatcherProvider` (creates a Supabase realtime channel + `.subscribe()`). Once confirmed, the fix is to wrap the subscription in `try/catch` and defer it via `Future.microtask` / post-frame callback, then restore the actual `totalUnreadCountProvider` / `unreadCountForEventProvider` reads. See the 2026-09-02 session-log entry for the exact rollback details.

**OPEN — known & unstarted:**
1. **`pubspec.yaml` description says "Lively — dating app"** — stale, should be "events / meetups app".
2. **People screen uses mock names.** `lib/features/people/screens/people_screen.dart` — not yet reading real attendees.
3. **Notifications screen is a placeholder.** No push tokens registered; `push_tokens` and `notification_preferences` tables unused.
4. **Legacy onboarding uploader.** `lib/features/onboarding/repositories/supabase_onboarding_repository.dart` references a bucket named `profile-photos` that does not exist (real bucket is `avatars`). Confirm no code path still reaches it before deleting.
5. **`main_shell.dart` uses deprecated `Color.withOpacity`.** Should migrate to `.withValues(alpha: …)`.
6. **114 analyzer info-level lints** (mostly `prefer_const_constructors`, `unnecessary_underscores`). Not blocking.
7. **Release APK signed with debug keystore.** Not shippable to Play Store — needs a real signing config.
8. **Event insert requires denormalised host columns** (`host_display_*`) to already be populated by the 0006 trigger — new hosts need their profile fully hydrated before publishing works cleanly. No trigger auto-populates them on user-created events, so the host card on Home falls back to "Lively" / empty avatar until a follow-up trigger is written.
9. **Build command must always include `--dart-define-from-file=.env.json`.** Without it, `main()` throws `Bad state: Missing SUPABASE_URL / SUPABASE_ANON_KEY` and the splash screen hangs.
10. **RSVP / events feed is not realtime.** No `.stream()` subscription — feed refresh is triggered by `refresh()` on Home mount, `AppLifecycleState.resumed`, tab-switch to Home, pull-to-refresh, and post-publish. But another user's just-published event doesn't appear until one of those triggers fires.
11. **Every migration authored in a session must be applied manually** via the Supabase SQL editor and end with `notify pgrst, 'reload schema';`. There is no CI/migration pipeline yet. This applied to 0007 and now to 0008 / 0009 / 0010.

**RESOLVED since bootstrap (2026-08-28):**
- ~~Chats in-memory only~~ → **RESOLVED 2026-09-02** by migration 0009 + new `SupabaseChatRepository` + `ChatController` (`AutoDisposeAsyncNotifierProvider.family`) using `client.from('messages').stream(...)` for realtime + optimistic sends + retry + `client_temp_id` echo dedup.
- ~~`0007_gender_pricing.sql` needs manual apply~~ → user applied it 2026-08-28.
- ~~RLS infinite recursion on `rsvps` (42P17) blocking `fetchEvents()`~~ → **RESOLVED 2026-09-02** by migration 0008 via `my_active_rsvp_event_ids()` SECURITY DEFINER helper. This was the actual root cause of the "publish → event doesn't appear on Home" symptom.

---

## 11. Handy commands

```bash
# Codegen after touching a freezed / json_serializable model
dart run build_runner build --delete-conflicting-outputs

# Run on connected device
flutter run --dart-define-from-file=.env.json

# Build a debug APK for sideloading
flutter build apk --debug --dart-define-from-file=.env.json

# Install to OnePlus 11R (alpha device)
adb -s 538a393e install -r build/app/outputs/flutter-apk/app-debug.apk

# Analyze
flutter analyze
```

---

## SESSION LOG

> Append-only. New entries at the TOP. Never delete prior entries. Every session must add its own entry before finishing.

### 2026-09-02 — RSVP RLS recursion fix, Home refresh triggers, full chat system on Supabase (persistence + realtime + status + member count + unread badges); Chats-tab blank-white regression under investigation
**What changed**

**Migrations added (each ends with `notify pgrst, 'reload schema'`):**
- `supabase/migrations/0008_fix_rsvp_recursion.sql` — replaces the self-referential `rsvps event peers read` policy from 0001 with a `SECURITY DEFINER` helper `my_active_rsvp_event_ids()`. Root cause: `fetchEvents()` also queries `rsvps` (to compute `Event.isGoing`), which tripped 42P17 infinite recursion and caused a silent `_refresh()` failure → Home feed empty even for the host of the just-inserted rows.
- `supabase/migrations/0009_event_chats.sql` — trigger `tg_events_ensure_chat_channel` (creates the `channels` row + adds host as `channel_member` on event insert); trigger `tg_rsvps_sync_channel_member` (on RSVP insert/update, upserts membership; on cancel, sets `left_at`); backfills all existing events + active RSVPs; **adds `messages` to the `supabase_realtime` publication**. All idempotent.
- `supabase/migrations/0010_chat_unread.sql` — `my_unread_counts()` RPC returns `(event_id, unread_count)` per active membership. Counts only `created_at > channel_members.last_read_at` and excludes the caller's own sends. One round-trip; no client-side aggregation.

**Client — Home feed:**
- `lib/features/home/screens/home_screen.dart` — `HomeScreen` is now `ConsumerStatefulWidget` with `WidgetsBindingObserver`. Refreshes on `initState` (post-frame), on `AppLifecycleState.resumed`, and `RefreshIndicator.onRefresh` now actually calls `refresh()` (was a 600 ms `Future.delayed` stub with a `// In prod, this would refetch` comment).
- `lib/core/router/main_shell.dart` — `StatelessWidget` → `ConsumerWidget`; when the user switches TO the Home tab (index 0), triggers `refresh()`. (See note below about a diagnostic rollback in the chat-badge additions.)
- `lib/features/profile/screens/create_event_screen.dart` — after a successful publish, resets `homeFilterProvider = 'all'` and `dateFilterProvider = anytime` so a newly-published event whose category doesn't match the user's active pill is still visible.
- `lib/features/home/providers/event_providers.dart` — removed the in-memory `joinChat` / `leaveChat` bookkeeping calls (0009 triggers own membership now).

**Client — Chats (persistence + realtime + status + member count):**
- `lib/features/chats/models/chat_message.dart` — added `id`, `senderId`, `status` (`sending`/`sent`/`failed`), `clientTempId`, `copyWith`.
- `lib/features/chats/repositories/supabase_chat_repository.dart` — NEW. `ensureChannelForEvent`, `fetchProfileNames`, `fetchChannelMemberNames` (name cache — `.stream()` doesn't do joins), `streamMessages` (uses `client.from('messages').stream(primaryKey:['id']).eq('channel_id',…).order('created_at')` — the higher-level self-healing stream API), `sendMessage` (writes `client_temp_id` into `metadata` for echo dedup), `markChannelRead`, `fetchUnreadCounts` (RPC), `subscribeToAllInboxInserts`.
- `lib/features/chats/providers/event_chat_provider.dart` — rewritten as `AutoDisposeAsyncNotifierProvider.family<ChatController, List<ChatMessage>, String>`. Warms name cache → opens `.stream()` → completes future on first emission. Every emission re-merges server rows + optimistic pending overlay (server wins on `client_temp_id` match). Adds `markRead()`, `unreadCountsProvider` (FutureProvider<Map<eventId,int>>), `unreadCountForEventProvider`, `totalUnreadCountProvider`, `chatInboxWatcherProvider` (global realtime; invalidates unread on any inbound message), and `chatPreviewProvider` (per-row last-message query for chats list).
- `lib/features/chats/screens/event_chat_screen.dart` — new provider. Header (cover + title + `N members`) is fully tap-through to event detail. **WhatsApp-style scroll**: jump to bottom on first data load, animate on subsequent additions ONLY if user is near bottom (within 120 px of `maxScrollExtent`); reading history is never yanked. Per-message status: 12 px `CircularProgressIndicator` (sending) → `Icons.check` (sent) → `Icons.error_outline` + tappable "Retry" (failed). Mark-read on mount + on dispose.
- `lib/features/chats/screens/chats_screen.dart` — preview switched to `chatPreviewProvider` (AsyncValue-aware). Filter includes both `isGoing` AND `hostId == myId` (hosts are auto-added to their own event's chat via 0009 trigger and should see it in the list). Added `_UnreadBadge` widget for per-row badges. **DIAGNOSTIC ROLLBACK IN PLACE — see Known Issues below.**

**In-session ops:**
- Ran 0008 SQL in Supabase editor. Confirmed via `select policyname, cmd, qual from pg_policies where tablename='rsvps'` — new policy now references `my_active_rsvp_event_ids()` (SECURITY DEFINER), no self-recursion. Feed unblocked immediately.
- Ran 0009 SQL in Supabase editor ("Success. No rows returned" — expected). Chat persistence confirmed working: send → survives kill/reopen → cross-user sees history.
- Ran 0010 SQL in Supabase editor ("Success. No rows returned"). Unread RPC live.

**Bugs resolved this session:**
- RLS 42P17 on rsvps → feed empty for everyone (was the ROOT CAUSE of the "publish → don't see it on Home" symptom — filter mismatch was a secondary concern). Fixed by 0008.
- Home pull-to-refresh no-op → real refetch.
- Home category-pill hiding a just-published off-category event → auto-reset to 'all' on publish.
- Chats vanish on app kill → chats fully persisted via `messages` table (0009 + new repo).
- Group chat header inert → tap-through to event detail; member count shown.
- No status indication on send → sending/sent/failed with retry.
- New RSVPer couldn't see prior chat history → `messages channel read` RLS is `channel_id`-scoped, not time-scoped; the 0009 trigger adds membership on RSVP → full history immediately visible.

**KNOWN ISSUE (STILL OPEN, MID-INVESTIGATION):**
- **Chats tab renders as blank white above the nav bar** (no title, no sub-tabs, no rows, no empty state). Logcat on cold launch showed no Flutter exception. Diagnostic build currently deployed (installed to device `538a393e`):
  - `chatInboxWatcherProvider` watch removed from BOTH `MainShell` and `_EventChatsTab` (was the top suspect — sync body creates a Supabase realtime channel + subscribes; if that path throws or hangs it could poison the widget tree).
  - `unread` in both `MainShell._NavIconWithBadge` and per-row chats trailing hard-coded to `0`.
  - Debug prints added to `_EventChatsTab.build`: `[Lively] _EventChatsTab.build starting` and `[Lively] _EventChatsTab.build chats.length=N`.
  - Awaiting the user's logcat while tapping the Chats tab. Three-way outcome map is documented in the session transcript.
- **Once the culprit is confirmed**, re-add the inbox watcher wrapped in `try/catch` and deferred to a `Future.microtask`/post-frame callback so any realtime setup failure can't take down the UI, and restore the actual `totalUnreadCountProvider` / `unreadCountForEventProvider` reads.

**What's next (unchanged priority order):**
- Land the Chats-tab fix, remove the diagnostic prints, restore unread badges.
- Real signing config for release APK (still debug-signed).
- Firebase App Distribution wiring.
- Replace `people_screen.dart` mock names with real attendees.
- Register push tokens + build real `notifications_screen`.
- Delete `supabase_onboarding_repository.dart` (legacy `profile-photos` bucket that doesn't exist).
- Update `pubspec.yaml` description from "dating app" to "events app".
- Realtime subscription on the events feed (currently manual refresh).

**Updated known-issues delta vs the 2026-08-28 entry:**
- ~~Bug #2 (chats in-memory only)~~ → **RESOLVED** by 0009 + new chat repo/provider.
- ~~Bug #9 (0007 must be applied manually)~~ → user applied it via SQL editor. Same pattern applies to 0008 / 0009 / 0010; document that any migration authored in a session needs manual apply until the CI/migration pipeline is wired.
- Bug #4 (notifications placeholder), Bug #3 (people_screen mock), Bug #5 (legacy onboarding uploader), Bug #6 (`withOpacity` deprecation), Bug #8 (debug keystore signing), Bug #10 (host_display_* not backfilled by trigger for user-created events), Bug #12 (feed not realtime) — still open.

**Files modified**
- NEW: `supabase/migrations/0008_fix_rsvp_recursion.sql`, `supabase/migrations/0009_event_chats.sql`, `supabase/migrations/0010_chat_unread.sql`, `lib/features/chats/repositories/supabase_chat_repository.dart`.
- REWRITTEN: `lib/features/chats/providers/event_chat_provider.dart`, `lib/features/chats/screens/event_chat_screen.dart`.
- EDITED: `lib/features/chats/models/chat_message.dart`, `lib/features/chats/screens/chats_screen.dart`, `lib/features/home/screens/home_screen.dart`, `lib/features/home/providers/event_providers.dart`, `lib/features/profile/screens/create_event_screen.dart`, `lib/core/router/main_shell.dart`.

**Device / build**
- Device: OnePlus 11R `538a393e`. Every rebuild used `flutter build apk --debug --dart-define-from-file=.env.json` then `adb -s 538a393e install -r build/app/outputs/flutter-apk/app-debug.apk`. Missing `--dart-define-from-file` is still the #1 splash-hang trap.

---

### 2026-08-28 — Bug fixes 7 & 8 + CLAUDE.md bootstrap
**What changed**
- **Bug 7 (Create Event → Supabase)** implemented end-to-end. Cover uploads to `event_covers/<uid>/<epoch>_cover.<ext>` (RLS-safe path convention), category id resolved via `activity_categories.code`, city id resolved via `cities.code = 'bengaluru'`, event row inserted with per-gender pricing + `select().single()` + category join. On `PostgrestException` the orphaned storage object is removed.
- **Bug 8 (persist dummy events)** verified: `0006_events_seed.sql` already seeds 12 events, and the Home feed already reads via `SupabaseEventRepository.fetchEvents()`. No code change needed — this bug was already implicitly fixed by the earlier repo swap.
- **Blank cover in Preview** fixed. `EventCard._CoverImage` now branches on `!url.startsWith('http')` and renders local files with `Image.file(File(url))` so the create-event Preview step shows the picked cover instead of a blank tile.
- Bootstrapped this `CLAUDE.md` as the project's running memory.

**Files modified**
- `lib/features/home/repositories/supabase_event_repository.dart` — `createEvent(...)` + `_categoryToCode` helper.
- `lib/features/profile/screens/create_event_screen.dart` — `_publishing` guard + async `_publish()` with modal loader, calls repo then `eventsProvider.refresh()`, error SnackBar.
- `lib/features/home/widgets/event_card.dart` — local-file fallback in `_CoverImage`.
- `CLAUDE.md` — new.

**In-session ops (no code change)**
- Rebuilt APK **with** `--dart-define-from-file=.env.json` (previous build missed the flag and hung on splash).
- Provided `0007_gender_pricing.sql` for manual application via Supabase SQL editor, with `notify pgrst, 'reload schema';` appended to force PostgREST cache reload.
- Provided host-approval SQL scoped to `golively.app@gmail.com` (the actual login email — user corrected from an earlier guess).

**What's next**
- Real signing config for release APK (currently debug-signed).
- Wire chats to Supabase (`channels` / `channel_members` / `messages` tables exist, no repo yet).
- Replace `people_screen.dart` mock names with real attendees.
- Register push tokens + build a real `notifications_screen`.
- Delete or migrate `supabase_onboarding_repository.dart` — references a non-existent `profile-photos` bucket.
- Update `pubspec.yaml` description from "dating app" to "events app".
- Add realtime subscription to the events feed instead of manual refresh.

**Known issues (still open)**
- Any Supabase project provisioned before 0007 needs the migration applied manually via SQL editor + PostgREST schema reload.
- Analyzer reports ~113 info-level lints (not blocking).
- `main_shell.dart` uses deprecated `Color.withOpacity`.
