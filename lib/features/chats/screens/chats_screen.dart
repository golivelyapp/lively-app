import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/route_paths.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../home/models/event.dart';
import '../../home/providers/event_providers.dart';
import '../models/chat_message.dart';
import '../providers/event_chat_provider.dart';

class ChatsScreen extends StatefulWidget {
  const ChatsScreen({super.key});

  @override
  State<ChatsScreen> createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController = TabController(length: 2, vsync: this);

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.sm,
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('Chats', style: AppTextStyles.displayLg),
              ),
            ),
            TabBar(
              controller: _tabController,
              labelColor: AppColors.magenta,
              unselectedLabelColor: AppColors.textSecondary,
              indicatorColor: AppColors.magenta,
              indicatorSize: TabBarIndicatorSize.label,
              labelStyle: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
              unselectedLabelStyle: AppTextStyles.body,
              tabs: const <Widget>[
                Tab(text: 'Event Chats'),
                Tab(text: 'Direct Messages'),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: const <Widget>[_EventChatsTab(), _DirectMessagesTab()],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EventChatsTab extends ConsumerWidget {
  const _EventChatsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<Event> chats = ref
        .watch(eventsProvider)
        .where((e) => e.isGoing)
        .toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));

    if (chats.isEmpty) {
      return _empty(
        icon: Icons.chat_bubble_outline,
        title: 'Your event chats will appear here',
        subtitle: 'When you RSVP to an event, its group chat opens right away.',
      );
    }

    return ListView.separated(
      physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      itemCount: chats.length,
      separatorBuilder: (_, __) => const Divider(height: 1, color: AppColors.border, indent: 76),
      itemBuilder: (context, i) {
        final Event event = chats[i];
        final ChatMessage? last = ref.watch(eventChatPreviewProvider(event.id));
        final bool archived = event.isPast && !event.isWithinPostEventWindow;

        final String preview = archived
            ? 'Archived — no new messages'
            : (last?.text ?? 'Say hello to the group.');

        return ListTile(
          onTap: () => context.push('${RoutePaths.chats}/${event.id}'),
          contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 4),
          leading: SizedBox(
            width: 44,
            height: 44,
            child: ClipOval(
              child: event.coverImageUrl.isEmpty
                  ? Container(color: AppColors.surface)
                  : CachedNetworkImage(imageUrl: event.coverImageUrl, fit: BoxFit.cover),
            ),
          ),
          title: Text(event.title, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
          subtitle: Text(preview, style: AppTextStyles.bodySecondary, maxLines: 1, overflow: TextOverflow.ellipsis),
          trailing: archived
              ? const Icon(Icons.lock_outline, size: 16, color: AppColors.textSecondary)
              : null,
        );
      },
    );
  }
}

class _DirectMessagesTab extends StatelessWidget {
  const _DirectMessagesTab();

  @override
  Widget build(BuildContext context) {
    return _empty(
      icon: Icons.waving_hand_outlined,
      title: 'No direct messages yet',
      subtitle: 'When you and someone wave at each other after an event, your conversation will appear here.',
    );
  }
}

Widget _empty({required IconData icon, required String title, required String subtitle}) {
  return Center(
    child: Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 56, color: AppColors.textSecondary),
          const SizedBox(height: AppSpacing.md),
          Text(title, textAlign: TextAlign.center, style: AppTextStyles.headline),
          const SizedBox(height: AppSpacing.sm),
          Text(subtitle, textAlign: TextAlign.center, style: AppTextStyles.bodySecondary),
        ],
      ),
    ),
  );
}
