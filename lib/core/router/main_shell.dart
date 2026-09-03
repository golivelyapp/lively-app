import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/chats/providers/event_chat_provider.dart';
import '../../features/home/providers/event_providers.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class MainShell extends ConsumerWidget {
  const MainShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(chatInboxWatcherProvider);
    final int unread = ref.watch(totalUnreadCountProvider);

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (int index) {
          // Switching TO Home from any other tab → re-fetch the feed
          // so newly-published events by others appear.
          if (index == 0 && navigationShell.currentIndex != 0) {
            ref.read(eventsProvider.notifier).refresh();
          }
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
        backgroundColor: AppColors.background,
        indicatorColor: AppColors.pink.withOpacity(0.12),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: <NavigationDestination>[
          const NavigationDestination(
            icon: Icon(Icons.home_outlined, color: AppColors.textSecondary),
            selectedIcon: Icon(Icons.home, color: AppColors.magenta),
            label: 'Home',
          ),
          const NavigationDestination(
            icon: Icon(Icons.people_outline, color: AppColors.textSecondary),
            selectedIcon: Icon(Icons.people, color: AppColors.magenta),
            label: 'People',
          ),
          NavigationDestination(
            icon: _NavIconWithBadge(
              icon: Icons.chat_bubble_outline,
              color: AppColors.textSecondary,
              badgeCount: unread,
            ),
            selectedIcon: _NavIconWithBadge(
              icon: Icons.chat_bubble,
              color: AppColors.magenta,
              badgeCount: unread,
            ),
            label: 'Chats',
          ),
          const NavigationDestination(
            icon: Icon(Icons.person_outline, color: AppColors.textSecondary),
            selectedIcon: Icon(Icons.person, color: AppColors.magenta),
            label: 'You',
          ),
        ],
      ),
    );
  }
}

/// Small overlay badge for the Chats tab. Rendered only when unread > 0.
class _NavIconWithBadge extends StatelessWidget {
  const _NavIconWithBadge({
    required this.icon,
    required this.color,
    required this.badgeCount,
  });

  final IconData icon;
  final Color color;
  final int badgeCount;

  @override
  Widget build(BuildContext context) {
    if (badgeCount <= 0) return Icon(icon, color: color);
    final String label = badgeCount > 99 ? '99+' : badgeCount.toString();
    return Stack(
      clipBehavior: Clip.none,
      children: <Widget>[
        Icon(icon, color: color),
        Positioned(
          right: -8,
          top: -6,
          child: Container(
            constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
            padding: const EdgeInsets.symmetric(horizontal: 5),
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: AppColors.magenta,
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.all(Radius.circular(999)),
            ),
            child: Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textOnDark,
                fontWeight: FontWeight.w700,
                fontSize: 10,
                height: 1,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
