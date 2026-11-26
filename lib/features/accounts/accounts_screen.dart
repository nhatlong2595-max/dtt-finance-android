import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/finance_store.dart';

class AccountsScreen extends StatefulWidget {
 const AccountsScreen({super.key,required this.store});final FinanceStore store;
 @override State<AccountsScreen> createState()=>_AccountsScreenState();
}
class _AccountsScreenState extends State<AccountsScreen>{
 final name=TextEditingController(),opening=TextEditingController(text:'0');
 final money=NumberFormat.currency(locale:'vi_VN',symbol:'₫',decimalDigits:0);
 @override void dispose(){name.dispose();opening.dispose();super.dispose();}
 @override Widget build(BuildContext context)=>Scaffold(appBar:AppBar(title:const Text('Tài khoản')),body:ListView(padding:const EdgeInsets.fromLTRB(16,8,16,24),children:[
  ...widget.store.accounts.map((a)=>Card(child:ListTile(contentPadding:const EdgeInsets.symmetric(horizontal:16,vertical:8),leading:const CircleAvatar(backgroundColor:Color(0xFFFFE3D3),child:Icon(Icons.account_balance_wallet,color:Color(0xFF99542D))),title:Text(a.name,style:const TextStyle(fontWeight:FontWeight.w700)),subtitle:Text('Số dư ban đầu: '+money.format(a.openingBalance)),trailing:Text(money.format(widget.store.balanceFor(a.id)),style:const TextStyle(fontWeight:FontWeight.bold))))),
  const SizedBox(height:18),const Text('Thêm tài khoản',style:TextStyle(fontSize:18,fontWeight:FontWeight.w800)),const SizedBox(height:12),
  TextField(controller:name,decoration:const InputDecoration(labelText:'Tên tài khoản',hintText:'Ví dụ: Ví tiền mặt, Vietcombank')),
  const SizedBox(height:14),TextField(controller:opening,keyboardType:TextInputType.number,decoration:const InputDecoration(labelText:'Số dư ban đầu (VND)')),
  const SizedBox(height:16),FilledButton(style:FilledButton.styleFrom(minimumSize:const Size.fromHeight(52)),onPressed:()async{final n=name.text.trim(),v=int.tryParse(opening.text.replaceAll(RegExp(r'[^0-9]'),''))??0;if(n.isEmpty||v<0){ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Vui lòng nhập tên và số dư hợp lệ.')));return;}await widget.store.addAccount(n,v);name.clear();opening.text='0';if(mounted)setState((){});},child:const Text('Thêm tài khoản')),
 ]));
}