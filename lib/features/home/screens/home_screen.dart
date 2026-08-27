import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/route_paths.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/locality_picker_sheet.dart';
import '../../notifications/notifications_screen.dart';
import '../../onboarding/providers/onboarding_draft_controller.dart';
import '../../profile/models/host_verification_status.dart';
import '../../profile/providers/host_verification_provider.dart';
import '../models/event.dart';
import '../providers/event_providers.dart';
import '../widgets/event_card.dart';
import '../widgets/filter_chip_row.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<Event> events = ref.watch(filteredEventsProvider);
    final String filter = ref.watch(homeFilterProvider);
    final bool isHost = ref.watch(isVerifiedHostProvider);
    final List<Event> upcomingRsvps = ref.watch(upcomingRsvpsProvider);
    final bool showWomenOnly = ref.watch(showWomenOnlyFilterProvider);
    final bool womenOnlyActive = ref.watch(womenOnlyFilterProvider);
    final DateFilter activeDate = ref.watch(dateFilterProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: <Widget>[
            const _LocationBar(),
            const SizedBox(height: AppSpacing.sm),
            FilterChipRow(
              selected: filter,
              categories: ref.watch(homeCategoryPillsProvider),
              onSelected: (v) => ref.read(homeFilterProvider.notifier).state = v,
            ),
            const SizedBox(height: AppSpacing.sm),
            _DateFilterRow(
              active: activeDate,
              onSelected: (d) => ref.read(dateFilterProvider.notifier).state = d,
            ),
            if (showWomenOnly) ...<Widget>[
              const SizedBox(height: AppSpacing.sm),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: _WomenOnlyChip(
                    active: womenOnlyActive,
                    onTap: () => ref
                        .read(womenOnlyFilterProvider.notifier)
                        .state = !womenOnlyActive,
                  ),
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.md),
            Expanded(
              child: RefreshIndicator(
                color: AppColors.magenta,
                onRefresh: () async {
                  await Future<void>.delayed(const Duration(milliseconds: 600));
                  // In prod, this would refetch the feed.
                },
                child: events.isEmpty && upcomingRsvps.isEmpty
                    ? _EmptyState()
                    : ListView(
                        physics: const AlwaysScrollableScrollPhysics(
                          parent: BouncingScrollPhysics(),
                        ),
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.md,
                          0,
                          AppSpacing.md,
                          AppSpacing.md,
                        ),
                        children: <Widget>[
                          if (upcomingRsvps.isNotEmpty)
                            _RsvpCarousel(events: upcomingRsvps),
                          if (events.isEmpty)
                            const Padding(
                              padding: EdgeInsets.all(AppSpacing.xl),
                              child: _InlineEmpty(),
                            )
                          else
                            for (final Event event in events)
                              EventCard(
                                event: event,
                                onTap: () => context.push(
                                  RoutePaths.eventDetail(event.id),
                                ),
                              ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
      // Always show the + FAB so every user has a discoverable path
      // to hosting. Verified hosts go straight to the Create Event
      // flow; anyone else is nudged into the Apply-to-host flow with
      // a quick sheet explaining what happens next.
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.magenta,
        onPressed: () => _handleFabTap(context, ref, isHost),
        child: const Icon(Icons.add, color: AppColors.textOnDark),
      ),
    );
  }

  Future<void> _handleFabTap(BuildContext context, WidgetRef ref, bool isHost) async {
    if (isHost) {
      context.push(RoutePaths.createEvent);
      return;
    }
    final HostVerificationStatus status =
        ref.read(hostVerificationStatusProvider);
    // If the user's application is already in flight, show that instead
    // of restarting the flow.
    if (status == HostVerificationStatus.underReview) {
      showModalBottomSheet<void>(
        context: context,
        builder: (_) => const _HostPendingSheet(),
      );
      return;
    }
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusLg)),
      ),
      builder: (sheetCtx) => _BecomeHostSheet(
        onApply: () {
          Navigator.of(sheetCtx).pop();
          context.push(RoutePaths.hostVerification);
        },
      ),
    );
  }
}

class _BecomeHostSheet extends StatelessWidget {
  const _BecomeHostSheet({required this.onApply});
  final VoidCallback onApply;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const SizedBox(height: 8),
            const Icon(Icons.stars_outlined, size: 40, color: AppColors.magenta),
            const SizedBox(height: AppSpacing.sm),
            Text('Become a host to create events', textAlign: TextAlign.center, style: AppTextStyles.headline),
            const SizedBox(height: AppSpacing.sm),
            Text(
              "Only verified hosts can create events on Lively — we do a quick ID check to keep the room safe. It usually takes under 24 hours.",
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySecondary,
            ),
            const SizedBox(height: AppSpacing.lg),
            ElevatedButton(
              onPressed: onApply,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.magenta,
                foregroundColor: AppColors.textOnDark,
                minimumSize: const Size.fromHeight(48),
              ),
              child: const Text('Apply to host'),
            ),
            const SizedBox(height: AppSpacing.xs),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Not now', style: AppTextStyles.body.copyWith(color: AppColors.textSecondary)),
            ),
          ],
        ),
      ),
    );
  }
}

class _HostPendingSheet extends StatelessWidget {
  const _HostPendingSheet();
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(Icons.hourglass_top, size: 40, color: AppColors.magenta),
            const SizedBox(height: AppSpacing.sm),
            Text('Host application under review', style: AppTextStyles.headline),
            const SizedBox(height: AppSpacing.sm),
            Text(
              "We're verifying your ID. You'll get a notification once you're approved — usually under 24 hours.",
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySecondary,
            ),
            const SizedBox(height: AppSpacing.md),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.magenta,
                foregroundColor: AppColors.textOnDark,
                minimumSize: const Size.fromHeight(48),
              ),
              child: const Text('Got it'),
            ),
          ],
        ),
      ),
    );
  }
}

class _LocationBar extends ConsumerWidget {
  const _LocationBar();

  Future<void> _openPicker(BuildContext context, WidgetRef ref, String current) async {
    // The "Use current location" option in the sheet returns whatever the
    // user chose during onboarding (or the last detected value), so it
    // acts as a "reset to my detected locality" affordance.
    final String? detected =
        ref.read(onboardingDraftProvider).location ?? current;
    final String? picked = await showLocalityPickerSheet(
      context,
      selected: current,
      detectedLocality: detected,
    );
    if (picked != null) {
      ref.read(locationLabelProvider.notifier).state = picked;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final String location = ref.watch(locationLabelProvider);
    return SizedBox(
      height: 48,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        child: Row(
          children: <Widget>[
            Expanded(
              child: InkWell(
                borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                onTap: () => _openPicker(context, ref, location),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      const Icon(Icons.place_outlined, size: 20, color: AppColors.textPrimary),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          location,
                          style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const Icon(Icons.keyboard_arrow_down, size: 18, color: AppColors.textSecondary),
                    ],
                  ),
                ),
              ),
            ),
            _BellButton(
              hasBadge: true,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const NotificationsScreen(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Second row of chips beneath the interest pills — narrower & shorter
/// so it reads as a sub-filter rather than a peer of the category pills.
class _DateFilterRow extends StatelessWidget {
  const _DateFilterRow({required this.active, required this.onSelected});
  final DateFilter active;
  final ValueChanged<DateFilter> onSelected;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 32,
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        children: <Widget>[
          for (final DateFilter d in DateFilter.values)
            Padding(
              padding: const EdgeInsets.only(right: 6),
              child: _DatePill(
                label: d.label,
                selected: active == d,
                onTap: () => onSelected(d),
              ),
            ),
        ],
      ),
    );
  }
}

class _DatePill extends StatelessWidget {
  const _DatePill({required this.label, required this.selected, required this.onTap});
  final String label;
  final bool selected;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: selected ? AppColors.pinkTint : Colors.transparent,
          border: Border.all(
            color: selected ? AppColors.magenta : AppColors.border,
          ),
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: selected ? AppColors.magenta : AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _BellButton extends StatelessWidget {
  const _BellButton({required this.hasBadge, required this.onTap});
  final bool hasBadge;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 44,
        height: 44,
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            const Icon(Icons.notifications_none_outlined, color: AppColors.textPrimary),
            if (hasBadge)
              const Positioned(
                top: 12,
                right: 12,
                child: SizedBox(
                  width: 8,
                  height: 8,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: AppColors.magenta,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _WomenOnlyChip extends StatelessWidget {
  const _WomenOnlyChip({required this.active, required this.onTap});
  final bool active;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 28,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: active ? AppColors.pinkTint : Colors.transparent,
          border: Border.all(
            color: active ? AppColors.magenta : AppColors.border,
          ),
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.female_outlined,
              size: 14,
              color: active ? AppColors.magenta : AppColors.textSecondary,
            ),
            const SizedBox(width: 4),
            Text(
              'Women only',
              style: AppTextStyles.caption.copyWith(
                color: active ? AppColors.magenta : AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RsvpCarousel extends StatelessWidget {
  const _RsvpCarousel({required this.events});
  final List<Event> events;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: SizedBox(
        height: 100,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          itemCount: events.length,
          separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
          itemBuilder: (context, i) => _RsvpCard(event: events[i]),
        ),
      ),
    );
  }
}

class _RsvpCard extends StatelessWidget {
  const _RsvpCard({required this.event});
  final Event event;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(RoutePaths.eventDetail(event.id)),
      child: Container(
        width: 280,
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: <Widget>[
            ClipRRect(
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              child: SizedBox(
                width: 72,
                height: 72,
                child: event.coverImageUrl.isEmpty
                    ? const ColoredBox(color: AppColors.surface)
                    : CachedNetworkImage(imageUrl: event.coverImageUrl, fit: BoxFit.cover),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.pinkTint,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                    ),
                    child: Text(
                      formatEventCountdown(event.startTime),
                      style: AppTextStyles.caption.copyWith(color: AppColors.magenta, fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    event.title,
                    style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(event.neighbourhood, style: AppTextStyles.caption),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
      children: const <Widget>[SizedBox(height: 200), _InlineEmpty()],
    );
  }
}

class _InlineEmpty extends StatelessWidget {
  const _InlineEmpty();
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(Icons.event_available_outlined, size: 48, color: AppColors.textSecondary),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'No events here yet.\nCheck back soon or try a different interest.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySecondary,
            ),
          ],
        ),
      ),
    );
  }
}
