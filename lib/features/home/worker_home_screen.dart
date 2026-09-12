import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import 'widgets/home_map_section.dart';
import 'widgets/worker_field_selector.dart';

class WorkerHomeScreen extends StatefulWidget {
  const WorkerHomeScreen({
    super.key,
  });

  @override
  State<WorkerHomeScreen> createState() {
    return _WorkerHomeScreenState();
  }
}

class _WorkerHomeScreenState extends State<WorkerHomeScreen> {
  bool _isOnline = false;

  // First app open: Stats closed
  bool _showStats = false;

  int _selectedBottomIndex = 0;

  List<String> _selectedFields = [];

  void _openJobSelector() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return WorkerFieldSelector(
          selectedFields: _selectedFields,
          onContinue: (fields) {
            setState(() {
              _selectedFields = fields;
              _isOnline = true;
            });

            Navigator.pop(context);
          },
        );
      },
    );
  }

  void _toggleOnline() {
    if (_isOnline) {
      setState(() {
        _isOnline = false;
      });
    } else {
      _openJobSelector();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),

            // Go Online card
            _buildGoOnlineSection(),

            // Stats open / close button
            _buildStatsArrow(),

            // Stats are hidden initially
            if (_showStats) _buildStatsSection(),

            Expanded(
              child: Stack(
                children: [
                  _buildMapSection(),

                  if (_isOnline)
                    Positioned(
                      left: 16,
                      right: 16,
                      bottom: 18,
                      child: _buildMapActionButtons(),
                    ),
                ],
              ),
            ),

            _buildBottomNavigation(),
          ],
        ),
      ),
    );
  }

  // --------------------------------------------------
  // HEADER
  // --------------------------------------------------

  Widget _buildHeader() {
    return Container(
      height: 88,
      padding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 12,
      ),
      decoration: const BoxDecoration(
        color: AppColors.card,
        border: Border(
          bottom: BorderSide(
            color: AppColors.border,
          ),
        ),
      ),
      child: Row(
        children: [
          _buildHeaderButton(
            icon: Icons.menu_rounded,
            onTap: () {},
          ),

          const SizedBox(width: 14),

          const Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'HANDZY THOZHAN',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
                ),

                SizedBox(height: 4),

                Text(
                  'Your work. Your freedom.',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          _buildHeaderButton(
            icon: Icons.notifications_none_rounded,
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          color: AppColors.lightTeal,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Icon(
          icon,
          color: AppColors.primary,
          size: 27,
        ),
      ),
    );
  }

  // --------------------------------------------------
  // GO ONLINE SECTION
  // --------------------------------------------------

  Widget _buildGoOnlineSection() {
    return Container(
      margin: const EdgeInsets.fromLTRB(
        16,
        16,
        16,
        10,
      ),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _isOnline
            ? AppColors.lightTeal
            : AppColors.card,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: _isOnline
              ? AppColors.primary
              : AppColors.border,
          width: 1.2,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(
              color: AppColors.lightTeal,
              shape: BoxShape.circle,
            ),
            child: Icon(
              _isOnline
                  ? Icons.wifi_rounded
                  : Icons.wifi_off_rounded,
              color: AppColors.primary,
              size: 30,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isOnline
                      ? 'You are Online'
                      : 'Go Online',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  _isOnline
                      ? 'Ready to receive nearby jobs'
                      : 'Start receiving nearby work',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          Switch(
            value: _isOnline,
            activeThumbColor: AppColors.primary,
            activeTrackColor: AppColors.secondary,
            onChanged: (_) {
              _toggleOnline();
            },
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------
  // STATS ARROW
  // --------------------------------------------------

  Widget _buildStatsArrow() {
    return Center(
      child: InkWell(
        onTap: () {
          setState(() {
            _showStats = !_showStats;
          });
        },
        borderRadius: BorderRadius.circular(30),
        child: Container(
          width: 76,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.lightTeal,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: AppColors.border,
            ),
          ),
          child: Icon(
            _showStats
                ? Icons.keyboard_arrow_up_rounded
                : Icons.keyboard_arrow_down_rounded,
            color: AppColors.primary,
            size: 30,
          ),
        ),
      ),
    );
  }

  // --------------------------------------------------
  // STATS SECTION
  // --------------------------------------------------

  Widget _buildStatsSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        16,
        12,
        16,
        14,
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatsCard(
              icon: Icons.account_balance_wallet_outlined,
              value: '₹0.00',
              title: 'Wallet',
            ),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: _buildStatsCard(
              icon: Icons.bar_chart_rounded,
              value: '₹0.00',
              title: 'Today Earnings',
            ),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: _buildStatsCard(
              icon: Icons.receipt_long_outlined,
              value: '0',
              title: 'Recent Orders',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard({
    required IconData icon,
    required String value,
    required String title,
  }) {
    return Container(
      height: 124,
      padding: const EdgeInsets.all(13),
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
          Icon(
            icon,
            color: AppColors.primary,
            size: 28,
          ),

          const SizedBox(height: 10),

          Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------
  // MAP SECTION
  // --------------------------------------------------

  Widget _buildMapSection() {
    if (!_isOnline) {
      return Container(
        width: double.infinity,
        color: AppColors.background,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 84,
              height: 84,
              decoration: const BoxDecoration(
                color: AppColors.card,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.location_on_rounded,
                color: AppColors.primary,
                size: 48,
              ),
            ),

            const SizedBox(height: 18),

            const Text(
              'Nearby work area',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Go online to see nearby works',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    return const HomeMapSection();
  }

  // --------------------------------------------------
  // MAP BUTTONS
  // --------------------------------------------------

  Widget _buildMapActionButtons() {
    return Row(
      children: [
        Expanded(
          child: _buildMapButton(
            icon: Icons.currency_rupee_rounded,
            title: 'Super Areas',
            color: AppColors.secondary,
          ),
        ),

        const SizedBox(width: 8),

        Expanded(
          child: _buildMapButton(
            icon: Icons.location_on_rounded,
            title: 'Go to',
            color: AppColors.primary,
          ),
        ),

        const SizedBox(width: 8),

        Expanded(
          child: _buildMapButton(
            icon: Icons.arrow_upward_rounded,
            title: 'Surge',
            color: AppColors.secondary,
          ),
        ),
      ],
    );
  }

  Widget _buildMapButton({
    required IconData icon,
    required String title,
    required Color color,
  }) {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
      ),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: AppColors.border,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withValues(alpha:0.08),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: color,
            size: 22,
          ),

          const SizedBox(width: 5),

          Flexible(
            child: Text(
              title,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------
  // BOTTOM NAVIGATION
  // --------------------------------------------------

  Widget _buildBottomNavigation() {
    return Container(
      height: 84,
      padding: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 8,
      ),
      decoration: const BoxDecoration(
        color: AppColors.card,
        border: Border(
          top: BorderSide(
            color: AppColors.border,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildBottomItem(
              index: 0,
              icon: Icons.home_rounded,
              title: 'Home',
            ),
          ),

          Expanded(
            child: _buildBottomItem(
              index: 1,
              icon: Icons.receipt_long_rounded,
              title: 'Orders',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomItem({
    required int index,
    required IconData icon,
    required String title,
  }) {
    final bool isSelected =
        _selectedBottomIndex == index;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedBottomIndex = index;
        });
      },
      borderRadius: BorderRadius.circular(18),
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: 16,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.lightTeal
              : AppColors.card,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected
                  ? AppColors.primary
                  : AppColors.textSecondary,
              size: 28,
            ),

            const SizedBox(height: 3),

            Text(
              title,
              style: TextStyle(
                color: isSelected
                    ? AppColors.primary
                    : AppColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}