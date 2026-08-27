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

const List<String> _mockNames = <String>[
  'Aditi', 'Rahul', 'Sneha', 'Vikram', 'Neha', 'Aakash', 'Divya', 'Kabir',
  'Priya', 'Rohit', 'Meera', 'Karan',
];

class PeopleScreen extends ConsumerWidget {
  const PeopleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<Event> attendedPast = ref
        .watch(eventsProvider)
        .where((e) => e.isGoing && e.isPast)
        .toList()
      ..sort((a, b) => b.startTime.compareTo(a.startTime));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: attendedPast.isEmpty
            ? _EmptyState()
            : ListView(
                physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.md, AppSpacing.md, AppSpacing.md),
                children: <Widget>[
                  Text('People', style: AppTextStyles.displayLg),
                  const SizedBox(height: AppSpacing.md),
                  for (final Event event in attendedPast) ...<Widget>[
                    _EventGroupHeader(event: event),
                    const SizedBox(height: AppSpacing.sm),
                    SizedBox(
                      height: 156,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        itemCount: event.attendeeAvatarUrls.length,
                        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
                        itemBuilder: (context, i) => _PersonCard(
                          name: _mockNames[(event.hashCode + i).abs() % _mockNames.length],
                          avatarUrl: event.attendeeAvatarUrls[i],
                          eventsAttended: 3 + (i % 5),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                  ],
                ],
              ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(Icons.people_outline, size: 64, color: AppColors.textSecondary),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Attend an event to meet people here',
              textAlign: TextAlign.center,
              style: AppTextStyles.headline,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'After an event ends, everyone you met shows up here.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySecondary,
            ),
            const SizedBox(height: AppSpacing.lg),
            SizedBox(
              width: 200,
              child: ElevatedButton(
                onPressed: () => context.go(RoutePaths.home),
                child: const Text('Browse events'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EventGroupHeader extends StatelessWidget {
  const _EventGroupHeader({required this.event});
  final Event event;
  @override
  Widget build(BuildContext context) {
    const List<String> months = <String>['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    final String when = '${months[event.startTime.month - 1]} ${event.startTime.day}';
    return Text(
      'From ${event.title} · $when',
      style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700),
    );
  }
}

class _PersonCard extends StatefulWidget {
  const _PersonCard({required this.name, required this.avatarUrl, required this.eventsAttended});
  final String name;
  final String avatarUrl;
  final int eventsAttended;
  @override
  State<_PersonCard> createState() => _PersonCardState();
}

class _PersonCardState extends State<_PersonCard> {
  bool _waved = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 132,
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          CircleAvatar(radius: 32, backgroundImage: CachedNetworkImageProvider(widget.avatarUrl)),
          const SizedBox(height: AppSpacing.sm),
          Text(widget.name, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 2),
          Text('${widget.eventsAttended} events', style: AppTextStyles.caption),
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            width: double.infinity,
            height: 32,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.zero,
                foregroundColor: _waved ? AppColors.textSecondary : AppColors.magenta,
                side: BorderSide(color: _waved ? AppColors.border : AppColors.magenta),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusFull)),
              ),
              onPressed: _waved ? null : () => setState(() => _waved = true),
              child: Text(_waved ? 'Waved' : 'Wave', style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w600, color: _waved ? AppColors.textSecondary : AppColors.magenta)),
            ),
          ),
        ],
      ),
    );
  }
}
