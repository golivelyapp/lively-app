-- ============================================================================
-- Fix infinite recursion in the rsvps RLS.
--
-- The original "rsvps event peers read" policy referenced `rsvps` in its
-- own USING subquery. Postgres re-evaluates RLS on that subquery, which
-- re-enters the same policy, triggering 42P17. Same pattern that 0005
-- fixed for channel_members — apply it here.
-- ============================================================================

create or replace function my_active_rsvp_event_ids() returns setof uuid
language sql stable security definer set search_path = public
as $$
  select event_id from rsvps
  where profile_id = auth.uid() and cancelled_at is null;
$$;

drop policy if exists "rsvps event peers read" on rsvps;
create policy "rsvps event peers read" on rsvps for select using (
  is_approved() and event_id in (select my_active_rsvp_event_ids())
);

-- Force PostgREST to re-scan.
notify pgrst, 'reload schema';
