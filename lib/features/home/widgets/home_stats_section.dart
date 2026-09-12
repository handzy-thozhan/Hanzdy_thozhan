import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class HomeStatsSection extends StatelessWidget {
  final bool isExpanded;
  final VoidCallback onToggle;

  const HomeStatsSection({
    super.key,
    required this.isExpanded,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // V Shape Toggle Button
        Center(
          child: InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.circular(30),
            child: Container(
              width: 54,
              height: 34,
              decoration: BoxDecoration(
                color: AppColors.secondary.withValues(alpha:0.12),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: AppColors.border,
                ),
              ),
              child: Icon(
                isExpanded
                    ? Icons.keyboard_arrow_up_rounded
                    : Icons.keyboard_arrow_down_rounded,
                color: AppColors.primary,
                size: 28,
              ),
            ),
          ),
        ),

        AnimatedCrossFade(
          duration: const Duration(milliseconds: 250),
          crossFadeState: isExpanded
              ? CrossFadeState.showFirst
              : CrossFadeState.showSecond,
          firstChild: _expandedStats(),
          secondChild: const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _expandedStats() {
    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _statCard(
                  icon: Icons.account_balance_wallet_outlined,
                  title: 'Wallet',
                  value: '₹ 0.00',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _statCard(
                  icon: Icons.currency_rupee_rounded,
                  title: 'Today Earnings',
                  value: '₹ 0.00',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _statCard(
                  icon: Icons.receipt_long_outlined,
                  title: 'Recent Orders',
                  value: '0',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      constraints: const BoxConstraints(
        minHeight: 118,
      ),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: AppColors.primary,
            size: 24,
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}