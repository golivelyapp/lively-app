-- ============================================================================
-- Bug 5: per-gender pricing on events.
--
-- `price_rupees` stays as the legacy single price (still displayed as a
-- summary and used as the max/fallback). The two new columns allow hosts
-- to charge different amounts (or waive entirely) by attendee gender.
-- Both columns are nullable; a NULL means "same as price_rupees" and a
-- value of 0 means "free for that gender".
-- ============================================================================

alter table events
  add column if not exists price_rupees_women integer,
  add column if not exists price_rupees_men   integer;

-- Optional non-negative check to catch bad host input at the DB boundary.
alter table events
  drop constraint if exists events_price_women_nonneg,
  drop constraint if exists events_price_men_nonneg;

alter table events
  add constraint events_price_women_nonneg check (price_rupees_women is null or price_rupees_women >= 0),
  add constraint events_price_men_nonneg   check (price_rupees_men   is null or price_rupees_men   >= 0);

-- Backfill existing rows: mirror the current single price to both genders.
update events
  set price_rupees_women = price_rupees
where price_rupees_women is null;

update events
  set price_rupees_men = price_rupees
where price_rupees_men is null;
