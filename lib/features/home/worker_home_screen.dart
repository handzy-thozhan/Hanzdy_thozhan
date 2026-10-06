import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../menu/worker_menu_drawer.dart';
import '../order/worker_order_screen.dart';
import 'widgets/home_map_section.dart';
import 'widgets/worker_field_selector.dart';

class WorkerHomeScreen extends StatefulWidget {
  const WorkerHomeScreen({super.key});

  @override
  State<WorkerHomeScreen> createState() {
    return _WorkerHomeScreenState();
  }
}

class _WorkerHomeScreenState extends State<WorkerHomeScreen> {
  // --------------------------------------------------
  // INITIAL STATE
  // --------------------------------------------------

  bool _isOnline = false;
  bool _showStats = false;

  // Home selected when app opens
  int _selectedBottomIndex = 0;

  List<String> _selectedFields = [];

  // --------------------------------------------------
  // MENU
  // --------------------------------------------------

  void _openWorkerMenu() {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'Worker Menu',
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 280),
      pageBuilder: (
        context,
        animation,
        secondaryAnimation,
      ) {
        return WorkerMenuDrawer(
          onClose: () {
            Navigator.of(context).pop();
          },

          // PROFILE
          onProfile: () {
            Navigator.of(context).pop();

            // My Profile page will be connected later.
          },

          // HOME
          onHome: () {
            Navigator.of(context).pop();

            setState(() {
              _selectedBottomIndex = 0;
            });
          },

          // MY JOBS
          onJobs: () {
            Navigator.of(context).pop();

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => WorkerOrderScreen(
                  selectedFields: _selectedFields,
                ),
              ),
            );
          },

          // EARNINGS
          onEarnings: () {
            Navigator.of(context).pop();

            // Earnings page will be connected later.
          },

          // HELP
          onHelp: () {
            Navigator.of(context).pop();

            // Help & Support page later.
          },

          // SETTINGS
          onSettings: () {
            Navigator.of(context).pop();

            // Settings page later.
          },
        );
      },
      transitionBuilder: (
        context,
        animation,
        secondaryAnimation,
        child,
      ) {
        final slideAnimation = Tween<Offset>(
          begin: const Offset(-1.0, 0.0),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          ),
        );

        return SlideTransition(
          position: slideAnimation,
          child: child,
        );
      },
    );
  }

  // --------------------------------------------------
  // ONLINE LOGIC
  // --------------------------------------------------

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

  // --------------------------------------------------
  // OPEN ORDERS
  // --------------------------------------------------

  void _openOrders() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WorkerOrderScreen(
          selectedFields: _selectedFields,
        ),
      ),
    );
  }

  // --------------------------------------------------
  // BUILD
  // --------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),

            const SizedBox(height: 12),

            _buildOnlineStatusCard(),

            const SizedBox(height: 8),

            _buildStatsArrow(),

            if (_showStats) _buildStatsSection(),

            Expanded(
              child: _buildMainContent(),
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
      height: 95,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.headerMiddle,
            AppColors.headerEnd,
          ],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(
              alpha: 0.22,
            ),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Stack(
        children: [
          // ------------------------------------------------
          // HEADER CURVED ACCENT
          // ------------------------------------------------

          Positioned(
            right: -70,
            bottom: -80,
            child: Container(
              width: 280,
              height: 150,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(
                  alpha: 0.28,
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(200),
                ),
              ),
            ),
          ),

          // ------------------------------------------------
          // HEADER CONTENT
          // ------------------------------------------------

          Positioned(
            left: 16,
            right: 16,
            top: 12,
            child: Row(
              crossAxisAlignment:
                  CrossAxisAlignment.center,
              children: [
                // MENU BUTTON
                _buildHeaderButton(
                  icon: Icons.menu_rounded,
                  onTap: _openWorkerMenu,
                ),

                const SizedBox(width: 10),

                const Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Handzy Thozhan',
                        maxLines: 1,
                        overflow:
                            TextOverflow.ellipsis,
                        style: TextStyle(
                          color:
                              AppColors.textOnPrimary,
                          fontSize: 19,
                          fontWeight:
                              FontWeight.w800,
                          letterSpacing: -0.4,
                        ),
                      ),

                      SizedBox(height: 2),

                      Text(
                        'Your work. Your freedom.',
                        maxLines: 1,
                        overflow:
                            TextOverflow.ellipsis,
                        style: TextStyle(
                          color:
                              AppColors.lightMint,
                          fontSize: 11,
                          fontWeight:
                              FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 6),

                // NOTIFICATION BUTTON
                _buildHeaderButton(
                  icon:
                      Icons.notifications_none_rounded,
                  onTap: () {},
                ),
              ],
            ),
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
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.white.withValues(
            alpha: 0.12,
          ),
          borderRadius:
              BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.white.withValues(
              alpha: 0.12,
            ),
            width: 1,
          ),
        ),
        child: Icon(
          icon,
          color: AppColors.white,
          size: 27,
        ),
      ),
    );
  }

  // --------------------------------------------------
  // ONLINE STATUS CARD
  // --------------------------------------------------

  Widget _buildOnlineStatusCard() {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 22,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 13,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius:
            BorderRadius.circular(24),
        border: Border.all(
          color: _isOnline
              ? AppColors.onlineToggle
                  .withValues(alpha: 0.45)
              : AppColors.border,
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(
              alpha: 0.25,
            ),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          // WIFI ICON
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.lightMint,
              borderRadius:
                  BorderRadius.circular(18),
            ),
            child: Icon(
              _isOnline
                  ? Icons.wifi_rounded
                  : Icons.wifi_off_rounded,
              color: AppColors.primary,
              size: 33,
            ),
          ),

          const SizedBox(width: 13),

          // ONLINE TEXT
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  _isOnline
                      ? 'You’re Online'
                      : 'Go Online',
                  maxLines: 1,
                  overflow:
                      TextOverflow.ellipsis,
                  style: const TextStyle(
                    color:
                        AppColors.textPrimary,
                    fontSize: 19,
                    fontWeight:
                        FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 3),

                _buildSelectedWorkerText(),
              ],
            ),
          ),

          const SizedBox(width: 5),

          // ONLINE SWITCH
          Switch(
            value: _isOnline,
            activeThumbColor:
                AppColors.white,
            activeTrackColor:
                AppColors.onlineToggle,
            inactiveThumbColor:
                AppColors.white,
            inactiveTrackColor:
                AppColors.textSecondary
                    .withValues(alpha: 0.25),
            onChanged: (_) {
              _toggleOnline();
            },
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------
  // SELECTED WORKER FIELDS
  // --------------------------------------------------

  Widget _buildSelectedWorkerText() {
    if (!_isOnline) {
      return const Text(
        'Start receiving nearby work',
        maxLines: 1,
        overflow:
            TextOverflow.ellipsis,
        style: TextStyle(
          color: AppColors.textSecondary,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      );
    }

    if (_selectedFields.isEmpty) {
      return const Text(
        'Ready to receive nearby jobs',
        maxLines: 1,
        overflow:
            TextOverflow.ellipsis,
        style: TextStyle(
          color: AppColors.textSecondary,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      );
    }

    return Row(
      children: [
        const Text(
          'Serving:',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),

        const SizedBox(width: 5),

        Expanded(
          child: Text(
            _selectedFields.join(' • '),
            maxLines: 1,
            overflow:
                TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
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
        borderRadius:
            BorderRadius.circular(13),
        child: Container(
          width: 62,
          height: 38,
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius:
                BorderRadius.circular(13),
            border: Border.all(
              color: AppColors.border,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadow
                    .withValues(alpha: 0.22),
                blurRadius: 8,
                offset:
                    const Offset(0, 3),
              ),
            ],
          ),
          child: Icon(
            _showStats
                ? Icons.keyboard_arrow_up_rounded
                : Icons.keyboard_arrow_down_rounded,
            color: AppColors.darkIcon,
            size: 27,
          ),
        ),
      ),
    );
  }

  // --------------------------------------------------
  // STATS
  // --------------------------------------------------

  Widget _buildStatsSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        22,
        10,
        22,
        8,
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatsCard(
              icon:
                  Icons.account_balance_wallet_outlined,
              value: '₹0.00',
              title: 'Wallet',
              iconColor:
                  AppColors.primary,
            ),
          ),

          const SizedBox(width: 8),

          Expanded(
            child: _buildStatsCard(
              icon:
                  Icons.bar_chart_rounded,
              value: '₹0.00',
              title: 'Today',
              iconColor:
                  AppColors.primary,
            ),
          ),

          const SizedBox(width: 8),

          Expanded(
            child: _buildStatsCard(
              icon:
                  Icons.receipt_long_outlined,
              value: '0',
              title: 'Orders',
              iconColor:
                  AppColors.darkIcon,
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
    required Color iconColor,
  }) {
    return Container(
      height: 135,
      padding:
          const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius:
            BorderRadius.circular(21),
        border: Border.all(
          color: AppColors.border,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow
                .withValues(alpha: 0.18),
            blurRadius: 11,
            offset:
                const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment:
            MainAxisAlignment.center,
        children: [
          Container(
            width: 55,
            height: 55,
            decoration: BoxDecoration(
              color: iconColor ==
                      AppColors.darkIcon
                  ? AppColors.mapBackground
                  : AppColors.lightMint,
              borderRadius:
                  BorderRadius.circular(17),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 27,
            ),
          ),

          const SizedBox(height: 7),

          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: const TextStyle(
                color:
                    AppColors.textPrimary,
                fontSize: 18,
                fontWeight:
                    FontWeight.w800,
              ),
            ),
          ),

          const SizedBox(height: 2),

          Text(
            title,
            maxLines: 1,
            overflow:
                TextOverflow.ellipsis,
            style: const TextStyle(
              color:
                  AppColors.textSecondary,
              fontSize: 11,
              fontWeight:
                  FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------
  // MAIN CONTENT
  // --------------------------------------------------

  Widget _buildMainContent() {
    if (!_isOnline) {
      return _buildOfflineContent();
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        22,
        8,
        22,
        12,
      ),
      child: ClipRRect(
        borderRadius:
            BorderRadius.circular(25),
        child: const HomeMapSection(),
      ),
    );
  }

  // --------------------------------------------------
  // OFFLINE CONTENT
  // --------------------------------------------------

  Widget _buildOfflineContent() {
    return Center(
      child: Padding(
        padding:
            const EdgeInsets.symmetric(
          horizontal: 24,
        ),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                color: AppColors.lightMint,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadow
                        .withValues(alpha: 0.22),
                    blurRadius: 14,
                    offset:
                        const Offset(0, 5),
                  ),
                ],
              ),
              child: const Icon(
                Icons.location_on_rounded,
                color: AppColors.primary,
                size: 44,
              ),
            ),

            const SizedBox(height: 17),

            const Text(
              'Nearby work area',
              textAlign:
                  TextAlign.center,
              style: TextStyle(
                color:
                    AppColors.textPrimary,
                fontSize: 20,
                fontWeight:
                    FontWeight.w800,
              ),
            ),

            const SizedBox(height: 7),

            const Text(
              'Go online to see nearby works',
              textAlign:
                  TextAlign.center,
              style: TextStyle(
                color:
                    AppColors.textSecondary,
                fontSize: 13,
                fontWeight:
                    FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --------------------------------------------------
  // BOTTOM NAVIGATION
  // --------------------------------------------------

  Widget _buildBottomNavigation() {
    return Container(
      height: 78,
      padding:
          const EdgeInsets.symmetric(
        horizontal: 22,
        vertical: 6,
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
              icon:
                  Icons.receipt_long_rounded,
              title: 'Orders',
            ),
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------
  // BOTTOM NAV ITEM
  // --------------------------------------------------

  Widget _buildBottomItem({
    required int index,
    required IconData icon,
    required String title,
  }) {
    final bool isSelected =
        _selectedBottomIndex == index;

    return InkWell(
      onTap: () {
        // HOME
        if (index == 0) {
          setState(() {
            _selectedBottomIndex = 0;
          });

          return;
        }

        // ORDERS
        if (index == 1) {
          _openOrders();
        }
      },
      borderRadius:
          BorderRadius.circular(20),
      child: Container(
        margin:
            const EdgeInsets.symmetric(
          horizontal: 12,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.lightMint
              : AppColors.card,
          borderRadius:
              BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected
                  ? AppColors.bottomActive
                  : AppColors.textSecondary,
              size: 26,
            ),

            const SizedBox(height: 1),

            Text(
              title,
              style: TextStyle(
                color: isSelected
                    ? AppColors.bottomActive
                    : AppColors.textSecondary,
                fontSize: 12,
                fontWeight:
                    FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}