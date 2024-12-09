import 'package:flutter/material.dart';
import 'pages/login.dart'; // 로그인 페이지 import

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // 디버그 배너 숨김
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginScreen(), // 시작 페이지를 LoginScreen으로 설정
    );
  }
}
