import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends StatefulWidget {
 const SettingsScreen({super.key});
 @override State<SettingsScreen> createState()=>_SettingsScreenState();
}
class _SettingsScreenState extends State<SettingsScreen>{
 bool checking=false;String version='1.1.0';
 @override void initState(){super.initState();_loadVersion();}
 Future<void> _loadVersion()async{final p=await PackageInfo.fromPlatform();if(mounted)setState(()=>version=p.version);}
 Future<void> _checkUpdate()async{
  setState(()=>checking=true);
  try{
   final response=await http.get(Uri.parse('https://api.github.com/repos/nhatlong2595-max/dtt-finance-android/releases/latest'),headers:{'Accept':'application/vnd.github+json'});
   if(response.statusCode!=200)throw Exception('GitHub trả về mã '+response.statusCode.toString());
   final data=jsonDecode(response.body) as Map<String,dynamic>;
   final tag=(data['tag_name']??'').toString();
   final assets=(data['assets'] as List<dynamic>? ?? []);
   final apk=assets.cast<Map<String,dynamic>>().where((a)=>(a['name']??'').toString().toLowerCase().endsWith('.apk')).firstOrNull;
   if(apk==null)throw Exception('Bản phát hành chưa có file APK.');
   if(!mounted)return;
   final newer=_compare(tag.replaceFirst('v',''),version)>0;
   if(!newer){ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text('Bạn đang dùng phiên bản mới nhất ('+version+').')));}
   else{
    showDialog(context:context,builder:(ctx)=>AlertDialog(title:const Text('Có phiên bản mới'),content:Text('Phiên bản hiện tại: '+version+'\nPhiên bản mới: '+tag+'\n\nMở GitHub để tải và cài đặt bản cập nhật?'),actions:[TextButton(onPressed:()=>Navigator.pop(ctx),child:const Text('Để sau')),FilledButton(onPressed:(){Navigator.pop(ctx);launchUrl(Uri.parse(apk['browser_download_url'].toString()),mode:LaunchMode.externalApplication);},child:const Text('Tải bản cập nhật'))]));
   }
  }catch(e){if(mounted)ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text('Không kiểm tra được cập nhật: '+e.toString())));}
  finally{if(mounted)setState(()=>checking=false);}
 }
 int _compare(String a,String b){final aa=a.split('.').map((x)=>int.tryParse(x)??0).toList(),bb=b.split('.').map((x)=>int.tryParse(x)??0).toList();for(var i=0;i<3;i++){final x=i<aa.length?aa[i]:0,y=i<bb.length?bb[i]:0;if(x!=y)return x.compareTo(y);}return 0;}
 @override Widget build(BuildContext context)=>Scaffold(appBar:AppBar(title:const Text('Cài đặt')),body:ListView(padding:const EdgeInsets.all(16),children:[
  Card(child:ListTile(leading:const Icon(Icons.person_outline),title:const Text('Hồ sơ cá nhân'),subtitle:const Text('Thông tin người dùng'))),
  Card(child:ListTile(leading:const Icon(Icons.lock_outline),title:const Text('Bảo mật ứng dụng'),subtitle:const Text('Tùy chọn bảo mật sẽ được bổ sung trong bản tiếp theo'))),
  Card(child:ListTile(leading:const Icon(Icons.backup_outlined),title:const Text('Sao lưu dữ liệu'),subtitle:const Text('Sao lưu đám mây chưa bật'))),
  Card(child:ListTile(leading:const Icon(Icons.system_update_alt),title:const Text('Phiên bản ứng dụng'),subtitle:Text('DTT Finance v'+version),trailing:checking?const SizedBox(width:22,height:22,child:CircularProgressIndicator(strokeWidth:2)):const Icon(Icons.chevron_right),onTap:checking?null:_checkUpdate)),
  const SizedBox(height:8),FilledButton.icon(onPressed:checking?null:_checkUpdate,icon:const Icon(Icons.cloud_download_outlined),label:Text(checking?'Đang kiểm tra...':'Kiểm tra cập nhật online')),
  const SizedBox(height:8),const Text('Ứng dụng kiểm tra bản phát hành chính thức từ GitHub. Khi có phiên bản mới, bạn có thể tải APK và cài đặt cập nhật trực tiếp trên điện thoại.',style:TextStyle(color:Colors.black54)),
 ]));
}