import 'finance_models.dart';
class FinanceEngine {
 static int accountBalance(FinanceAccount account,Iterable<FinanceTransaction> transactions){var balance=account.openingBalance;for(final tx in transactions.where((e)=>e.status=='posted')){if(tx.accountId==account.id){switch(tx.type){case TransactionType.income:case TransactionType.collectDebt:balance+=tx.amount;break;case TransactionType.expense:case TransactionType.lend:case TransactionType.borrow:case TransactionType.repayDebt:case TransactionType.transfer:balance-=tx.amount;break;}}if(tx.type==TransactionType.transfer&&tx.destinationAccountId==account.id)balance+=tx.amount;}return balance;}
 static Map<String,int> cashflowTotals(Iterable<FinanceTransaction> transactions){var income=0,expense=0;for(final tx in transactions.where((e)=>e.status=='posted')){if(tx.type==TransactionType.income)income+=tx.amount;if(tx.type==TransactionType.expense)expense+=tx.amount;}return {'income':income,'expense':expense,'net':income-expense};}
 static bool isValidBalancedJournal(List<int> debits,List<int> credits)=>debits.isNotEmpty&&debits.fold<int>(0,(a,b)=>a+b)==credits.fold<int>(0,(a,b)=>a+b);
}
