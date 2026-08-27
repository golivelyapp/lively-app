import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// Overlapping row of attendee avatars. Each avatar has a border in the
/// card's background color (white) — the border is only there to visually
/// separate overlapping circles, not to draw a visible ring. The trailing
/// "+N more" is a same-size circle chip so the row reads as one unit.
class AttendeeAvatarStack extends StatelessWidget {
  const AttendeeAvatarStack({
    required this.avatarUrls,
    super.key,
    this.max = 4,
    this.radius = 14,
    this.totalCount,
  });

  final List<String> avatarUrls;
  final int max;
  final double radius;
  final int? totalCount;

  @override
  Widget build(BuildContext context) {
    final List<String> shown = avatarUrls.take(max).toList();
    final int extra = (totalCount ?? avatarUrls.length) - shown.length;
    final double overlap = radius * 0.7;
    final double diameter = radius * 2;

    // Total items in the row = avatars + optional +N chip.
    final int itemCount = shown.length + (extra > 0 ? 1 : 0);
    if (itemCount == 0) return const SizedBox.shrink();
    final double stackWidth = diameter + (itemCount - 1) * overlap;

    return SizedBox(
      height: diameter,
      width: stackWidth,
      child: Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          for (int i = 0; i < shown.length; i++)
            Positioned(
              left: i * overlap,
              child: _AvatarChip(radius: radius, imageUrl: shown[i]),
            ),
          if (extra > 0)
            Positioned(
              left: shown.length * overlap,
              child: _MoreChip(radius: radius, count: extra),
            ),
        ],
      ),
    );
  }
}

class _AvatarChip extends StatelessWidget {
  const _AvatarChip({required this.radius, required this.imageUrl});
  final double radius;
  final String imageUrl;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.background, width: 2),
      ),
      child: ClipOval(
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          fit: BoxFit.cover,
          placeholder: (_, __) => Container(color: AppColors.surface),
          errorWidget: (_, __, ___) => Container(color: AppColors.surface),
        ),
      ),
    );
  }
}

class _MoreChip extends StatelessWidget {
  const _MoreChip({required this.radius, required this.count});
  final double radius;
  final int count;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        color: AppColors.lockChip,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.background, width: 2),
      ),
      alignment: Alignment.center,
      child: Text(
        '+$count',
        style: AppTextStyles.caption.copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w700,
          fontSize: radius > 16 ? 12 : 10,
        ),
      ),
    );
  }
}
