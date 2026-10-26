
import 'package:flutter/material.dart';


class EarningsScreen extends StatelessWidget {
  const EarningsScreen({
    super.key,
    required this.onHomeTap,
    required this.onOrdersTap,
  });

  final VoidCallback onHomeTap;
  final VoidCallback onOrdersTap;

  static const Color primary = Color(0xFF087F73);
  static const Color background = Color(0xFFE5F7F4);
  static const Color mint = Color(0xFFD5F2EC);
  static const Color textDark = Color(0xFF14243D);
  static const Color textGrey = Color(0xFF68758A);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        title: const Text(
          'Handzy Thozhan',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none),
          ),
        ],
      ),
      // Only Home and Orders are shown here.
      
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Earnings',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: textDark,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Your earnings at a glance',
                      style: TextStyle(color: textGrey),
                    ),
                  ],
                ),
              ),
              OutlinedButton.icon(
                onPressed: () async {
                  final now = DateTime.now();
                  await showDatePicker(
                    context: context,
                    initialDate: now,
                    firstDate: DateTime(2020),
                    lastDate: now,
                  );
                },
                icon: const Icon(Icons.calendar_month),
                label: const Text('Today'),
              ),
            ],
          ),
          const SizedBox(height: 16),

          _card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Today's Earnings",
                  style: TextStyle(color: textGrey, fontSize: 16),
                ),
                const SizedBox(height: 8),
                const Text(
                  '₹1,850',
                  style: TextStyle(
                    fontSize: 38,
                    color: textDark,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Row(
                  children: [
                    Icon(Icons.trending_up, color: Colors.green),
                    SizedBox(width: 6),
                    Text(
                      '+12.5% vs yesterday',
                      style: TextStyle(color: Colors.green),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 90,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _bar(30),
                      _bar(45),
                      _bar(60),
                      _bar(38),
                      _bar(70),
                      _bar(50),
                      _bar(82),
                      _bar(62),
                      _bar(55),
                      _bar(90, active: true),
                      _bar(45),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('6 AM', style: TextStyle(color: textGrey)),
                    Text('10 AM', style: TextStyle(color: textGrey)),
                    Text('2 PM', style: TextStyle(color: textGrey)),
                    Text('6 PM', style: TextStyle(color: textGrey)),
                    Text('10 PM', style: TextStyle(color: textGrey)),
                  ],
                ),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: background,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: mint,
                        child: Icon(Icons.bar_chart, color: primary),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Good job!',
                              style: TextStyle(
                                color: primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'You earned more than yesterday.',
                              style: TextStyle(color: textGrey),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: _card(
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.account_balance_wallet,
                        color: primary,
                        size: 30,
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Wallet Balance',
                        style: TextStyle(color: textGrey, fontSize: 13),
                      ),
                      SizedBox(height: 5),
                      Text(
                        '₹4,250',
                        style: TextStyle(
                          color: primary,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _card(
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.schedule, color: primary, size: 30),
                      SizedBox(height: 12),
                      Text(
                        'Pending Payout',
                        style: TextStyle(color: textGrey, fontSize: 13),
                      ),
                      SizedBox(height: 5),
                      Text(
                        '₹750',
                        style: TextStyle(
                          color: primary,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          _card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Earnings Breakdown',
                  style: TextStyle(
                    fontSize: 19,
                    color: textDark,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                _earningRow('Completed Jobs (3)', '₹2,100'),
                const Divider(height: 24),
                _earningRow('Platform Fee', '-₹250'),
                const Divider(height: 24),
                _earningRow('Net Earnings', '₹1,850', bold: true),
              ],
            ),
          ),

          const SizedBox(height: 16),

          _card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Recent Transactions',
                  style: TextStyle(
                    fontSize: 19,
                    color: textDark,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                _transaction(
                  Icons.build,
                  'Plumbing service',
                  'Today, 10:30 AM',
                  '+₹850',
                ),
                const Divider(),
                _transaction(
                  Icons.electrical_services,
                  'Electrical repair',
                  'Today, 08:15 AM',
                  '+₹600',
                ),
                const Divider(),
                _transaction(
                  Icons.water_drop,
                  'Tap replacement',
                  'Yesterday, 06:45 PM',
                  '+₹400',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _card({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: primary.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  static Widget _bar(double height, {bool active = false}) {
    return Container(
      width: 13,
      height: height,
      decoration: BoxDecoration(
        color: active ? primary : const Color(0xFFB8E6DD),
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  static Widget _earningRow(
    String title,
    String amount, {
    bool bold = false,
  }) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              color: textDark,
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
        Text(
          amount,
          style: TextStyle(
            color: bold ? primary : textDark,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  static Widget _transaction(
    IconData icon,
    String title,
    String date,
    String amount,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: background,
            child: Icon(icon, color: primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: textDark,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  date,
                  style: const TextStyle(
                    color: textGrey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            amount,
            style: const TextStyle(
              color: primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  static Widget _navItem(
    IconData icon,
    String label,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: textGrey, size: 28),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: textGrey)),
        ],
      ),
    );
  }
}
