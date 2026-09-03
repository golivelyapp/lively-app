import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/photo_image_provider.dart';
import '../../../core/widgets/gradient_button.dart';
import '../../../core/widgets/pill_toggle.dart';
import '../../home/models/event.dart';
import '../../home/models/event_category.dart';
import '../../home/providers/event_providers.dart';
import '../../home/widgets/event_card.dart';
import '../../home/widgets/gender_balance_bar.dart';
import '../../onboarding/providers/onboarding_draft_controller.dart';

const List<String> _popularVenues = <String>[
  'Indiranagar', 'HSR Layout', 'Koramangala',
];

/// 12-hour AM/PM formatter that ignores the device locale — same shape
/// as the display formatters used across the app.
String _format12h(TimeOfDay t) {
  final int h = t.hour % 12 == 0 ? 12 : t.hour % 12;
  final String m = t.minute.toString().padLeft(2, '0');
  final String p = t.hour < 12 ? 'AM' : 'PM';
  return '$h:$m $p';
}

class CreateEventScreen extends ConsumerStatefulWidget {
  const CreateEventScreen({super.key});

  @override
  ConsumerState<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends ConsumerState<CreateEventScreen> {
  int _step = 0;
  static const int _totalSteps = 6;

  final TextEditingController _title = TextEditingController();
  final TextEditingController _description = TextEditingController();
  EventCategory? _category;

  DateTime _date = DateTime.now().add(const Duration(days: 2));
  TimeOfDay _time = const TimeOfDay(hour: 18, minute: 0);
  int _durationMinutes = 120;
  final TextEditingController _venueName = TextEditingController();
  final TextEditingController _venueAddress = TextEditingController();

  double _totalSpots = 20;
  double _malePercent = 50;

  // Per-gender pricing. "Free" toggles are the default so the user can
  // publish a free event without typing anything.
  bool _isFreeWomen = true;
  bool _isFreeMen = true;
  final TextEditingController _priceWomen = TextEditingController();
  final TextEditingController _priceMen = TextEditingController();

  String? _coverPhotoPath;

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _venueName.dispose();
    _venueAddress.dispose();
    _priceWomen.dispose();
    _priceMen.dispose();
    super.dispose();
  }

  int? _parsePrice(TextEditingController c) {
    final String s = c.text.trim();
    if (s.isEmpty) return null;
    return int.tryParse(s);
  }

  bool _genderPriceOk(bool isFree, TextEditingController c) {
    if (isFree) return true;
    final int? v = _parsePrice(c);
    return v != null && v > 0;
  }

  bool get _canContinue => switch (_step) {
    0 => _title.text.trim().isNotEmpty && _category != null,
    // Duration is validated on value>0, not on "user has interacted with
    // the slider". The default of 120 minutes is already valid — don't
    // gate Continue on the user touching it.
    1 => _venueName.text.trim().isNotEmpty && _durationMinutes > 0,
    // Pricing is complete when EACH gender has either a valid price>0
    // or its Free toggle on. Re-evaluated on every price onChanged.
    3 => _genderPriceOk(_isFreeWomen, _priceWomen) &&
         _genderPriceOk(_isFreeMen, _priceMen),
    4 => _coverPhotoPath != null,
    _ => true,
  };

  DateTime get _startTime => DateTime(_date.year, _date.month, _date.day, _time.hour, _time.minute);

  bool _publishing = false;

  Future<void> _publish() async {
    if (_publishing) return;
    final int priceWomen = _isFreeWomen ? 0 : (_parsePrice(_priceWomen) ?? 0);
    final int priceMen = _isFreeMen ? 0 : (_parsePrice(_priceMen) ?? 0);
    // Legacy single price kept for older readers — use the max so screens
    // that show "one price" don't understate it.
    final int legacyPrice = priceWomen > priceMen ? priceWomen : priceMen;

    setState(() => _publishing = true);
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(color: AppColors.black),
      ),
    );

    try {
      await ref.read(eventRepositoryProvider).createEvent(
            title: _title.text.trim(),
            description: _description.text.trim(),
            category: _category!,
            startTime: _startTime,
            durationMinutes: _durationMinutes,
            venueName: _venueName.text.trim(),
            venueAddress: _venueAddress.text.trim(),
            totalSpots: _totalSpots.round(),
            priceRupees: legacyPrice,
            priceRupeesWomen: priceWomen,
            priceRupeesMen: priceMen,
            coverImage: File(_coverPhotoPath!),
          );
      // Pull the fresh feed so the new event shows up on Home right away.
      await ref.read(eventsProvider.notifier).refresh();
      // Reset the Home category pill to "All" — otherwise a published
      // event whose category doesn't match the user's current pill is
      // filtered out on the feed and the host thinks it didn't save.
      ref.read(homeFilterProvider.notifier).state = 'all';
      ref.read(dateFilterProvider.notifier).state = DateFilter.anytime;
      if (!mounted) return;
      Navigator.of(context, rootNavigator: true).pop(); // dismiss loader
      Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context, rootNavigator: true).pop(); // dismiss loader
      setState(() => _publishing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not publish event: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.black),
          onPressed: () => _step == 0 ? Navigator.of(context).pop() : setState(() => _step--),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: ClipRRect(
            child: LinearProgressIndicator(
              value: (_step + 1) / _totalSteps,
              minHeight: 4,
              backgroundColor: AppColors.lockChip,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.black),
            ),
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: <Widget>[
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: _buildStep(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: GradientButton(
                label: _step == _totalSteps - 1 ? 'Publish' : 'Continue',
                onPressed: (_canContinue && !_publishing)
                    ? () => _step == _totalSteps - 1 ? _publish() : setState(() => _step++)
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep() {
    return switch (_step) {
      0 => _BasicsStep(
          title: _title,
          description: _description,
          category: _category,
          onCategory: (c) => setState(() => _category = c),
          onTextChanged: () => setState(() {}),
        ),
      1 => _WhenWhereStep(
          date: _date,
          time: _time,
          durationMinutes: _durationMinutes,
          venueName: _venueName,
          venueAddress: _venueAddress,
          onPickDate: (d) => setState(() => _date = d),
          onPickTime: (t) => setState(() => _time = t),
          onDuration: (m) => setState(() => _durationMinutes = m),
          onTextChanged: () => setState(() {}),
        ),
      2 => _CapacityStep(
          totalSpots: _totalSpots,
          malePercent: _malePercent,
          onSpots: (v) => setState(() => _totalSpots = v),
          onMalePercent: (v) => setState(() => _malePercent = v),
        ),
      3 => _PricingStep(
          isFreeWomen: _isFreeWomen,
          isFreeMen: _isFreeMen,
          priceWomen: _priceWomen,
          priceMen: _priceMen,
          onIsFreeWomen: (v) => setState(() => _isFreeWomen = v),
          onIsFreeMen: (v) => setState(() => _isFreeMen = v),
          // Bug 6: revalidate on every keystroke, not just on toggle.
          onPriceChanged: () => setState(() {}),
        ),
      4 => _PhotosStep(coverPhotoPath: _coverPhotoPath, onPicked: (p) => setState(() => _coverPhotoPath = p)),
      _ => _PreviewStep(event: _buildPreviewEvent()),
    };
  }

  Event _buildPreviewEvent() {
    final draft = ref.read(onboardingDraftProvider);
    // floor() → any leftover spot goes to women, matching the display rule.
    final int male = ((_totalSpots * _malePercent) / 100).floor();
    final int previewPriceWomen = _isFreeWomen ? 0 : (_parsePrice(_priceWomen) ?? 0);
    final int previewPriceMen = _isFreeMen ? 0 : (_parsePrice(_priceMen) ?? 0);
    final int previewLegacy = previewPriceWomen > previewPriceMen
        ? previewPriceWomen
        : previewPriceMen;
    return Event(
      id: 'preview',
      title: _title.text.trim().isEmpty ? 'Your event title' : _title.text.trim(),
      coverImageUrl: _coverPhotoPath ?? '',
      category: _category ?? EventCategory.boardGames,
      hostId: 'me',
      hostName: draft.name ?? 'You',
      hostPhotoUrl: draft.profilePhotoPath ?? '',
      hostVerified: true,
      hostBio: '',
      hostEventsHosted: 0,
      hostRating: 5,
      startTime: _startTime,
      durationMinutes: _durationMinutes,
      venueName: _venueName.text.trim(),
      venueAddress: _venueAddress.text.trim(),
      neighbourhood: _venueAddress.text.trim().split(',').last.trim(),
      priceRupees: previewLegacy,
      priceRupeesWomen: previewPriceWomen,
      priceRupeesMen: previewPriceMen,
      totalSpots: _totalSpots.round(),
      maleRsvpCount: male,
      femaleRsvpCount: _totalSpots.round() - male,
      attendeeAvatarUrls: const <String>[],
      description: _description.text.trim(),
    );
  }
}

class _StepTitle extends StatelessWidget {
  const _StepTitle(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: AppSpacing.lg),
    child: Text(text, style: AppTextStyles.displayLg),
  );
}

class _BasicsStep extends StatelessWidget {
  const _BasicsStep({
    required this.title,
    required this.description,
    required this.category,
    required this.onCategory,
    required this.onTextChanged,
  });

  final TextEditingController title;
  final TextEditingController description;
  final EventCategory? category;
  final ValueChanged<EventCategory> onCategory;
  final VoidCallback onTextChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const _StepTitle('Basics'),
        const Text('Event title', style: AppTextStyles.bodySecondary),
        const SizedBox(height: AppSpacing.xs),
        TextField(
          controller: title,
          onChanged: (_) => onTextChanged(),
          decoration: const InputDecoration(hintText: 'Art Jam & Wine'),
        ),
        const SizedBox(height: AppSpacing.md),
        const Text('Category', style: AppTextStyles.bodySecondary),
        const SizedBox(height: AppSpacing.xs),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: <Widget>[
            for (final EventCategory c in EventCategory.values)
              PillToggle(label: c.label, icon: c.icon, selected: category == c, onTap: () => onCategory(c)),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        const Text('Description', style: AppTextStyles.bodySecondary),
        const SizedBox(height: AppSpacing.xs),
        TextField(
          controller: description,
          maxLines: 4,
          decoration: const InputDecoration(hintText: 'What should people expect?'),
        ),
      ],
    );
  }
}

class _WhenWhereStep extends StatelessWidget {
  const _WhenWhereStep({
    required this.date,
    required this.time,
    required this.durationMinutes,
    required this.venueName,
    required this.venueAddress,
    required this.onPickDate,
    required this.onPickTime,
    required this.onDuration,
    required this.onTextChanged,
  });

  final DateTime date;
  final TimeOfDay time;
  final int durationMinutes;
  final TextEditingController venueName;
  final TextEditingController venueAddress;
  final ValueChanged<DateTime> onPickDate;
  final ValueChanged<TimeOfDay> onPickTime;
  final ValueChanged<int> onDuration;
  final VoidCallback onTextChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const _StepTitle('When & Where'),
        Row(
          children: <Widget>[
            Expanded(
              child: OutlinedButton(
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: date,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (picked != null) onPickDate(picked);
                },
                child: Text('${date.day}/${date.month}/${date.year}'),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: OutlinedButton(
                onPressed: () async {
                  // Force 12-hour AM/PM regardless of the device locale.
                  final picked = await showTimePicker(
                    context: context,
                    initialTime: time,
                    builder: (ctx, child) => MediaQuery(
                      data: MediaQuery.of(ctx).copyWith(alwaysUse24HourFormat: false),
                      child: child!,
                    ),
                  );
                  if (picked != null) onPickTime(picked);
                },
                child: Text(_format12h(time)),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Text('Duration: $durationMinutes min', style: AppTextStyles.bodySecondary),
        Slider(
          value: durationMinutes.toDouble(),
          min: 30,
          max: 300,
          divisions: 18,
          activeColor: AppColors.magenta,
          onChanged: (v) => onDuration(v.round()),
        ),
        const SizedBox(height: AppSpacing.md),
        const Text('Venue name', style: AppTextStyles.bodySecondary),
        const SizedBox(height: AppSpacing.xs),
        TextField(
          controller: venueName,
          onChanged: (_) => onTextChanged(),
          decoration: const InputDecoration(hintText: 'Studio Canvas'),
        ),
        const SizedBox(height: AppSpacing.md),
        const Text('Address', style: AppTextStyles.bodySecondary),
        const SizedBox(height: AppSpacing.xs),
        TextField(
          controller: venueAddress,
          onChanged: (_) => onTextChanged(),
          decoration: const InputDecoration(hintText: 'Street, area'),
        ),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.xs,
          children: <Widget>[
            for (final String v in _popularVenues)
              ActionChip(
                label: Text(v, style: AppTextStyles.caption),
                backgroundColor: AppColors.surface,
                side: BorderSide.none,
                onPressed: () => venueAddress.text = v,
              ),
          ],
        ),
      ],
    );
  }
}

class _CapacityStep extends StatelessWidget {
  const _CapacityStep({
    required this.totalSpots,
    required this.malePercent,
    required this.onSpots,
    required this.onMalePercent,
  });

  final double totalSpots;
  final double malePercent;
  final ValueChanged<double> onSpots;
  final ValueChanged<double> onMalePercent;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const _StepTitle('Capacity & Ratio'),
        Text('Total spots: ${totalSpots.round()}', style: AppTextStyles.bodySecondary),
        Slider(
          value: totalSpots,
          min: 8,
          max: 40,
          divisions: 32,
          activeColor: AppColors.magenta,
          onChanged: onSpots,
        ),
        const SizedBox(height: AppSpacing.md),
        const Text('How should spots be divided?', style: AppTextStyles.bodySecondary),
        const SizedBox(height: AppSpacing.sm),
        GenderBalanceBar(maleRatio: malePercent / 100, height: 10),
        const SizedBox(height: AppSpacing.xs),
        Builder(builder: (_) {
          // Convert ratio → headcount. If the split leaves an odd extra
          // spot (e.g. 50/50 of 21), it goes to women.
          final int total = totalSpots.round();
          final int male = (total * malePercent / 100).floor();
          final int female = total - male;
          return Text(
            '$female women · $male men',
            style: AppTextStyles.caption,
          );
        }),
        Slider(
          value: malePercent,
          min: 0,
          max: 100,
          activeColor: AppColors.coral,
          onChanged: onMalePercent,
        ),
      ],
    );
  }
}

class _PricingStep extends StatelessWidget {
  const _PricingStep({
    required this.isFreeWomen,
    required this.isFreeMen,
    required this.priceWomen,
    required this.priceMen,
    required this.onIsFreeWomen,
    required this.onIsFreeMen,
    required this.onPriceChanged,
  });

  final bool isFreeWomen;
  final bool isFreeMen;
  final TextEditingController priceWomen;
  final TextEditingController priceMen;
  final ValueChanged<bool> onIsFreeWomen;
  final ValueChanged<bool> onIsFreeMen;
  final VoidCallback onPriceChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const _StepTitle('Pricing'),
        _GenderPriceRow(
          label: 'For women',
          isFree: isFreeWomen,
          price: priceWomen,
          onIsFree: onIsFreeWomen,
          onPriceChanged: onPriceChanged,
        ),
        const SizedBox(height: AppSpacing.md),
        _GenderPriceRow(
          label: 'For men',
          isFree: isFreeMen,
          price: priceMen,
          onIsFree: onIsFreeMen,
          onPriceChanged: onPriceChanged,
        ),
        const SizedBox(height: AppSpacing.md),
        const Text(
          'Money goes straight to you — Lively takes no cut right now.',
          style: AppTextStyles.caption,
        ),
      ],
    );
  }
}

class _GenderPriceRow extends StatelessWidget {
  const _GenderPriceRow({
    required this.label,
    required this.isFree,
    required this.price,
    required this.onIsFree,
    required this.onPriceChanged,
  });

  final String label;
  final bool isFree;
  final TextEditingController price;
  final ValueChanged<bool> onIsFree;
  final VoidCallback onPriceChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(label, style: AppTextStyles.bodySecondary),
        const SizedBox(height: AppSpacing.xs),
        Row(
          children: <Widget>[
            PillToggle(label: 'Free', selected: isFree, onTap: () => onIsFree(true)),
            const SizedBox(width: AppSpacing.sm),
            PillToggle(label: 'Paid', selected: !isFree, onTap: () => onIsFree(false)),
          ],
        ),
        if (!isFree) ...<Widget>[
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: price,
            keyboardType: TextInputType.number,
            onChanged: (_) => onPriceChanged(),
            decoration: const InputDecoration(hintText: 'Amount in ₹'),
          ),
        ],
      ],
    );
  }
}

class _PhotosStep extends StatelessWidget {
  const _PhotosStep({required this.coverPhotoPath, required this.onPicked});

  final String? coverPhotoPath;
  final ValueChanged<String> onPicked;

  Future<void> _pick() async {
    final XFile? file = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (file != null) onPicked(file.path);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const _StepTitle('Photos'),
        const Text('Cover photo', style: AppTextStyles.bodySecondary),
        const SizedBox(height: AppSpacing.xs),
        GestureDetector(
          onTap: _pick,
          child: Container(
            height: 180,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              image: coverPhotoPath == null
                  ? null
                  : DecorationImage(image: photoImageProvider(coverPhotoPath)!, fit: BoxFit.cover),
            ),
            child: coverPhotoPath == null
                ? const Icon(Icons.add_a_photo_outlined, size: 32, color: AppColors.textSecondary)
                : null,
          ),
        ),
      ],
    );
  }
}

class _PreviewStep extends StatelessWidget {
  const _PreviewStep({required this.event});

  final Event event;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const _StepTitle('Preview & Publish'),
        EventCard(event: event, onTap: () {}),
      ],
    );
  }
}
