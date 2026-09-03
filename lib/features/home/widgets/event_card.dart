import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../models/event.dart';
import '../models/event_category.dart';
import 'attendee_avatar_stack.dart';
import 'gender_balance_bar.dart';

const List<String> _shortDays = <String>['Mon','Tue','Wed','Thu','Fri','Sat','Sun'];
const List<String> _shortMonths = <String>['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];

String formatEventWhen(DateTime dt) {
  final int hour12 = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
  final String minute = dt.minute.toString().padLeft(2, '0');
  final String period = dt.hour < 12 ? 'AM' : 'PM';
  return '${_shortDays[dt.weekday - 1]}, ${_shortMonths[dt.month - 1]} ${dt.day} · $hour12:$minute $period';
}

String formatEventCountdown(DateTime start) {
  final DateTime now = DateTime.now();
  final Duration diff = start.difference(now);
  if (diff.inHours < 1 && diff.inMinutes > 0) return 'Starts soon';
  if (diff.inHours < 12) return 'Today at ${_time(start)}';
  final DateTime today = DateTime(now.year, now.month, now.day);
  final DateTime day = DateTime(start.year, start.month, start.day);
  final int days = day.difference(today).inDays;
  if (days == 0) return 'Today at ${_time(start)}';
  if (days == 1) return 'Tomorrow at ${_time(start)}';
  if (days < 7) return 'In $days days';
  return formatEventWhen(start);
}

String _time(DateTime dt) {
  final int h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
  final String m = dt.minute.toString().padLeft(2, '0');
  final String p = dt.hour < 12 ? 'AM' : 'PM';
  return '$h:$m $p';
}

class EventCard extends StatelessWidget {
  const EventCard({required this.event, required this.onTap, super.key});

  final Event event;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _PressableCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          AspectRatio(
            aspectRatio: 16 / 9,
            child: _CoverImage(url: event.coverImageUrl),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  event.title,
                  style: AppTextStyles.headline,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: <Widget>[
                    _CategoryTag(category: event.category),
                    if (event.isWomenOnly) const _WomenOnlyTag(),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                _HostRow(event: event),
                const SizedBox(height: AppSpacing.sm),
                _MetaLine(event: event),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: <Widget>[
                    Text(
                      event.priceLabel,
                      style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.w700,
                        color: event.isFree ? AppColors.success : AppColors.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    _SpotsText(event: event),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                GenderBalanceBar(maleRatio: event.maleRatio),
                if (event.rsvpCount > 0) ...<Widget>[
                  const SizedBox(height: 6),
                  Text(
                    '${event.femaleRsvpCount} women · ${event.maleRsvpCount} men',
                    style: AppTextStyles.caption,
                  ),
                ],
                if (event.attendeeAvatarUrls.isNotEmpty) ...<Widget>[
                  const SizedBox(height: AppSpacing.sm),
                  AttendeeAvatarStack(
                    avatarUrls: event.attendeeAvatarUrls,
                    max: 4,
                    radius: 14,
                    totalCount: event.rsvpCount,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CoverImage extends StatelessWidget {
  const _CoverImage({required this.url});
  final String url;
  @override
  Widget build(BuildContext context) {
    if (url.isEmpty) return const ColoredBox(color: AppColors.surface);
    // Create-Event preview passes a local file path while the cover is
    // still on-device; render it with Image.file so the preview isn't blank.
    if (!url.startsWith('http')) {
      return Image.file(
        File(url),
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const ColoredBox(color: AppColors.surface),
      );
    }
    return CachedNetworkImage(
      imageUrl: url,
      fit: BoxFit.cover,
      placeholder: (_, __) => const _ShimmerBox(),
      errorWidget: (_, __, ___) => const ColoredBox(color: AppColors.surface),
    );
  }
}

class _ShimmerBox extends StatefulWidget {
  const _ShimmerBox();
  @override
  State<_ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<_ShimmerBox> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        return DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment(-1 + _c.value * 2, -0.3),
              end: Alignment(1 + _c.value * 2, 0.3),
              colors: const <Color>[
                AppColors.surfaceAlt,
                AppColors.surface,
                AppColors.surfaceAlt,
              ],
            ),
          ),
        );
      },
    );
  }
}

class _PressableCard extends StatefulWidget {
  const _PressableCard({required this.child, required this.onTap});
  final Widget child;
  final VoidCallback onTap;
  @override
  State<_PressableCard> createState() => _PressableCardState();
}

class _PressableCardState extends State<_PressableCard> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.98),
      onTapUp: (_) => setState(() => _scale = 1.0),
      onTapCancel: () => setState(() => _scale = 1.0),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOut,
        child: Container(
          margin: const EdgeInsets.only(bottom: AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            boxShadow: const <BoxShadow>[
              BoxShadow(color: Color(0x14000000), blurRadius: 12, offset: Offset(0, 4)),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: widget.child,
        ),
      ),
    );
  }
}

class _CategoryTag extends StatelessWidget {
  const _CategoryTag({required this.category});
  final EventCategory category;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(category.icon, size: 12, color: AppColors.textSecondary),
          const SizedBox(width: 4),
          Text(category.label, style: AppTextStyles.caption),
        ],
      ),
    );
  }
}

class _WomenOnlyTag extends StatelessWidget {
  const _WomenOnlyTag();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 4),
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

class _HostRow extends StatelessWidget {
  const _HostRow({required this.event});
  final Event event;
  @override
  Widget build(BuildContext context) {
    final String hostFirst = event.hostName.split(' ').first;
    final String meta = event.hostRating > 0
        ? '★ ${event.hostRating.toStringAsFixed(1)}'
        : '${event.hostEventsHosted} events hosted';
    return Row(
      children: <Widget>[
        Stack(
          clipBehavior: Clip.none,
          children: <Widget>[
            CircleAvatar(
              radius: 14,
              backgroundColor: AppColors.surface,
              backgroundImage: CachedNetworkImageProvider(event.hostPhotoUrl),
            ),
            if (event.hostVerified)
              const Positioned(
                right: -2,
                bottom: -2,
                child: _VerifiedDot(),
              ),
          ],
        ),
        const SizedBox(width: AppSpacing.sm),
        Flexible(
          child: Text(
            'Hosted by $hostFirst · $meta',
            style: AppTextStyles.bodySecondary.copyWith(color: AppColors.textSecondary),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _VerifiedDot extends StatelessWidget {
  const _VerifiedDot();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(1),
      decoration: const BoxDecoration(color: AppColors.background, shape: BoxShape.circle),
      child: const Icon(Icons.verified, size: 12, color: AppColors.gold),
    );
  }
}

class _MetaLine extends StatelessWidget {
  const _MetaLine({required this.event});
  final Event event;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        const Icon(Icons.calendar_today_outlined, size: 12, color: AppColors.textSecondary),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            '${formatEventWhen(event.startTime)} · ${event.neighbourhood}',
            style: AppTextStyles.bodySecondary,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _SpotsText extends StatelessWidget {
  const _SpotsText({required this.event});
  final Event event;
  @override
  Widget build(BuildContext context) {
    if (event.isFull) {
      return Text('Sold out', style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary));
    }
    final bool urgent = event.isLowOnSpots;
    return Text(
      '${event.spotsRemaining} of ${event.totalSpots} spots left',
      style: AppTextStyles.caption.copyWith(
        color: urgent ? AppColors.warning : AppColors.textSecondary,
        fontWeight: urgent ? FontWeight.w600 : FontWeight.w500,
      ),
    );
  }
}
