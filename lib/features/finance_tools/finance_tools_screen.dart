import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/finance_store.dart';
enum FinanceTool { savings, budget, goals, health }
class FinanceToolsScreen extends StatefulWidget {const FinanceToolsScreen({super.key,required this.store,required this.tool});final FinanceStore store;final FinanceTool tool;@override State<FinanceToolsScreen> createState()=>_FinanceToolsScreenState();}
class _FinanceToolsScreenState extends State<FinanceToolsScreen>{
 final money=NumberFormat.currency(locale:'vi_VN',symbol:'₫',decimalDigits:0);final target=TextEditingController(),current=TextEditingController();int savedTarget=0,savedCurrent=0;bool loading=true;
 String get prefix=>widget.tool.name;
 @override void initState(){super.initState();_load();}
 Future<void> _load()async{final p=await SharedPreferences.getInstance();savedTarget=p.getInt(prefix+'_target')??0;savedCurrent=p.getInt(prefix+'_current')??0;target.text=savedTarget==0?'':savedTarget.toString();current.text=savedCurrent==0?'':savedCurrent.toString();if(mounted)setState(()=>loading=false);}
 @override void dispose(){target.dispose();current.dispose();super.dispose();}
 String get title=>switch(widget.tool){FinanceTool.savings=>'Tiết kiệm',FinanceTool.budget=>'Ngân sách',FinanceTool.goals=>'Mục tiêu',FinanceTool.health=>'Sức khỏe tài chính'};
 String get description=>switch(widget.tool){FinanceTool.savings=>'Thiết lập số tiền muốn tích lũy và cập nhật số tiền đã tiết kiệm.',FinanceTool.budget=>'Đặt hạn mức chi tiêu tổng thể và theo dõi mức sử dụng.',FinanceTool.goals=>'Đặt mục tiêu tài chính và cập nhật tiến độ thực hiện.',FinanceTool.health=>'Đánh giá sức khỏe dòng tiền từ dữ liệu giao dịch hiện có.'};
 @override Widget build(BuildContext context){final flow=widget.store.cashflow;final income=flow['income']??0,expense=flow['expense']??0;final progress=savedTarget<=0?0.0:(savedCurrent/savedTarget).clamp(0.0,1.0);return Scaffold(appBar:AppBar(title:Text(title)),body:loading?const Center(child:CircularProgressIndicator()):ListView(padding:const EdgeInsets.all(18),children:[
 Text(description,style:TextStyle(color:Colors.grey.shade700,height:1.4)),const SizedBox(height:18),
 if(widget.tool==FinanceTool.health)...[
 _healthCard('Tỷ lệ tiết kiệm',income==0?'Chưa đủ dữ liệu':((income-expense)*100/income).toStringAsFixed(1)+'%',income==0?0:((income-expense)/income).clamp(0.0,1.0)),
 _healthCard('Kiểm soát chi tiêu',income==0?'Chưa đủ dữ liệu':expense<=income?'Chi tiêu không vượt thu nhập':'Chi tiêu vượt thu nhập',income==0?0:expense<=income?1:0.25),
 _healthCard('Dữ liệu tài chính',widget.store.transactions.isEmpty?'Chưa có giao dịch':widget.store.transactions.length.toString()+' giao dịch được ghi nhận',widget.store.transactions.isEmpty?0.1:0.5),
 const SizedBox(height:12),const Text('Đây là chỉ báo tham khảo dựa trên dữ liệu hiện có, không phải điểm tín dụng. Chưa có dữ liệu về nợ, quỹ dự phòng và tài sản nên chưa thể chấm điểm sức khỏe toàn diện.',style:TextStyle(color:Colors.black54)),
 ]else...[
 Text('Tiến độ',style:TextStyle(color:Colors.grey.shade600,fontWeight:FontWeight.w600)),const SizedBox(height:8),
 Container(padding:const EdgeInsets.all(18),decoration:BoxDecoration(color:const Color(0xFF17243B),borderRadius:BorderRadius.circular(18)),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(money.format(savedCurrent),style:const TextStyle(color:Colors.white,fontSize:26,fontWeight:FontWeight.bold)),Text('trên '+money.format(savedTarget),style:const TextStyle(color:Colors.white70)),const SizedBox(height:14),ClipRRect(borderRadius:BorderRadius.circular(8),child:LinearProgressIndicator(value:progress,minHeight:10,backgroundColor:Colors.white24,color:const Color(0xFFFF9A59))),const SizedBox(height:8),Text((progress*100).toStringAsFixed(1)+'% hoàn thành',style:const TextStyle(color:Colors.white))])),
 const SizedBox(height:22),const Text('Cập nhật kế hoạch',style:TextStyle(fontWeight:FontWeight.bold,fontSize:17)),
 TextField(controller:target,keyboardType:TextInputType.number,decoration:InputDecoration(labelText:widget.tool==FinanceTool.budget?'Hạn mức chi tiêu (VND)':'Số tiền mục tiêu (VND)')),
 const SizedBox(height:12),TextField(controller:current,keyboardType:TextInputType.number,decoration:InputDecoration(labelText:widget.tool==FinanceTool.budget?'Đã chi tiêu (VND)':'Đã tích lũy (VND)')),
 const SizedBox(height:16),FilledButton(onPressed:save,child:const Text('Lưu kế hoạch')),
 ],
 ]));}
 Widget _healthCard(String title,String value,double progress)=>Card(child:Padding(padding:const EdgeInsets.all(16),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(title,style:const TextStyle(fontWeight:FontWeight.bold)),const SizedBox(height:8),Text(value),const SizedBox(height:8),LinearProgressIndicator(value:progress,color:const Color(0xFFFF8A3D),backgroundColor:const Color(0xFFFFE4D5))])));
 Future<void> save()async{final t=int.tryParse(target.text.replaceAll(RegExp(r'[^0-9]'),''))??0,c=int.tryParse(current.text.replaceAll(RegExp(r'[^0-9]'),''))??0;if(t<=0||c<0){ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Vui lòng nhập số tiền hợp lệ.')));return;}final p=await SharedPreferences.getInstance();await p.setInt(prefix+'_target',t);await p.setInt(prefix+'_current',c);if(!mounted)return;setState((){savedTarget=t;savedCurrent=c;});ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Đã lưu kế hoạch trên thiết bị.')));}
}