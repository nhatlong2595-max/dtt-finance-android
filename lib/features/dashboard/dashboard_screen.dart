import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/finance_store.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key, required this.store});
  final FinanceStore store;

  String money(int value) => NumberFormat.currency(
        locale: 'vi_VN', symbol: '₫', decimalDigits: 0).format(value);

  @override
  Widget build(BuildContext context) {
    final flow = store.cashflow;
    return Scaffold(
      appBar: AppBar(title: const Text('DTT Finance')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: const Color(0xFF17243B),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('TỔNG SỐ DƯ', style: TextStyle(color: Colors.white70)),
                const SizedBox(height: 8),
                Text(money(store.balance), style: const TextStyle(
                  color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                Row(children: [
                  Expanded(child: _metric('Thu nhập', flow['income'] ?? 0, Colors.lightGreenAccent)),
                  Expanded(child: _metric('Chi tiêu', flow['expense'] ?? 0, Colors.orangeAccent)),
                ]),
              ],
            ),
          ),
          const SizedBox(height: 18),
          const Text('Tóm tắt tài chính', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          GridView.count(
            shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2, childAspectRatio: 1.55,
            children: const [
              _SummaryTile(Icons.savings_outlined, 'Tiết kiệm'),
              _SummaryTile(Icons.pie_chart_outline, 'Ngân sách'),
              _SummaryTile(Icons.flag_outlined, 'Mục tiêu'),
              _SummaryTile(Icons.insights, 'Sức khỏe tài chính'),
            ],
          ),
          const SizedBox(height: 8),
          const Text('Tài khoản của tôi', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ...store.accounts.map((account) => Card(
            child: ListTile(
              leading: const Icon(Icons.account_balance_wallet),
              title: Text(account.name),
              subtitle: Text('Số dư ban đầu: ${money(account.openingBalance)}'),
            ),
          )),
        ],
      ),
    );
  }

  Widget _metric(String label, int value, Color color) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: const TextStyle(color: Colors.white70)),
      Text(money(value), style: TextStyle(color: color, fontSize: 17, fontWeight: FontWeight.bold)),
    ],
  );
}

class _SummaryTile extends StatelessWidget {
  const _SummaryTile(this.icon, this.label);
  final IconData icon;
  final String label;
  @override
  Widget build(BuildContext context) => Card(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 4),
        Icon(icon, color: const Color(0xFFFF8A3D)),
        const SizedBox(height: 6),
        Text(label),
      ],
    ),
  );
}
