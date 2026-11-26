import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/finance_store.dart';
import '../../domain/finance_models.dart';
import '../finance_tools/finance_tools_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key, required this.store});
  final FinanceStore store;
  @override State<DashboardScreen> createState() => _DashboardScreenState();
}
class _DashboardScreenState extends State<DashboardScreen> {
  int selected=-1;
  final money=NumberFormat.currency(locale:'vi_VN',symbol:'₫',decimalDigits:0);
  @override Widget build(BuildContext context) {
    final flow=widget.store.cashflow; final byCat=<String,int>{};
    for(final tx in widget.store.transactions.where((t)=>t.status=='posted'&&t.type==TransactionType.expense)){byCat[tx.categoryId]=(byCat[tx.categoryId]??0)+tx.amount;}
    final entries=byCat.entries.where((e)=>e.value>0).toList()..sort((a,b)=>b.value.compareTo(a.value));
    final total=entries.fold<int>(0,(s,e)=>s+e.value);
    const colors=[Color(0xFFFF8A3D),Color(0xFF17243B),Color(0xFFE7A6B7),Color(0xFF6C9B91),Color(0xFFF2C66D),Color(0xFF8B91C9),Color(0xFFB7A08A),Color(0xFF70A7D5)];
    return Scaffold(appBar:AppBar(title:const Text('DTT Finance'),actions:[IconButton(onPressed:()=>setState((){}),icon:const Icon(Icons.refresh))]),body:ListView(padding:const EdgeInsets.fromLTRB(16,8,16,24),children:[
      Container(padding:const EdgeInsets.all(22),decoration:BoxDecoration(color:const Color(0xFF17243B),borderRadius:BorderRadius.circular(24)),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
        const Text('TỔNG SỐ DƯ',style:TextStyle(color:Colors.white70,fontSize:12,letterSpacing:1)),const SizedBox(height:8),
        Text(money.format(widget.store.balance),style:const TextStyle(color:Colors.white,fontSize:30,fontWeight:FontWeight.w800)),const SizedBox(height:22),
        Row(children:[Expanded(child:_metric('Thu nhập',flow['income']??0,const Color(0xFFB7F36B))),Expanded(child:_metric('Chi tiêu',flow['expense']??0,const Color(0xFFFFB15C)))])
      ])),
      const SizedBox(height:22),const Text('Phân tích chi tiêu',style:TextStyle(fontSize:19,fontWeight:FontWeight.w800)),const SizedBox(height:4),
      Text(total==0?'Chưa có khoản chi tiêu được ghi nhận':'Tổng chi tiêu '+money.format(total),style:TextStyle(color:Colors.grey.shade600)),const SizedBox(height:8),
      Container(padding:const EdgeInsets.all(14),decoration:BoxDecoration(color:Colors.white,borderRadius:BorderRadius.circular(22)),child:Column(children:[
        SizedBox(height:230,child:total==0?const Center(child:Column(mainAxisAlignment:MainAxisAlignment.center,children:[Icon(Icons.donut_large,color:Color(0xFFFF8A3D),size:54),SizedBox(height:8),Text('Biểu đồ sẽ hiển thị khi có chi tiêu',style:TextStyle(color:Colors.black54))])):PieChart(PieChartData(centerSpaceRadius:65,sectionsSpace:3,pieTouchData:PieTouchData(touchCallback:(event,response){if(!event.isInterestedForInteractions||response?.touchedSection==null)return;setState(()=>selected=response!.touchedSection!.touchedSectionIndex);}),sections:List.generate(entries.length,(i){final e=entries[i];return PieChartSectionData(value:e.value.toDouble(),color:colors[i%colors.length],radius:selected==i?64:54,title:(e.value*100/total).toStringAsFixed(0)+'%',titleStyle:const TextStyle(color:Colors.white,fontWeight:FontWeight.bold,fontSize:12));}))),
        if(total>0)...[
          const SizedBox(height:6),Text(selected>=0&&selected<entries.length?(widget.store.categories.where((c)=>c.id==entries[selected].key).firstOrNull?.name??'Danh mục'):'TỔNG CHI TIÊU',style:TextStyle(color:Colors.grey.shade600,fontWeight:FontWeight.w600)),
          Text(money.format(selected>=0&&selected<entries.length?entries[selected].value:total),style:const TextStyle(fontSize:19,fontWeight:FontWeight.w800)),const Divider(height:22),
          ...List.generate(entries.length,(i){final e=entries[i];final cat=widget.store.categories.where((c)=>c.id==e.key).firstOrNull;return InkWell(onTap:()=>_showCategory(context,e.key,cat?.name??'Danh mục'),child:Padding(padding:const EdgeInsets.symmetric(vertical:7),child:Row(children:[Container(width:11,height:11,decoration:BoxDecoration(color:colors[i%colors.length],shape:BoxShape.circle)),const SizedBox(width:10),Expanded(child:Text(cat?.name??'Danh mục',style:const TextStyle(fontWeight:FontWeight.w600))),Text((e.value*100/total).toStringAsFixed(1)+'%',style:TextStyle(color:Colors.grey.shade600)),const SizedBox(width:12),Text(money.format(e.value),style:const TextStyle(fontWeight:FontWeight.w700))])));}),
        ],
      ])),
      const SizedBox(height:22),const Text('Quản lý tài chính',style:TextStyle(fontSize:19,fontWeight:FontWeight.w800)),const SizedBox(height:10),
      GridView.count(shrinkWrap:true,physics:const NeverScrollableScrollPhysics(),crossAxisCount:2,mainAxisSpacing:12,crossAxisSpacing:12,childAspectRatio:1.42,children:[
        _tool(context,Icons.savings_outlined,'Tiết kiệm','Theo dõi khoản tích lũy',FinanceTool.savings),_tool(context,Icons.pie_chart_outline,'Ngân sách','Đặt hạn mức chi tiêu',FinanceTool.budget),_tool(context,Icons.flag_outlined,'Mục tiêu','Theo dõi mục tiêu tiền',FinanceTool.goals),_tool(context,Icons.insights,'Sức khỏe tài chính','Đánh giá dòng tiền',FinanceTool.health),
      ]),
      const SizedBox(height:20),const Text('Tài khoản của tôi',style:TextStyle(fontSize:19,fontWeight:FontWeight.w800)),const SizedBox(height:8),
      ...widget.store.accounts.map((a)=>Card(child:ListTile(leading:const CircleAvatar(backgroundColor:Color(0xFFFFE3D3),child:Icon(Icons.account_balance_wallet,color:Color(0xFF9B5428))),title:Text(a.name,style:const TextStyle(fontWeight:FontWeight.w700)),subtitle:Text('Số dư ban đầu: '+money.format(a.openingBalance)),trailing:Text(money.format(widget.store.balanceFor(a.id)),style:const TextStyle(fontWeight:FontWeight.bold))))),
    ]));
  }
  Widget _metric(String label,int value,Color color)=>Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(label,style:const TextStyle(color:Colors.white70)),const SizedBox(height:4),Text(money.format(value),style:TextStyle(color:color,fontSize:18,fontWeight:FontWeight.bold))]);
  Widget _tool(BuildContext context,IconData icon,String title,String sub,FinanceTool tool)=>Material(color:const Color(0xFFFFF1E9),borderRadius:BorderRadius.circular(18),child:InkWell(borderRadius:BorderRadius.circular(18),onTap:()=>Navigator.push(context,MaterialPageRoute(builder:(_)=>FinanceToolsScreen(store:widget.store,tool:tool))),child:Padding(padding:const EdgeInsets.all(14),child:Column(crossAxisAlignment:CrossAxisAlignment.start,mainAxisAlignment:MainAxisAlignment.center,children:[Icon(icon,color:const Color(0xFFFF8A3D),size:28),const SizedBox(height:10),Text(title,style:const TextStyle(fontWeight:FontWeight.w800,fontSize:15)),const SizedBox(height:3),Text(sub,style:TextStyle(color:Colors.grey.shade700,fontSize:11))]))));
  void _showCategory(BuildContext context,String id,String title){final rows=widget.store.transactions.where((t)=>t.categoryId==id&&t.type==TransactionType.expense&&t.status=='posted').toList()..sort((a,b)=>b.date.compareTo(a.date));showModalBottomSheet(context:context,isScrollControlled:true,builder:(ctx)=>SafeArea(child:Padding(padding:const EdgeInsets.all(18),child:Column(mainAxisSize:MainAxisSize.min,crossAxisAlignment:CrossAxisAlignment.start,children:[Text(title,style:const TextStyle(fontSize:20,fontWeight:FontWeight.bold)),const SizedBox(height:12),...rows.take(10).map((t)=>ListTile(title:Text(t.note.isEmpty?title:t.note),subtitle:Text(DateFormat('dd/MM/yyyy').format(t.date)),trailing:Text(money.format(t.amount)))),if(rows.isEmpty)const Text('Chưa có giao dịch')]))));}
}