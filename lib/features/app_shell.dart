import 'package:flutter/material.dart';
import '../data/finance_store.dart';
import 'dashboard/dashboard_screen.dart';
import 'transactions/transactions_screen.dart';
import 'accounts/accounts_screen.dart';
import 'reports/reports_screen.dart';
import 'settings/settings_screen.dart';

class AppShell extends StatefulWidget {
 const AppShell({super.key,required this.store});
 final FinanceStore store;
 @override State<AppShell> createState()=>_AppShellState();
}
class _AppShellState extends State<AppShell>{
 int index=0;
 @override Widget build(BuildContext context){
  final pages=[DashboardScreen(store:widget.store),TransactionsScreen(store:widget.store),AccountsScreen(store:widget.store),ReportsScreen(store:widget.store),const SettingsScreen()];
  return Scaffold(
   body:SafeArea(child:AnimatedBuilder(animation:widget.store,builder:(context,_)=>IndexedStack(index:index,children:pages))),
   bottomNavigationBar:NavigationBar(selectedIndex:index,onDestinationSelected:(i)=>setState(()=>index=i),destinations:const [
    NavigationDestination(icon:Icon(Icons.dashboard_outlined),selectedIcon:Icon(Icons.dashboard),label:'Tổng quan'),
    NavigationDestination(icon:Icon(Icons.swap_vert),label:'Giao dịch'),
    NavigationDestination(icon:Icon(Icons.account_balance_wallet_outlined),label:'Tài khoản'),
    NavigationDestination(icon:Icon(Icons.pie_chart_outline),label:'Báo cáo'),
    NavigationDestination(icon:Icon(Icons.settings_outlined),label:'Cài đặt'),
   ]),
  );
 }
}