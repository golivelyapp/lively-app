import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../models/profile_prompt.dart';

const int promptMaxLength = 150;

/// One numbered, character-counted card in a prompt-list step (Favourite
/// Musicians, Movies, Books, Dishes, Places, Games & Sports all share this).
class PromptListField extends StatelessWidget {
  const PromptListField({
    required this.prompt,
    required this.controller,
    required this.onChanged,
    super.key,
  });

  final ProfilePrompt prompt;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        boxShadow: const <BoxShadow>[
          BoxShadow(color: Color(0x0F000000), blurRadius: 8),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('${prompt.index}', style: AppTextStyles.button.copyWith(color: AppColors.textPrimary)),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                TextField(
                  maxLength: promptMaxLength,
                  maxLines: 3,
                  minLines: 1,
                  controller: controller,
                  onChanged: onChanged,
                  style: AppTextStyles.body,
                  decoration: InputDecoration(
                    isDense: true,
                    filled: false,
                    contentPadding: EdgeInsets.zero,
                    border: InputBorder.none,
                    counterText: '',
                    hintText: prompt.placeholder,
                    hintStyle: AppTextStyles.bodySecondary,
                  ),
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Text(
                    '${prompt.answer.length}/$promptMaxLength',
                    style: AppTextStyles.caption,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
