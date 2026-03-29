import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sebastian_app/app/app.dart';
import 'services/auth_service.dart';


/// 작업 전환·탭 제목 등에 쓰이는 앱 표시 이름
//const String kAppName = '나의 세바스찬';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //await SharedPreferences.init();
  runApp(const MySebastianApp());
}