import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class WorkerOrderScreen extends StatefulWidget {
  // --------------------------------------------------
  // SELECTED SERVICES FROM HOME SCREEN
  // --------------------------------------------------

  final List<String> selectedFields;

  const WorkerOrderScreen({
    super.key,
    required this.selectedFields,
  });

  @override
  State<WorkerOrderScreen> createState() =>
      _WorkerOrderScreenState();
}

class _WorkerOrderScreenState extends State<WorkerOrderScreen> {
  // --------------------------------------------------
  // SELECTED SERVICES
  // --------------------------------------------------
  // This now comes from Worker Home Screen.
  // No temporary hardcoded services here.

  int _selectedTab = 0;

  // Temporary sample orders.
  // Later Firebase orders will come here.
  final List<Map<String, dynamic>> _orders = [
    {
      'orderId': '#HZ1024',
      'service': 'Plumbing Service',
      'customer': 'Ramesh Kumar',
      'location': 'Gandhipuram, Coimbatore',
      'distance': '2.4 km',
      'amount': '₹450',
      'time': '8 min ago',
      'icon': Icons.plumbing_rounded,
    },
    {
      'orderId': '#HZ1025',
      'service': 'Electrical Service',
      'customer': 'Suresh A',
      'location': 'RS Puram, Coimbatore',
      'distance': '3.1 km',
      'amount': '₹600',
      'time': '35 min ago',
      'icon': Icons.bolt_rounded,
    },
  ];

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

            Expanded(
              child: _buildBody(),
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
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(
              alpha: 0.20,
            ),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
        ),
        child: Row(
          children: [
            const SizedBox(width: 4),

            const Expanded(
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.center,
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    'Orders',
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Manage your work',
                    style: TextStyle(
                      color: AppColors.lightMint,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
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
      ),
    );
  }

  Widget _buildHeaderButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.white.withValues(
            alpha: 0.12,
          ),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(
          icon,
          color: AppColors.white,
          size: 24,
        ),
      ),
    );
  }

  // --------------------------------------------------
  // BODY
  // --------------------------------------------------

  Widget _buildBody() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        16,
        14,
        16,
        16,
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          _buildServicesSection(),

          const SizedBox(height: 18),

          _buildOrderTabs(),

          const SizedBox(height: 14),

          _buildOrderList(),
        ],
      ),
    );
  }

  // --------------------------------------------------
  // SELECTED SERVICES
  // --------------------------------------------------

  Widget _buildServicesSection() {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        const Text(
          'Your Services',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),

        const SizedBox(height: 9),

        SizedBox(
          height: 42,
          child: widget.selectedFields.isEmpty
              ? const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'No services selected',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                )
              : ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: widget.selectedFields.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    return _buildServiceChip(
                      widget.selectedFields[index],
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildServiceChip(String service) {
    IconData icon;

    switch (service.toLowerCase()) {
      case 'plumber':
        icon = Icons.plumbing_rounded;
        break;

      case 'electrician':
        icon = Icons.bolt_rounded;
        break;

      case 'carpenter':
        icon = Icons.handyman_rounded;
        break;

      case 'painter':
        icon = Icons.format_paint_rounded;
        break;

      case 'ac service':
        icon = Icons.ac_unit_rounded;
        break;

      case 'cleaning':
        icon = Icons.cleaning_services_rounded;
        break;

      default:
        icon = Icons.work_outline_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 13,
      ),
      decoration: BoxDecoration(
        color: AppColors.lightMint,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: AppColors.primary,
            size: 19,
          ),

          const SizedBox(width: 6),

          Text(
            service,
            style: const TextStyle(
              color: AppColors.darkTeal,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------
  // ORDER TABS
  // --------------------------------------------------

  Widget _buildOrderTabs() {
    final tabs = [
      'New',
      'Accepted',
      'In Progress',
      'Completed',
    ];

    return Container(
      height: 46,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Row(
        children: List.generate(
          tabs.length,
          (index) {
            final bool selected =
                _selectedTab == index;

            return Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedTab = index;
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: selected
                        ? AppColors.primary
                        : Colors.transparent,
                    borderRadius:
                        BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    tabs[index],
                    style: TextStyle(
                      color: selected
                          ? AppColors.white
                          : AppColors.textSecondary,
                      fontSize: 11,
                      fontWeight: selected
                          ? FontWeight.w800
                          : FontWeight.w600,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // --------------------------------------------------
  // ORDER LIST
  // --------------------------------------------------

  Widget _buildOrderList() {
    if (_orders.isEmpty) {
      return _buildEmptyOrders();
    }

    return Column(
      children: _orders.map((order) {
        return Padding(
          padding: const EdgeInsets.only(
            bottom: 12,
          ),
          child: _buildOrderCard(order),
        );
      }).toList(),
    );
  }

  // --------------------------------------------------
  // ORDER CARD
  // --------------------------------------------------

  Widget _buildOrderCard(
    Map<String, dynamic> order,
  ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.border,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(
              alpha: 0.18,
            ),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.lightMint,
                  borderRadius:
                      BorderRadius.circular(14),
                ),
                child: Icon(
                  order['icon'] as IconData,
                  color: AppColors.primary,
                  size: 25,
                ),
              ),

              const SizedBox(width: 11),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      order['orderId'],
                      style: const TextStyle(
                        color:
                            AppColors.textPrimary,
                        fontSize: 15,
                        fontWeight:
                            FontWeight.w800,
                      ),
                    ),

                    const SizedBox(height: 2),

                    Text(
                      order['time'],
                      style: const TextStyle(
                        color:
                            AppColors.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 9,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color:
                      AppColors.mintBackground,
                  borderRadius:
                      BorderRadius.circular(10),
                ),
                child: const Text(
                  'New',
                  style: TextStyle(
                    color: AppColors.success,
                    fontSize: 10,
                    fontWeight:
                        FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Text(
            order['service'],
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 9),

          _buildOrderInfo(
            icon: Icons.person_outline_rounded,
            text: order['customer'],
          ),

          const SizedBox(height: 6),

          _buildOrderInfo(
            icon: Icons.location_on_outlined,
            text:
                '${order['distance']} • ${order['location']}',
          ),

          const SizedBox(height: 6),

          Row(
            children: [
              const Icon(
                Icons.currency_rupee_rounded,
                color: AppColors.darkIcon,
                size: 19,
              ),

              const SizedBox(width: 7),

              Text(
                order['amount'],
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(width: 5),

              const Text(
                'Estimated',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          SizedBox(
            width: double.infinity,
            height: 38,
            child: OutlinedButton(
              onPressed: () {
                _showOrderDetails(order);
              },
              style: OutlinedButton.styleFrom(
                foregroundColor:
                    AppColors.primary,
                side: const BorderSide(
                  color: AppColors.border,
                ),
                backgroundColor:
                    AppColors.mintBackground,
                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'View Details',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight:
                      FontWeight.w700,
                ),
              ),
            ),
          ),

          const SizedBox(height: 9),

          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: OutlinedButton(
                    onPressed: () {
                      _rejectOrder(order);
                    },
                    style:
                        OutlinedButton.styleFrom(
                      foregroundColor:
                          AppColors.error,
                      side: const BorderSide(
                        color: AppColors.error,
                        width: 1.2,
                      ),
                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(13),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment:
                          MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.close_rounded,
                          size: 19,
                        ),
                        SizedBox(width: 5),
                        Text(
                          'Reject',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight:
                                FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 9),

              Expanded(
                child: SizedBox(
                  height: 44,
                  child: ElevatedButton(
                    onPressed: () {
                      _acceptOrder(order);
                    },
                    style:
                        ElevatedButton.styleFrom(
                      backgroundColor:
                          AppColors.primary,
                      foregroundColor:
                          AppColors.white,
                      elevation: 0,
                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(13),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment:
                          MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.check_rounded,
                          size: 20,
                        ),
                        SizedBox(width: 5),
                        Text(
                          'Accept',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight:
                                FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrderInfo({
    required IconData icon,
    required String text,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          color: AppColors.darkIcon,
          size: 19,
        ),

        const SizedBox(width: 7),

        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow:
                TextOverflow.ellipsis,
            style: const TextStyle(
              color:
                  AppColors.textSecondary,
              fontSize: 12,
              fontWeight:
                  FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  // --------------------------------------------------
  // EMPTY ORDERS
  // --------------------------------------------------

  Widget _buildEmptyOrders() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        vertical: 45,
      ),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration:
                const BoxDecoration(
              color: AppColors.lightMint,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.receipt_long_outlined,
              color: AppColors.primary,
              size: 34,
            ),
          ),

          const SizedBox(height: 14),

          const Text(
            'No orders yet',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight:
                  FontWeight.w800,
            ),
          ),

          const SizedBox(height: 5),

          const Text(
            'New bookings will appear here.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------
  // ORDER ACTIONS
  // --------------------------------------------------

  void _acceptOrder(
    Map<String, dynamic> order,
  ) {
    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(
          '${order['orderId']} accepted',
        ),
        backgroundColor:
            AppColors.success,
      ),
    );
  }

  void _rejectOrder(
    Map<String, dynamic> order,
  ) {
    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(
          '${order['orderId']} rejected',
        ),
        backgroundColor:
            AppColors.error,
      ),
    );
  }

  // --------------------------------------------------
  // ORDER DETAILS
  // --------------------------------------------------

  void _showOrderDetails(
    Map<String, dynamic> order,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor:
          AppColors.card,
      shape:
          const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(
          top: Radius.circular(25),
        ),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding:
                const EdgeInsets.all(22),
            child: Column(
              mainAxisSize:
                  MainAxisSize.min,
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 42,
                    height: 4,
                    decoration:
                        BoxDecoration(
                      color:
                          AppColors.border,
                      borderRadius:
                          BorderRadius.circular(
                              10),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                Text(
                  order['orderId'],
                  style: const TextStyle(
                    color:
                        AppColors.textPrimary,
                    fontSize: 21,
                    fontWeight:
                        FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  order['service'],
                  style: const TextStyle(
                    color:
                        AppColors.primary,
                    fontSize: 16,
                    fontWeight:
                        FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 16),

                _buildOrderInfo(
                  icon:
                      Icons.person_outline_rounded,
                  text:
                      order['customer'],
                ),

                const SizedBox(height: 9),

                _buildOrderInfo(
                  icon:
                      Icons.location_on_outlined,
                  text:
                      order['location'],
                ),

                const SizedBox(height: 9),

                _buildOrderInfo(
                  icon:
                      Icons.currency_rupee_rounded,
                  text:
                      order['amount'],
                ),

                const SizedBox(height: 22),

                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child:
                      ElevatedButton(
                    onPressed: () {
                      Navigator.pop(
                          context);
                      _acceptOrder(
                          order);
                    },
                    style:
                        ElevatedButton
                            .styleFrom(
                      backgroundColor:
                          AppColors
                              .primary,
                      foregroundColor:
                          AppColors.white,
                      elevation: 0,
                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius
                                .circular(
                                    14),
                      ),
                    ),
                    child: const Text(
                      'Accept Order',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight:
                            FontWeight
                                .w800,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // --------------------------------------------------
  // BOTTOM NAVIGATION
  // --------------------------------------------------

  Widget _buildBottomNavigation() {
    return Container(
      height: 72,
      padding:
          const EdgeInsets.symmetric(
        horizontal: 22,
        vertical: 6,
      ),
      decoration:
          const BoxDecoration(
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
              icon:
                  Icons.home_rounded,
              title: 'Home',
              selected: false,
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ),

          Expanded(
            child: _buildBottomItem(
              icon:
                  Icons.receipt_long_rounded,
              title: 'Orders',
              selected: true,
              onTap: () {},
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomItem({
    required IconData icon,
    required String title,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius:
          BorderRadius.circular(17),
      child: Container(
        margin:
            const EdgeInsets.symmetric(
          horizontal: 12,
        ),
        decoration:
            BoxDecoration(
          color: selected
              ? AppColors.lightMint
              : AppColors.card,
          borderRadius:
              BorderRadius.circular(17),
        ),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: selected
                  ? AppColors.bottomActive
                  : AppColors.textSecondary,
              size: 24,
            ),

            const SizedBox(height: 1),

            Text(
              title,
              style: TextStyle(
                color: selected
                    ? AppColors.bottomActive
                    : AppColors.textSecondary,
                fontSize: 11,
                fontWeight:
                    FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}