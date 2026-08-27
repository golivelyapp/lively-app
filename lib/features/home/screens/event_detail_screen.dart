import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/gradient_button.dart';
import '../../onboarding/models/onboarding_enums.dart';
import '../../onboarding/providers/onboarding_draft_controller.dart';
import '../models/event.dart';
import '../models/event_category.dart';
import '../providers/event_providers.dart';
import '../widgets/attendee_avatar_stack.dart';
import '../widgets/event_card.dart' show formatEventWhen;
import '../widgets/gender_balance_bar.dart';

const List<String> _monthsFull = <String>['January','February','March','April','May','June','July','August','September','October','November','December'];
const List<String> _daysFull = <String>['Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday'];

class EventDetailScreen extends ConsumerWidget {
  const EventDetailScreen({required this.eventId, super.key});

  final String eventId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Event? event = ref.watch(eventByIdProvider(eventId));
    if (event == null) {
      return const Scaffold(body: Center(child: Text('Event not found')));
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: <Widget>[
          CustomScrollView(
            physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
            slivers: <Widget>[
              _HeroSliver(event: event),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    AppSpacing.md,
                    AppSpacing.md,
                    140,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(event.title, style: AppTextStyles.displayLg),
                      const SizedBox(height: AppSpacing.sm),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: <Widget>[
                          _CategoryPill(label: event.category.label),
                          if (event.isWomenOnly) const _WomenOnlyPill(),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _HostSummary(event: event),
                      const SizedBox(height: AppSpacing.md),
                      _QuickInfoRow(event: event),
                      const SizedBox(height: AppSpacing.md),
                      _SpotsPriceBanner(event: event),
                      const SizedBox(height: AppSpacing.lg),
                      Text('What to expect', style: AppTextStyles.headline),
                      const SizedBox(height: AppSpacing.sm),
                      _DescriptionText(text: event.description),
                      const SizedBox(height: AppSpacing.lg),
                      _HostCard(event: event),
                      const SizedBox(height: AppSpacing.md),
                      _WhenCard(event: event),
                      const SizedBox(height: AppSpacing.md),
                      _WhereCard(event: event),
                      const SizedBox(height: AppSpacing.md),
                      _WhoIsGoingCard(event: event),
                      const SizedBox(height: AppSpacing.md),
                      const _SafetyCard(),
                      const SizedBox(height: AppSpacing.md),
                      const _SupportCard(),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        'Free cancellation up to 24 hours before the event.',
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _BottomActionBar(event: event),
          ),
        ],
      ),
    );
  }
}

class _HeroSliver extends StatelessWidget {
  const _HeroSliver({required this.event});
  final Event event;
  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      expandedHeight: 260,
      backgroundColor: AppColors.background,
      foregroundColor: AppColors.textOnDark,
      elevation: 0,
      leading: _CircleIconButton(
        icon: Icons.arrow_back,
        onTap: () => Navigator.of(context).maybePop(),
      ),
      actions: <Widget>[
        _CircleIconButton(
          icon: Icons.ios_share,
          onTap: () => _shareEvent(context, event),
        ),
        const SizedBox(width: AppSpacing.sm),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            event.coverImageUrl.isEmpty
                ? const ColoredBox(color: AppColors.surface)
                : CachedNetworkImage(imageUrl: event.coverImageUrl, fit: BoxFit.cover),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: <Color>[Color(0x66000000), Color(0x00000000), Color(0x66000000)],
                  stops: <double>[0.0, 0.5, 1.0],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.sm),
      child: Material(
        color: Colors.black.withOpacity(0.35),
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: SizedBox(
            width: 36,
            height: 36,
            child: Icon(icon, size: 20, color: AppColors.textOnDark),
          ),
        ),
      ),
    );
  }
}

class _CategoryPill extends StatelessWidget {
  const _CategoryPill({required this.label});
  final String label;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
      ),
      child: Text(label, style: AppTextStyles.caption),
    );
  }
}

class _WomenOnlyPill extends StatelessWidget {
  const _WomenOnlyPill();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.pinkTint,
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
      ),
      child: Text(
        'Women only',
        style: AppTextStyles.caption.copyWith(color: AppColors.magenta, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _HostSummary extends StatelessWidget {
  const _HostSummary({required this.event});
  final Event event;
  @override
  Widget build(BuildContext context) {
    final String first = event.hostName.split(' ').first;
    return Row(
      children: <Widget>[
        Stack(
          clipBehavior: Clip.none,
          children: <Widget>[
            CircleAvatar(radius: 18, backgroundImage: CachedNetworkImageProvider(event.hostPhotoUrl)),
            if (event.hostVerified)
              const Positioned(
                right: -2,
                bottom: -2,
                child: Icon(Icons.verified, size: 14, color: AppColors.gold),
              ),
          ],
        ),
        const SizedBox(width: AppSpacing.sm),
        Flexible(
          child: Text(
            'Hosted by $first · ★ ${event.hostRating.toStringAsFixed(1)}',
            style: AppTextStyles.bodySecondary,
          ),
        ),
      ],
    );
  }
}

class _QuickInfoRow extends StatelessWidget {
  const _QuickInfoRow({required this.event});
  final Event event;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(child: _QuickItem(icon: Icons.calendar_today_outlined, label: _dateLabel(event.startTime))),
        Expanded(child: _QuickItem(icon: Icons.schedule, label: _timeRangeLabel(event))),
        Expanded(child: _QuickItem(icon: Icons.place_outlined, label: event.neighbourhood)),
      ],
    );
  }
}

class _QuickItem extends StatelessWidget {
  const _QuickItem({required this.icon, required this.label});
  final IconData icon;
  final String label;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Icon(icon, size: 20, color: AppColors.textSecondary),
        const SizedBox(height: 4),
        Text(label, textAlign: TextAlign.center, style: AppTextStyles.caption),
      ],
    );
  }
}

class _SpotsPriceBanner extends StatelessWidget {
  const _SpotsPriceBanner({required this.event});
  final Event event;
  @override
  Widget build(BuildContext context) {
    final String spots = event.isFull
        ? 'Sold out'
        : '${event.spotsRemaining} spots left';
    final String price = event.isFree ? 'Free' : '₹${event.priceRupees}';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Row(
        children: <Widget>[
          Text(spots, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700)),
          const Text(' · ', style: AppTextStyles.body),
          Text(price, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700, color: event.isFree ? AppColors.success : AppColors.textPrimary)),
        ],
      ),
    );
  }
}

class _DescriptionText extends StatefulWidget {
  const _DescriptionText({required this.text});
  final String text;
  @override
  State<_DescriptionText> createState() => _DescriptionTextState();
}

class _DescriptionTextState extends State<_DescriptionText> {
  bool _expanded = false;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        AnimatedSize(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          alignment: Alignment.topLeft,
          child: Text(
            widget.text,
            style: AppTextStyles.body,
            maxLines: _expanded ? null : 5,
            overflow: _expanded ? TextOverflow.visible : TextOverflow.ellipsis,
          ),
        ),
        if (widget.text.length > 200)
          TextButton(
            style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(0, 32)),
            onPressed: () => setState(() => _expanded = !_expanded),
            child: Text(
              _expanded ? 'Read less' : 'Read more',
              style: AppTextStyles.body.copyWith(color: AppColors.magenta, fontWeight: FontWeight.w600),
            ),
          ),
      ],
    );
  }
}

class _HostCard extends StatelessWidget {
  const _HostCard({required this.event});
  final Event event;
  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Row(
        children: <Widget>[
          Stack(
            clipBehavior: Clip.none,
            children: <Widget>[
              CircleAvatar(radius: 32, backgroundImage: CachedNetworkImageProvider(event.hostPhotoUrl)),
              if (event.hostVerified)
                const Positioned(
                  right: -2,
                  bottom: -2,
                  child: Icon(Icons.verified, size: 20, color: AppColors.gold),
                ),
            ],
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(event.hostName, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(event.hostBio, style: AppTextStyles.caption),
                const SizedBox(height: 6),
                Text(
                  '${event.hostEventsHosted} events hosted · ★ ${event.hostRating.toStringAsFixed(1)}',
                  style: AppTextStyles.bodySecondary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WhenCard extends StatelessWidget {
  const _WhenCard({required this.event});
  final Event event;
  @override
  Widget build(BuildContext context) {
    final DateTime start = event.startTime;
    final DateTime end = event.endTime;
    final String day = _daysFull[start.weekday - 1];
    final String month = _monthsFull[start.month - 1];
    return _Card(
      child: _IconTitleBody(
        icon: Icons.calendar_today_outlined,
        title: '$day, $month ${start.day}, ${start.year}',
        body: '${_time(start)} – ${_time(end)} · ${(event.durationMinutes / 60).toStringAsFixed(event.durationMinutes % 60 == 0 ? 0 : 1)} hours',
      ),
    );
  }
}

class _WhereCard extends StatelessWidget {
  const _WhereCard({required this.event});
  final Event event;
  @override
  Widget build(BuildContext context) {
    return _Card(
      onTap: () => _openMaps(context, event),
      child: _IconTitleBody(
        icon: Icons.place_outlined,
        title: event.venueName,
        body: event.venueAddress,
        trailing: const Icon(Icons.map_outlined, size: 20, color: AppColors.magenta),
      ),
    );
  }
}

class _WhoIsGoingCard extends ConsumerWidget {
  const _WhoIsGoingCard({required this.event});
  final Event event;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              const Icon(Icons.people_outline, size: 20, color: AppColors.textSecondary),
              const SizedBox(width: AppSpacing.sm),
              Text(
                "Who's going",
                style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700),
              ),
              const Spacer(),
              Text('${event.rsvpCount} of ${event.totalSpots}', style: AppTextStyles.caption),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          if (event.attendeeAvatarUrls.isEmpty)
            Text('Be the first to join!', style: AppTextStyles.bodySecondary)
          else
            AttendeeAvatarStack(
              avatarUrls: event.attendeeAvatarUrls,
              max: 6,
              radius: 18,
              totalCount: event.rsvpCount,
            ),
          const SizedBox(height: AppSpacing.md),
          GenderBalanceBar(maleRatio: event.maleRatio, height: 6),
          if (event.rsvpCount > 0) ...<Widget>[
            const SizedBox(height: 6),
            Text(
              '${event.femaleRsvpCount} women · ${event.maleRsvpCount} men',
              style: AppTextStyles.caption,
            ),
          ],
        ],
      ),
    );
  }
}

class _SafetyCard extends StatelessWidget {
  const _SafetyCard();
  @override
  Widget build(BuildContext context) {
    return _Card(
      child: _IconTitleBody(
        icon: Icons.shield_outlined,
        title: 'Your safety matters',
        body:
            'Every attendee is verified with a government ID. Lively monitors event chats for harassment. If you feel unsafe, tap Support below.',
      ),
    );
  }
}

class _SupportCard extends StatelessWidget {
  const _SupportCard();
  @override
  Widget build(BuildContext context) {
    return _Card(
      onTap: () => _openSupport(context),
      child: _IconTitleBody(
        icon: Icons.headset_mic_outlined,
        title: 'Need help?',
        body: 'Contact us anytime before, during, or after the event.',
        trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child, this.onTap});
  final Widget child;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    final Widget content = Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: child,
    );
    if (onTap == null) return content;
    return InkWell(
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      onTap: onTap,
      child: content,
    );
  }
}

class _IconTitleBody extends StatelessWidget {
  const _IconTitleBody({required this.icon, required this.title, required this.body, this.trailing});
  final IconData icon;
  final String title;
  final String body;
  final Widget? trailing;
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Icon(icon, size: 20, color: AppColors.textSecondary),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(title, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text(body, style: AppTextStyles.bodySecondary),
            ],
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

class _BottomActionBar extends ConsumerWidget {
  const _BottomActionBar({required this.event});
  final Event event;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Gender? myGender = ref.watch(
      onboardingDraftProvider.select((d) => d.gender),
    );
    final bool blockedMenOnly = event.isMenOnly && myGender == Gender.female;
    final bool blockedWomenOnly = event.isWomenOnly && myGender == Gender.male;
    final bool blocked = blockedMenOnly || blockedWomenOnly;

    String label;
    VoidCallback? onPressed;

    if (blocked) {
      label = event.isWomenOnly ? 'Women only event' : 'Men only event';
      onPressed = null;
    } else if (event.isFull && !event.isGoing) {
      label = 'Sold out';
      onPressed = null;
    } else if (event.isGoing) {
      label = "You're in ✓";
      onPressed = () {
        ref.read(eventsProvider.notifier).toggleRsvp(event.id);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('RSVP cancelled. Your spot is back in the pool.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      };
    } else {
      label = event.isFree ? 'RSVP · Free' : 'RSVP · ₹${event.priceRupees}';
      onPressed = () {
        ref.read(eventsProvider.notifier).toggleRsvp(event.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("You're in! Group chat is open in the Chats tab."),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.magenta,
            action: SnackBarAction(
              label: 'Open chat',
              textColor: AppColors.textOnDark,
              onPressed: () =>
                  context.push('/chats/${event.id}'),
            ),
          ),
        );
      };
    }

    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.background,
        boxShadow: <BoxShadow>[
          BoxShadow(color: Color(0x14000000), blurRadius: 16, offset: Offset(0, -4)),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        event.isFull ? 'Sold out' : '${event.spotsRemaining} spots left',
                        style: AppTextStyles.caption.copyWith(
                          color: event.isLowOnSpots ? AppColors.warning : AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        event.isFree ? 'Free entry' : '₹${event.priceRupees}',
                        style: AppTextStyles.bodySecondary,
                      ),
                    ],
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(child: GradientButton(label: label, onPressed: onPressed)),
                ],
              ),
              if (event.isGoing && !blocked)
                TextButton(
                  onPressed: () => ref.read(eventsProvider.notifier).toggleRsvp(event.id),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    minimumSize: const Size(0, 32),
                  ),
                  child: Text(
                    'Cancel RSVP',
                    style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                  ),
                ),
              if (event.isFull && !event.isGoing && !blocked)
                TextButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          "You're on the list. We'll notify you if a spot opens.",
                        ),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    minimumSize: const Size(0, 32),
                  ),
                  child: Text(
                    'Notify me if a spot opens',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.magenta,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

String _dateLabel(DateTime dt) {
  const List<String> months = <String>['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
  const List<String> days = <String>['Mon','Tue','Wed','Thu','Fri','Sat','Sun'];
  return '${days[dt.weekday - 1]}, ${months[dt.month - 1]} ${dt.day}';
}

String _timeRangeLabel(Event e) {
  return '${_time(e.startTime)} – ${_time(e.endTime)}';
}

String _time(DateTime dt) {
  final int h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
  final String m = dt.minute.toString().padLeft(2, '0');
  final String p = dt.hour < 12 ? 'AM' : 'PM';
  return '$h:$m $p';
}

/// Native share sheet. `SharePlus.instance.share` is the current API on
/// share_plus 10.x; older `Share.share` is deprecated.
Future<void> _shareEvent(BuildContext context, Event event) async {
  final String when = '${_dateLabel(event.startTime)} · ${_time(event.startTime)}';
  // Deep link points at the app's event route. When universal/app links
  // are configured later, this URL will resolve straight into the app;
  // for now it's a placeholder that lands on a web fallback.
  final String url = 'https://lively.app/event/${event.id}';
  final String message =
      "${event.title}\n$when · ${event.neighbourhood}\nHosted by ${event.hostName.split(' ').first} on Lively\n$url";
  await Share.share(message, subject: event.title);
}

/// Open Google Maps to the venue. Fall back to a browser search if the
/// Maps app isn't installed. We prefer the search query over lat/lng
/// because we only have addresses for seed data — no geocoded points.
Future<void> _openMaps(BuildContext context, Event event) async {
  final String q = Uri.encodeComponent('${event.venueName}, ${event.venueAddress}');
  final Uri geo = Uri.parse('geo:0,0?q=$q');
  final Uri fallback = Uri.parse('https://www.google.com/maps/search/?api=1&query=$q');
  try {
    if (await canLaunchUrl(geo)) {
      await launchUrl(geo);
      return;
    }
  } catch (_) {
    // Some Android builds throw when the geo scheme isn't handled — fall
    // through to the web fallback below.
  }
  await launchUrl(fallback, mode: LaunchMode.externalApplication);
}

/// Open a mailto: link to Lively support. On devices with no configured
/// mail app we surface a snackbar with the fallback email so the user
/// can still copy it manually.
Future<void> _openSupport(BuildContext context) async {
  final Uri mail = Uri(
    scheme: 'mailto',
    path: 'support@lively.app',
    query: 'subject=Help with a Lively event',
  );
  final bool launched = await launchUrl(mail);
  if (!launched && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Email us at support@lively.app'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
