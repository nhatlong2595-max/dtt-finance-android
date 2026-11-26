import 'package:flutter/material.dart';
class DttTheme {
 static const navy=Color(0xFF17243B),orange=Color(0xFFFF8A3D),pink=Color(0xFFF4DCE5),background=Color(0xFFF5F4F8),surface=Color(0xFFFFF1E8);
 static ThemeData get light=>ThemeData(
  useMaterial3:true,scaffoldBackgroundColor:background,
  colorScheme:ColorScheme.fromSeed(seedColor:orange,primary:navy,secondary:orange,surface:Colors.white),
  appBarTheme:const AppBarTheme(backgroundColor:background,foregroundColor:navy,elevation:0,centerTitle:false,titleTextStyle:TextStyle(color:navy,fontSize:22,fontWeight:FontWeight.w700)),
  cardTheme:CardThemeData(color:surface,elevation:1,margin:const EdgeInsets.symmetric(vertical:6),shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(18))),
  inputDecorationTheme:InputDecorationTheme(filled:true,fillColor:Colors.white,contentPadding:const EdgeInsets.symmetric(horizontal:16,vertical:17),border:OutlineInputBorder(borderRadius:BorderRadius.circular(16),borderSide:const BorderSide(color:Color(0xFFD8D0CA))),enabledBorder:OutlineInputBorder(borderRadius:BorderRadius.circular(16),borderSide:const BorderSide(color:Color(0xFFD8D0CA))),focusedBorder:OutlineInputBorder(borderRadius:BorderRadius.circular(16),borderSide:const BorderSide(color:navy,width:1.5))),
  navigationBarTheme:const NavigationBarThemeData(backgroundColor:Color(0xFFFFEAE1),indicatorColor:Color(0xFFFFD9C5),height:76,labelTextStyle:WidgetStatePropertyAll(TextStyle(fontWeight:FontWeight.w600))),
 );
}