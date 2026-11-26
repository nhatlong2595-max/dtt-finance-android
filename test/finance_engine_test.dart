import 'package:flutter_test/flutter_test.dart';
import 'package:dtt_finance/domain/finance_engine.dart';
import 'package:dtt_finance/domain/finance_models.dart';

void main() {
  group('FinanceEngine', () {
    test('transfer reduces source and increases destination balance', () {
      const source = FinanceAccount(id: 'a', name: 'Cash', openingBalance: 100000);
      const destination = FinanceAccount(id: 'b', name: 'Bank', openingBalance: 50000);
      final transfer = FinanceTransaction(
        id: 't', accountId: 'a', destinationAccountId: 'b', amount: 20000,
        type: TransactionType.transfer, categoryId: 'c', note: 'move',
        date: DateTime(2026), status: 'posted');
      expect(FinanceEngine.accountBalance(source, [transfer]), 80000);
      expect(FinanceEngine.accountBalance(destination, [transfer]), 70000);
    });

    test('internal transfer and debt principal are excluded from cashflow', () {
      final rows = [
        FinanceTransaction(id: '1', accountId: 'a', amount: 100000, type: TransactionType.income, categoryId: 'c', note: '', date: DateTime(2026), status: 'posted'),
        FinanceTransaction(id: '2', accountId: 'a', amount: 40000, type: TransactionType.transfer, destinationAccountId: 'b', categoryId: 'c', note: '', date: DateTime(2026), status: 'posted'),
        FinanceTransaction(id: '3', accountId: 'a', amount: 20000, type: TransactionType.repayDebt, categoryId: 'c', note: '', date: DateTime(2026), status: 'posted'),
        FinanceTransaction(id: '4', accountId: 'a', amount: 15000, type: TransactionType.collectDebt, categoryId: 'c', note: '', date: DateTime(2026), status: 'posted'),
      ];
      expect(FinanceEngine.cashflowTotals(rows), {'income': 100000, 'expense': 0, 'net': 100000});
    });

    test('balanced journal validation', () {
      expect(FinanceEngine.isValidBalancedJournal([10, 20], [30]), isTrue);
      expect(FinanceEngine.isValidBalancedJournal([10], [11]), isFalse);
    });
  });
}
