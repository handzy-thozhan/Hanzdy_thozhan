import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

import 'widgets/home_header.dart';
import 'widgets/online_status_section.dart';
import 'widgets/home_stats_section.dart';
import 'widgets/home_map_section.dart';
import 'widgets/home_bottom_navigation.dart';

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
  bool isOnline = false;

  bool showStats = false;

  List<String> selectedWorkerFields = [];

  int currentIndex = 0;

  void _updateOnlineStatus(bool value) {
    setState(() {
      isOnline = value;
    });
  }

  void _updateWorkerFields(List<String> fields) {
    setState(() {
      selectedWorkerFields = fields;
    });
  }

  void _toggleStats() {
    setState(() {
      showStats = !showStats;
    });
  }

  void _openMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(26),
        ),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 42,
                  height: 5,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),

                const SizedBox(height: 22),

                const CircleAvatar(
                  radius: 32,
                  backgroundColor: AppColors.lightTeal,
                  child: Icon(
                    Icons.person_rounded,
                    color: AppColors.primary,
                    size: 36,
                  ),
                ),

                const SizedBox(height: 10),

                const Text(
                  'Handzy Thozhan',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 20),

                _menuItem(
                  icon: Icons.person_outline_rounded,
                  title: 'Profile',
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),

                _menuItem(
                  icon: Icons.receipt_long_outlined,
                  title: 'My Jobs',
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),

                _menuItem(
                  icon: Icons.currency_rupee_rounded,
                  title: 'Earnings',
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),

                _menuItem(
                  icon: Icons.help_outline_rounded,
                  title: 'Help & Support',
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),

                _menuItem(
                  icon: Icons.settings_outlined,
                  title: 'Settings',
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _menuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Icon(
        icon,
        color: AppColors.primary,
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right_rounded,
        color: AppColors.textSecondary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(
                  16,
                  14,
                  16,
                  20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    HomeHeader(
                      onMenuTap: _openMenu,
                      onNotificationTap: () {},
                    ),

                    const SizedBox(height: 22),

                    OnlineStatusSection(
                      isOnline: isOnline,
                      selectedFields: selectedWorkerFields,
                      onStatusChanged: _updateOnlineStatus,
                      onFieldsChanged: _updateWorkerFields,
                    ),

                    const SizedBox(height: 12),

                    if (isOnline &&
                        selectedWorkerFields.isNotEmpty)
                      Text(
                        selectedWorkerFields.join(' • '),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),

                    const SizedBox(height: 12),

                    HomeStatsSection(
                      isExpanded: showStats,
                      onToggle: _toggleStats,
                    ),

                    const SizedBox(height: 20),

                    const HomeMapSection(),
                  ],
                ),
              ),
            ),

            HomeBottomNavigation(
              currentIndex: currentIndex,
              onItemSelected: (index) {
                setState(() {
                  currentIndex = index;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}