import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class WorkerFieldSelector extends StatefulWidget {
  final List<String> selectedFields;
  final ValueChanged<List<String>> onContinue;

  const WorkerFieldSelector({
    super.key,
    required this.selectedFields,
    required this.onContinue,
  });

  @override
  State<WorkerFieldSelector> createState() {
    return _WorkerFieldSelectorState();
  }
}

class _WorkerFieldSelectorState
    extends State<WorkerFieldSelector> {
  late List<String> selectedFields;

  final List<String> jobFields = [
    'Plumber',
    'Electrician',
    'Carpenter',
    'Painter',
    'AC Service',
    'Cleaning',
    'Lifting & Moving',
    'Others',
  ];

  @override
  void initState() {
    super.initState();

    selectedFields = List<String>.from(
      widget.selectedFields,
    );
  }

  void _toggleField(String field) {
    setState(() {
      if (selectedFields.contains(field)) {
        selectedFields.remove(field);
        return;
      }

      if (selectedFields.length >= 2) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'You can select maximum 2 jobs',
            ),
          ),
        );
        return;
      }

      selectedFields.add(field);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(
          20,
          22,
          20,
          20,
        ),
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(28),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),

            const SizedBox(height: 22),

            const Text(
              'Choose your work',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              'Select maximum 2 job fields',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 18),

            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: jobFields.length,
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 2.7,
              ),
              itemBuilder: (context, index) {
                final field = jobFields[index];
                final isSelected =
                    selectedFields.contains(field);

                return InkWell(
                  onTap: () {
                    _toggleField(field);
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.lightTeal
                          : AppColors.card,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.border,
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            field,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.textPrimary,
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        Icon(
                          isSelected
                              ? Icons.check_circle_rounded
                              : Icons.circle_outlined,
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.textSecondary,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 22),

            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: selectedFields.isEmpty
                    ? null
                    : () {
                        widget.onContinue(selectedFields);
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  disabledBackgroundColor: AppColors.border,
                  foregroundColor: AppColors.textOnPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Continue',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}