import 'package:flutter/material.dart';
import 'package:dtt_finance/core/theme.dart';
import 'package:dtt_finance/data/finance_store.dart';
import 'package:dtt_finance/features/app_shell.dart';
Future<void> main() async { WidgetsFlutterBinding.ensureInitialized(); final store=FinanceStore(); await store.init(); runApp(DttFinanceApp(store:store)); }
class DttFinanceApp extends StatelessWidget { const DttFinanceApp({super.key,required this.store}); final FinanceStore store; @override Widget build(BuildContext context)=>MaterialApp(title:'DTT Finance',debugShowCheckedModeBanner:false,theme:DttTheme.light,home:AppShell(store:store)); }
