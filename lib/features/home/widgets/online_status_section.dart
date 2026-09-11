import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import 'worker_field_selector.dart';

class OnlineStatusSection extends StatefulWidget {
  final bool isOnline;
  final List<String> selectedFields;
  final ValueChanged<bool> onStatusChanged;
  final ValueChanged<List<String>> onFieldsChanged;

  const OnlineStatusSection({
    super.key,
    required this.isOnline,
    required this.selectedFields,
    required this.onStatusChanged,
    required this.onFieldsChanged,
  });

  @override
  State<OnlineStatusSection> createState() {
    return _OnlineStatusSectionState();
  }
}

class _OnlineStatusSectionState
    extends State<OnlineStatusSection> {
  bool showFieldSelector = false;

  void _handleOnlineTap() {
    if (widget.isOnline) {
      widget.onStatusChanged(false);
      return;
    }

    setState(() {
      showFieldSelector = true;
    });
  }

  void _handleContinue(List<String> fields) {
    widget.onFieldsChanged(fields);

    widget.onStatusChanged(true);

    setState(() {
      showFieldSelector = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: widget.isOnline
                ? AppColors.lightTeal
                : AppColors.card,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: widget.isOnline
                  ? AppColors.primary
                  : AppColors.border,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: widget.isOnline
                      ? AppColors.primary
                      : AppColors.lightTeal,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  widget.isOnline
                      ? Icons.wifi_rounded
                      : Icons.wifi_off_rounded,
                  color: widget.isOnline
                      ? AppColors.textOnPrimary
                      : AppColors.primary,
                  size: 27,
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.isOnline
                          ? 'You are Online'
                          : 'Go Online',
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.isOnline
                          ? 'Ready to receive nearby jobs'
                          : 'Start receiving nearby work',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

              Switch(
                value: widget.isOnline,
                activeColor: AppColors.primary,
                activeTrackColor: AppColors.secondary,
                onChanged: (_) {
                  _handleOnlineTap();
                },
              ),
            ],
          ),
        ),

        const SizedBox(height: 10),

        if (widget.isOnline &&
            widget.selectedFields.isNotEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.lightTeal,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.work_outline_rounded,
                  color: AppColors.primary,
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: Text(
                    widget.selectedFields.join(' • '),
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),

                IconButton(
                  onPressed: () {
                    setState(() {
                      showFieldSelector = true;
                    });
                  },
                  icon: const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),

        if (showFieldSelector) ...[
          const SizedBox(height: 12),

          WorkerFieldSelector(
            selectedFields: widget.selectedFields,
            onContinue: _handleContinue,
          ),
        ],
      ],
    );
  }
}