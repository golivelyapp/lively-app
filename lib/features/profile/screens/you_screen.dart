import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/route_paths.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_gradients.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/photo_image_provider.dart';
import '../../../core/widgets/gradient_button.dart';
import '../../auth/providers/auth_state_provider.dart';
import '../../home/providers/event_providers.dart';
import '../../onboarding/models/onboarding_draft.dart';
import '../../onboarding/models/onboarding_enums.dart';
import '../../onboarding/providers/onboarding_draft_controller.dart';
import '../models/host_verification_status.dart';
import '../providers/host_verification_provider.dart';

class YouScreen extends ConsumerWidget {
  const YouScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draft = ref.watch(onboardingDraftProvider);
    final hostStatus = ref.watch(hostVerificationStatusProvider);
    final events = ref.watch(eventsProvider);
    final int attendedPast = events.where((e) => e.isGoing && e.isPast).length;
    final int totalRsvpd = events.where((e) => e.isGoing).length;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: ListView(
          physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.md, AppSpacing.md, AppSpacing.md),
          children: <Widget>[
            _ProfileHeader(draft: draft),
            const SizedBox(height: AppSpacing.md),
            _ReliabilityBadge(attended: attendedPast, total: totalRsvpd),
            const SizedBox(height: AppSpacing.md),
            _HostCard(status: hostStatus),
            const SizedBox(height: AppSpacing.lg),
            _MoreAboutYouCard(draft: draft),
            const SizedBox(height: AppSpacing.md),
            _YourFavouritesCard(draft: draft),
            const SizedBox(height: AppSpacing.md),
            _YourSocialsCard(draft: draft),
            const SizedBox(height: AppSpacing.lg),
            Text('Settings', style: AppTextStyles.headline),
            const SizedBox(height: AppSpacing.xs),
            _SettingsGroup(
              tiles: <_SettingItem>[
                _SettingItem(
                  icon: Icons.notifications_none,
                  label: 'Notifications',
                  onTap: () => _openStubSettings(context, 'Notifications',
                      'Choose which reminders push to your phone: RSVP alerts, chat mentions, new events near you.'),
                ),
                _SettingItem(
                  icon: Icons.lock_outline,
                  label: 'Privacy',
                  onTap: () => _openStubSettings(context, 'Privacy',
                      'Control who sees your profile: visible to everyone, blurred to non-attendees, or private until you accept.'),
                ),
                _SettingItem(
                  icon: Icons.place_outlined,
                  label: 'Location',
                  onTap: () => _openStubSettings(context, 'Location',
                      'Set the neighbourhood we use to surface nearby events. Also toggles precise location for driving directions.'),
                ),
                _SettingItem(
                  icon: Icons.verified_user_outlined,
                  label: 'Verification status',
                  onTap: () => _openStubSettings(context, 'Verification status',
                      "You're verified. Your ID selfie matched your profile photo — this is how we keep the room real."),
                ),
                _SettingItem(
                  icon: Icons.help_outline,
                  label: 'Help & Support',
                  onTap: () => _openStubSettings(context, 'Help & Support',
                      "Reach us anytime at support@lively.app. We usually respond within a business day."),
                ),
                _SettingItem(
                  icon: Icons.info_outline,
                  label: 'About Lively',
                  onTap: () => _openStubSettings(context, 'About Lively',
                      'Lively is a members-only community for discovering and joining real-world activities in Bangalore. v0.1.0'),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            _LogoutTile(),
          ],
        ),
      ),
    );
  }
}

class _ProfileHeader extends ConsumerWidget {
  const _ProfileHeader({required this.draft});
  final OnboardingDraft draft;

  Future<void> _editName(BuildContext context, WidgetRef ref) async {
    final TextEditingController controller = TextEditingController(text: draft.name ?? '');
    final String? newName = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit your name'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Your name'),
          textCapitalization: TextCapitalization.words,
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(controller.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (newName != null && newName.isNotEmpty) {
      ref.read(onboardingDraftProvider.notifier).updateBasics(name: newName);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: <Widget>[
        Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.bottomRight,
          children: <Widget>[
            CircleAvatar(
              radius: 48,
              backgroundColor: AppColors.surface,
              backgroundImage: photoImageProvider(draft.profilePhotoPath),
              child: photoImageProvider(draft.profilePhotoPath) == null
                  ? const Icon(Icons.person, size: 40, color: AppColors.textSecondary)
                  : null,
            ),
            const Positioned(
              right: 0,
              bottom: 0,
              child: DecoratedBox(
                decoration: BoxDecoration(color: AppColors.background, shape: BoxShape.circle),
                child: Padding(
                  padding: EdgeInsets.all(2),
                  child: Icon(Icons.verified, color: AppColors.gold, size: 24),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(draft.name ?? 'You', style: AppTextStyles.headline),
            const SizedBox(width: 4),
            IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              icon: const Icon(Icons.edit_outlined, size: 18, color: AppColors.textSecondary),
              onPressed: () => _editName(context, ref),
            ),
          ],
        ),
        if (draft.bio != null && draft.bio!.isNotEmpty) ...<Widget>[
          const SizedBox(height: 4),
          Text(
            draft.bio!,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.bodySecondary,
          ),
        ],
        const SizedBox(height: 6),
        const Text('12 events attended · 8 connections', style: AppTextStyles.bodySecondary),
        if (draft.activities.isNotEmpty) ...<Widget>[
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            height: 28,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: draft.activities.length,
              separatorBuilder: (_, __) => const SizedBox(width: 6),
              itemBuilder: (context, i) {
                final String label = draft.activities.elementAt(i);
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                  ),
                  child: Center(child: Text(label, style: AppTextStyles.caption)),
                );
              },
            ),
          ),
        ],
      ],
    );
  }
}

class _ReliabilityBadge extends StatelessWidget {
  const _ReliabilityBadge({required this.attended, required this.total});
  final int attended;
  final int total;
  @override
  Widget build(BuildContext context) {
    if (total == 0) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.goldTint,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Row(
        children: <Widget>[
          const Icon(Icons.emoji_events_outlined, color: AppColors.gold),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Reliability', style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700)),
                Text('Attended $attended of $total events', style: AppTextStyles.caption),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Header row shared by the three enhancement cards — title on left,
/// "X of Y completed" chip on right, chevron rotates on expand.
class _EnhanceCard extends StatefulWidget {
  const _EnhanceCard({
    required this.title,
    required this.completed,
    required this.total,
    required this.rows,
  });

  final String title;
  final int completed;
  final int total;
  final List<_EnhanceRow> rows;

  @override
  State<_EnhanceCard> createState() => _EnhanceCardState();
}

class _EnhanceCardState extends State<_EnhanceCard> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: <Widget>[
          InkWell(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            onTap: () => setState(() => _open = !_open),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Text(widget.title, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700)),
                  ),
                  Text(
                    '${widget.completed} of ${widget.total} added',
                    style: AppTextStyles.caption,
                  ),
                  const SizedBox(width: 4),
                  AnimatedRotation(
                    turns: _open ? 0.5 : 0,
                    duration: const Duration(milliseconds: 180),
                    child: const Icon(Icons.expand_more, size: 20, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            child: _open
                ? Column(
                    children: <Widget>[
                      const Divider(height: 1, color: AppColors.border),
                      for (int i = 0; i < widget.rows.length; i++) ...<Widget>[
                        if (i > 0) const Divider(height: 1, color: AppColors.border, indent: AppSpacing.md),
                        widget.rows[i],
                      ],
                    ],
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class _EnhanceRow extends StatelessWidget {
  const _EnhanceRow({required this.label, required this.value, required this.onTap});
  final String label;
  final String value;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final bool filled = value.isNotEmpty && value != 'Add';
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 12),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(label, style: AppTextStyles.body),
                  if (filled) ...<Widget>[
                    const SizedBox(height: 2),
                    Text(value, style: AppTextStyles.caption),
                  ],
                ],
              ),
            ),
            Text(
              filled ? 'Edit' : 'Add',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.magenta,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right, color: AppColors.textSecondary, size: 20),
          ],
        ),
      ),
    );
  }
}

class _MoreAboutYouCard extends StatelessWidget {
  const _MoreAboutYouCard({required this.draft});
  final OnboardingDraft draft;
  @override
  Widget build(BuildContext context) {
    final bool hasHeight = draft.heightCm != null;
    final bool hasTraits = draft.traits.isNotEmpty;
    final bool hasWork =
        (draft.company?.isNotEmpty ?? false) || (draft.profession?.isNotEmpty ?? false);
    final bool hasStatus = draft.status != null;
    final int done = <bool>[hasHeight, hasTraits, hasWork, hasStatus].where((b) => b).length;

    return _EnhanceCard(
      title: 'More about you',
      completed: done,
      total: 4,
      rows: <_EnhanceRow>[
        _EnhanceRow(
          label: 'Height',
          value: hasHeight ? _heightLabel(draft.heightCm!) : '',
          onTap: () => context.push(RoutePaths.profileEditHeight),
        ),
        _EnhanceRow(
          label: 'Personality traits',
          value: hasTraits ? draft.traits.join(', ') : '',
          onTap: () => context.push(RoutePaths.profileEditTraits),
        ),
        _EnhanceRow(
          label: 'Work',
          value: hasWork
              ? [draft.profession, draft.company].where((s) => s != null && s.isNotEmpty).join(' · ')
              : '',
          onTap: () => context.push(RoutePaths.profileEditWork),
        ),
        _EnhanceRow(
          label: 'Relationship status',
          value: hasStatus ? draft.status!.label : '',
          onTap: () => context.push(RoutePaths.profileEditWork),
        ),
      ],
    );
  }

  String _heightLabel(int cm) {
    final int totalInches = (cm / 2.54).round();
    return "${totalInches ~/ 12}'${totalInches % 12}\"";
  }
}

class _YourFavouritesCard extends StatelessWidget {
  const _YourFavouritesCard({required this.draft});
  final OnboardingDraft draft;
  @override
  Widget build(BuildContext context) {
    final int done = <bool>[
      draft.musicians.any((p) => p.answer.isNotEmpty),
      draft.movies.any((p) => p.answer.isNotEmpty),
      draft.dishes.any((p) => p.answer.isNotEmpty),
    ].where((b) => b).length;

    return _EnhanceCard(
      title: 'Your favourites',
      completed: done,
      total: 3,
      rows: <_EnhanceRow>[
        _EnhanceRow(
          label: 'Musicians',
          value: _summarise(draft.musicians.map((p) => p.answer).toList()),
          onTap: () => context.push(RoutePaths.profileEditMusicians),
        ),
        _EnhanceRow(
          label: 'Movies',
          value: _summarise(draft.movies.map((p) => p.answer).toList()),
          onTap: () => context.push(RoutePaths.profileEditMovies),
        ),
        _EnhanceRow(
          label: 'Dishes',
          value: _summarise(draft.dishes.map((p) => p.answer).toList()),
          onTap: () => context.push(RoutePaths.profileEditDishes),
        ),
      ],
    );
  }

  String _summarise(List<String> answers) {
    final List<String> nonEmpty = answers.where((a) => a.isNotEmpty).toList();
    if (nonEmpty.isEmpty) return '';
    if (nonEmpty.length == 1) return nonEmpty.first;
    return '${nonEmpty.first} · +${nonEmpty.length - 1} more';
  }
}

class _YourSocialsCard extends StatelessWidget {
  const _YourSocialsCard({required this.draft});
  final OnboardingDraft draft;
  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        onTap: () => context.push(RoutePaths.profileEditSocials),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text('Your socials', style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 2),
                    Text(
                      draft.socials.isEmpty
                          ? 'Add Instagram, LinkedIn, or X'
                          : '${draft.socials.length} of 3 added',
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
              ),
              Text(
                draft.socials.isEmpty ? 'Add' : 'Edit',
                style: AppTextStyles.caption.copyWith(color: AppColors.magenta, fontWeight: FontWeight.w700),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.chevron_right, size: 20, color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}

class _HostCard extends StatelessWidget {
  const _HostCard({required this.status});
  final HostVerificationStatus status;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: AppGradients.marketingBackground,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Text(
                status == HostVerificationStatus.approved ? 'Your hosting' : 'Host on Lively',
                style: AppTextStyles.headline.copyWith(color: AppColors.textOnDark),
              ),
              if (status == HostVerificationStatus.approved) ...<Widget>[
                const SizedBox(width: 6),
                const Icon(Icons.verified, color: AppColors.textOnDark, size: 18),
              ],
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            switch (status) {
              HostVerificationStatus.approved =>
                'Create events, see attendee stats, and grow your hosting reputation.',
              HostVerificationStatus.underReview =>
                "We're verifying your identity. This usually takes under 24 hours.",
              HostVerificationStatus.rejected =>
                "We couldn't verify your identity. Try again with a clearer ID photo.",
              _ =>
                'Share what you love with verified people. You set the activity, the price, and the vibe.',
            },
            style: AppTextStyles.body.copyWith(color: AppColors.textOnDark.withOpacity(0.9)),
          ),
          const SizedBox(height: AppSpacing.md),
          GradientButton(
            label: switch (status) {
              HostVerificationStatus.approved => 'Create Event',
              HostVerificationStatus.underReview => 'Pending review',
              _ => 'Apply to host',
            },
            onPressed: status == HostVerificationStatus.underReview
                ? null
                : () => context.push(
                    status == HostVerificationStatus.approved
                        ? RoutePaths.createEvent
                        : RoutePaths.hostVerification,
                  ),
          ),
        ],
      ),
    );
  }
}

class _SettingItem {
  const _SettingItem({required this.icon, required this.label, required this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback onTap;
}

class _SettingsGroup extends StatelessWidget {
  const _SettingsGroup({required this.tiles});
  final List<_SettingItem> tiles;
  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: <Widget>[
          for (int i = 0; i < tiles.length; i++) ...<Widget>[
            if (i > 0) const Divider(height: 1, color: AppColors.border, indent: 56),
            ListTile(
              onTap: tiles[i].onTap,
              minVerticalPadding: 12,
              leading: Icon(tiles[i].icon, color: AppColors.textPrimary),
              title: Text(tiles[i].label, style: AppTextStyles.body),
              trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
            ),
          ],
        ],
      ),
    );
  }
}

/// Placeholder settings destination — real per-setting screens land in
/// later phases. This makes the tap always resolve to *something*,
/// which was the whole complaint.
void _openStubSettings(BuildContext context, String title, String body) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => _StubSettingsScreen(title: title, body: body),
    ),
  );
}

class _StubSettingsScreen extends StatelessWidget {
  const _StubSettingsScreen({required this.title, required this.body});
  final String title;
  final String body;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(title, style: AppTextStyles.headline),
      ),
      body: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Text(body, style: AppTextStyles.body),
        ),
      ),
    );
  }
}

class _LogoutTile extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: ListTile(
        onTap: () => _confirmLogout(context, ref),
        leading: const Icon(Icons.logout, color: AppColors.error),
        title: Text('Log out', style: AppTextStyles.body.copyWith(color: AppColors.error, fontWeight: FontWeight.w600)),
      ),
    );
  }

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    final bool? ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Log out?'),
        content: const Text(
          'You can log back in with the same Google account to pick up where you left off.',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Log out'),
          ),
        ],
      ),
    );
    if (ok == true) {
      // Router redirects to the login screen the instant this flips.
      ref.read(stubSignedInProvider.notifier).state = false;
    }
  }
}
