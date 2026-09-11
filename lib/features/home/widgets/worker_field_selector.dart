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

  final List<String> workerFields = [
    'Electrician',
    'Plumber',
    'Carpenter',
    'Painter',
    'AC Technician',
    'Cleaning',
    'Driver',
    'Delivery Partner',
    'Other Services',
  ];

  @override
  void initState() {
    super.initState();

    selectedFields = [
      ...widget.selectedFields,
    ];
  }

  void _selectField(String field) {
    setState(() {
      if (selectedFields.contains(field)) {
        selectedFields.remove(field);
      } else {
        if (selectedFields.length < 2) {
          selectedFields.add(field);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Select your working field',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 6),

          const Text(
            'Choose maximum 2 fields',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),

          const SizedBox(height: 16),

          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: workerFields.length,
            gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 2.8,
            ),
            itemBuilder: (context, index) {
              final field = workerFields[index];
              final isSelected =
                  selectedFields.contains(field);

              return InkWell(
                onTap: () {
                  _selectField(field);
                },
                borderRadius: BorderRadius.circular(12),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.lightTeal,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.border,
                    ),
                  ),
                  child: Text(
                    field,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isSelected
                          ? AppColors.textOnPrimary
                          : AppColors.textPrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 18),

          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: selectedFields.isEmpty
                  ? null
                  : () {
                      widget.onContinue(selectedFields);
                    },
              child: const Text(
                'Continue',
              ),
            ),
          ),
        ],
      ),
    );
  }
}