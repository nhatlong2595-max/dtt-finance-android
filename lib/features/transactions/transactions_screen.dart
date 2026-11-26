import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/finance_store.dart';
import '../../domain/finance_models.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key, required this.store});
  final FinanceStore store;
  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  final amount = TextEditingController();
  final note = TextEditingController();
  TransactionType type = TransactionType.expense;
  String? accountId;
  String? destinationId;
  String? categoryId;

  String money(int value) => NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0).format(value);

  @override
  Widget build(BuildContext context) {
    accountId ??= widget.store.accounts.firstOrNull?.id;
    final categories = widget.store.categories.where((c) => c.type == type || type == TransactionType.transfer).toList();
    if (categoryId == null || !categories.any((c) => c.id == categoryId)) categoryId = categories.firstOrNull?.id;
    return Scaffold(
      appBar: AppBar(title: const Text('Giao dịch')),
      floatingActionButton: FloatingActionButton.extended(onPressed: _showEntry, icon: const Icon(Icons.add), label: const Text('Thêm giao dịch')),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: widget.store.transactions.reversed.map((tx) {
          final category = widget.store.categories.where((c) => c.id == tx.categoryId).firstOrNull;
          return Card(child: ListTile(
            leading: CircleAvatar(child: Icon(tx.type == TransactionType.income ? Icons.arrow_downward : Icons.swap_vert)),
            title: Text(tx.note.isEmpty ? (category?.name ?? tx.type.name) : tx.note),
            subtitle: Text(DateFormat('dd/MM/yyyy').format(tx.date)),
            trailing: Text(money(tx.amount)),
          ));
        }).toList(),
      ),
    );
  }

  void _showEntry() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => StatefulBuilder(
        builder: (sheetContext, setModalState) => Padding(
          padding: EdgeInsets.only(left: 16, right: 16, top: 16, bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 16),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Giao dịch mới', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                DropdownButtonFormField<TransactionType>(
                  value: type,
                  decoration: const InputDecoration(labelText: 'Loại giao dịch'),
                  items: TransactionType.values.map((v) => DropdownMenuItem(value: v, child: Text(v.name))).toList(),
                  onChanged: (value) => setModalState(() { type = value ?? type; categoryId = null; destinationId = null; }),
                ),
                DropdownButtonFormField<String>(
                  value: accountId,
                  decoration: const InputDecoration(labelText: 'Tài khoản nguồn'),
                  items: widget.store.accounts.map((a) => DropdownMenuItem(value: a.id, child: Text(a.name))).toList(),
                  onChanged: (value) => setModalState(() { accountId = value; if (destinationId == value) destinationId = null; }),
                ),
                if (type == TransactionType.transfer)
                  DropdownButtonFormField<String>(
                    value: destinationId ?? widget.store.accounts.where((a) => a.id != accountId).firstOrNull?.id,
                    decoration: const InputDecoration(labelText: 'Tài khoản nhận'),
                    items: widget.store.accounts.where((a) => a.id != accountId).map((a) => DropdownMenuItem(value: a.id, child: Text(a.name))).toList(),
                    onChanged: (value) => setModalState(() => destinationId = value),
                  ),
                DropdownButtonFormField<String>(
                  value: categoryId,
                  decoration: const InputDecoration(labelText: 'Danh mục'),
                  items: widget.store.categories.where((c) => c.type == type || type == TransactionType.transfer).map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
                  onChanged: (value) => setModalState(() => categoryId = value),
                ),
                TextField(controller: amount, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Số tiền (VND)')),
                TextField(controller: note, decoration: const InputDecoration(labelText: 'Ghi chú')),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: () async {
                    final value = int.tryParse(amount.text.replaceAll(RegExp(r'[^0-9]'), ''));
                    if (accountId == null || categoryId == null || value == null || value <= 0) return;
                    if (type == TransactionType.transfer) {
                      final target = destinationId ?? widget.store.accounts.where((a) => a.id != accountId).firstOrNull?.id;
                      if (target == null) return;
                      await widget.store.transfer(sourceAccountId: accountId!, destinationAccountId: target, amount: value, categoryId: categoryId!, note: note.text, date: DateTime.now());
                    } else {
                      await widget.store.addTransaction(accountId: accountId!, amount: value, type: type, categoryId: categoryId!, note: note.text, date: DateTime.now());
                    }
                    amount.clear();
                    note.clear();
                    if (mounted) {
                      Navigator.pop(sheetContext);
                      setState(() {});
                    }
                  },
                  child: const Text('Lưu giao dịch'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
