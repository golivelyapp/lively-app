import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';

/// Three separate numeric inputs (DD / MM / YYYY) with hard-typed
/// validation. Replaces the Material date picker, which on some Android
/// builds silently rejects out-of-range entries and offers no path back.
///
/// Emits [onChanged] whenever a valid, complete date parses. Emits null
/// for any partial or invalid input so the parent's "Continue" state
/// stays honest.
class DobInputField extends StatefulWidget {
  const DobInputField({required this.onChanged, super.key, this.initial});

  final ValueChanged<DateTime?> onChanged;
  final DateTime? initial;

  @override
  State<DobInputField> createState() => _DobInputFieldState();
}

class _DobInputFieldState extends State<DobInputField> {
  late final TextEditingController _day;
  late final TextEditingController _month;
  late final TextEditingController _year;
  final FocusNode _dayFocus = FocusNode();
  final FocusNode _monthFocus = FocusNode();
  final FocusNode _yearFocus = FocusNode();
  String? _error;

  @override
  void initState() {
    super.initState();
    _day = TextEditingController(
      text: widget.initial == null
          ? ''
          : widget.initial!.day.toString().padLeft(2, '0'),
    );
    _month = TextEditingController(
      text: widget.initial == null
          ? ''
          : widget.initial!.month.toString().padLeft(2, '0'),
    );
    _year = TextEditingController(
      text: widget.initial == null ? '' : widget.initial!.year.toString(),
    );
  }

  @override
  void dispose() {
    _day.dispose();
    _month.dispose();
    _year.dispose();
    _dayFocus.dispose();
    _monthFocus.dispose();
    _yearFocus.dispose();
    super.dispose();
  }

  void _validate() {
    final String d = _day.text.trim();
    final String m = _month.text.trim();
    final String y = _year.text.trim();

    if (d.isEmpty && m.isEmpty && y.isEmpty) {
      _updateError(null);
      widget.onChanged(null);
      return;
    }
    if (d.length < 1 || m.length < 1 || y.length < 4) {
      _updateError(null); // partial — quiet
      widget.onChanged(null);
      return;
    }

    final int? day = int.tryParse(d);
    final int? month = int.tryParse(m);
    final int? year = int.tryParse(y);
    if (day == null || month == null || year == null) {
      _updateError('Numbers only');
      widget.onChanged(null);
      return;
    }
    if (month < 1 || month > 12) {
      _updateError('Month must be 1–12');
      widget.onChanged(null);
      return;
    }
    if (day < 1 || day > _daysIn(month, year)) {
      _updateError('That day doesn\'t exist in ${_monthName(month)}');
      widget.onChanged(null);
      return;
    }
    final int currentYear = DateTime.now().year;
    if (year < 1900 || year > currentYear) {
      _updateError('Year must be between 1900 and $currentYear');
      widget.onChanged(null);
      return;
    }

    final DateTime candidate = DateTime(year, month, day);
    // 18+ gate. Compute age from candidate to today.
    final DateTime now = DateTime.now();
    int age = now.year - candidate.year;
    if (now.month < candidate.month ||
        (now.month == candidate.month && now.day < candidate.day)) {
      age--;
    }
    if (age < 18) {
      _updateError('You must be at least 18 to use Lively');
      widget.onChanged(null);
      return;
    }
    if (age > 100) {
      _updateError('Please check the year');
      widget.onChanged(null);
      return;
    }

    _updateError(null);
    widget.onChanged(candidate);
  }

  void _updateError(String? next) {
    if (_error != next) setState(() => _error = next);
  }

  static int _daysIn(int month, int year) {
    // Handles Feb leap years correctly.
    return DateTime(year, month + 1, 0).day;
  }

  static const List<String> _months = <String>[
    'January','February','March','April','May','June',
    'July','August','September','October','November','December',
  ];
  static String _monthName(int m) => _months[m - 1];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const Text('Date of Birth', style: AppTextStyles.bodySecondary),
          const SizedBox(height: AppSpacing.xs),
          Row(
            children: <Widget>[
              Expanded(
                child: _NumberField(
                  controller: _day,
                  focusNode: _dayFocus,
                  hint: 'DD',
                  maxLength: 2,
                  onChanged: (v) {
                    _validate();
                    if (v.length == 2) _monthFocus.requestFocus();
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _NumberField(
                  controller: _month,
                  focusNode: _monthFocus,
                  hint: 'MM',
                  maxLength: 2,
                  onChanged: (v) {
                    _validate();
                    if (v.length == 2) _yearFocus.requestFocus();
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: _NumberField(
                  controller: _year,
                  focusNode: _yearFocus,
                  hint: 'YYYY',
                  maxLength: 4,
                  onChanged: (_) => _validate(),
                ),
              ),
            ],
          ),
          if (_error != null) ...<Widget>[
            const SizedBox(height: 4),
            Text(
              _error!,
              style: AppTextStyles.caption.copyWith(color: AppColors.error),
            ),
          ],
        ],
      ),
    );
  }
}

class _NumberField extends StatelessWidget {
  const _NumberField({
    required this.controller,
    required this.focusNode,
    required this.hint,
    required this.maxLength,
    required this.onChanged,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final String hint;
  final int maxLength;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      keyboardType: TextInputType.number,
      textAlign: TextAlign.center,
      maxLength: maxLength,
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(maxLength),
      ],
      decoration: InputDecoration(
        hintText: hint,
        counterText: '',
      ),
      style: AppTextStyles.body,
      onChanged: onChanged,
    );
  }
}
