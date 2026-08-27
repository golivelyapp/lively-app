import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';

/// Placeholder notifications inbox — real push and in-app notifications
/// arrive with the Supabase migration. For now this exists so the bell
/// icon on Home has somewhere real to go instead of being a dead touch.
class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<_Notif> items = _seedNotifications();
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text('Notifications', style: AppTextStyles.headline),
      ),
      body: items.isEmpty
          ? _empty()
          : ListView.separated(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              itemCount: items.length,
              separatorBuilder: (_, __) => const Divider(
                height: 1,
                color: AppColors.border,
                indent: AppSpacing.md,
                endIndent: AppSpacing.md,
              ),
              itemBuilder: (context, i) => _NotifTile(notif: items[i]),
            ),
    );
  }

  Widget _empty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(Icons.notifications_none, size: 56, color: AppColors.textSecondary),
            const SizedBox(height: AppSpacing.md),
            Text("You're all caught up", style: AppTextStyles.headline),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'RSVP reminders, chat mentions, and new events near you will appear here.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySecondary,
            ),
          ],
        ),
      ),
    );
  }
}

class _NotifTile extends StatelessWidget {
  const _NotifTile({required this.notif});
  final _Notif notif;
  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {},
      leading: CircleAvatar(
        radius: 20,
        backgroundColor: AppColors.pinkTint,
        child: Icon(notif.icon, size: 20, color: AppColors.magenta),
      ),
      title: Text(notif.title, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600)),
      subtitle: Text(notif.body, style: AppTextStyles.bodySecondary, maxLines: 2, overflow: TextOverflow.ellipsis),
      trailing: Text(notif.when, style: AppTextStyles.caption),
    );
  }
}

class _Notif {
  const _Notif({
    required this.icon,
    required this.title,
    required this.body,
    required this.when,
  });
  final IconData icon;
  final String title;
  final String body;
  final String when;
}

List<_Notif> _seedNotifications() {
  return const <_Notif>[
    _Notif(
      icon: Icons.event_available_outlined,
      title: 'Beer & Board Games Night starts in 2 days',
      body: 'The group chat is active. Say hi before you show up on Friday.',
      when: '2h',
    ),
    _Notif(
      icon: Icons.chat_bubble_outline,
      title: 'New message in Sunday Art Jam',
      body: 'Meera: "Anyone need help with brushes? I have extras."',
      when: '5h',
    ),
    _Notif(
      icon: Icons.local_fire_department_outlined,
      title: '3 new events near you this weekend',
      body: 'Trending in Koramangala: pottery, pub quiz, sunrise yoga.',
      when: '1d',
    ),
  ];
}
