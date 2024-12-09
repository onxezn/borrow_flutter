import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RegistrationScreen extends StatefulWidget {
  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final TextEditingController _loginIdController = TextEditingController(); // 아이디
  final TextEditingController _nameController = TextEditingController(); // 이름
  final TextEditingController _nicknameController = TextEditingController(); // 닉네임
  final TextEditingController _passwordController = TextEditingController(); // 비밀번호 설정
  final TextEditingController _confirmPasswordController = TextEditingController(); // 비밀번호 확인
  final TextEditingController _emailController = TextEditingController(); // 이메일

  bool _isLoginIdAvailable = false;

  // 아이디 중복확인 API 호출
  Future<void> _checkLoginIdAvailability() async {
    final url = Uri.parse('http://10.0.2.2:8080/check_login_id');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'loginId': _loginIdController.text}),
      );

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        setState(() {
          _isLoginIdAvailable = result['available'] == true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_isLoginIdAvailable ? '사용 가능한 아이디입니다.' : '이미 사용 중인 아이디입니다.')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('아이디 중복확인 실패: ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('네트워크 오류가 발생했습니다: $e')),
      );
    }
  }

  // 비밀번호 검증
  bool _isValidPassword(String password) {
    final regex = RegExp(r'^(?=.*[!@#$%^&*(),.?":{}|<>]).{8,15}$'); // 특수문자 포함, 8~15자
    return regex.hasMatch(password);
  }

  // 모든 필드가 채워져 있는지 확인하는 함수
  bool _validateFields() {
    if (_loginIdController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('아이디를 입력하세요.')),
      );
      return false;
    }
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('이름을 입력하세요.')),
      );
      return false;
    }
    if (_nicknameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('닉네임을 입력하세요.')),
      );
      return false;
    }
    if (_passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('비밀번호를 입력하세요.')),
      );
      return false;
    }
    if (_confirmPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('비밀번호 확인을 입력하세요.')),
      );
      return false;
    }
    if (_emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('이메일을 입력하세요.')),
      );
      return false;
    }
    return true; // 모든 필드가 유효함
  }

  // 회원가입 API 호출
  Future<void> _signUp() async {
    if (!_isLoginIdAvailable) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('아이디 중복확인을 먼저 진행해주세요.')),
      );
      return;
    }

    if (!_validateFields()) return; // 모든 필드 작성하였는지 확인

    if (!_isValidPassword(_passwordController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('비밀번호는 특수문자를 포함한 8~15글자로 설정해야 합니다.')),
      );
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('비밀번호가 일치하지 않습니다.')),
      );
      return;
    }

    final url = Uri.parse('http://10.0.2.2:8080/sign-up');
    final Map<String, dynamic> userData = {
      'loginId': _loginIdController.text,
      'name': _nameController.text,
      'nickname': _nicknameController.text,
      'password': _passwordController.text,
      'email': _emailController.text,
    };

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(userData),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('회원가입이 성공적으로 완료되었습니다!')),
        );
        _loginIdController.clear();
        _nameController.clear();
        _nicknameController.clear();
        _passwordController.clear();
        _confirmPasswordController.clear();
        _emailController.clear();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('회원가입 실패: ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('네트워크 오류가 발생했습니다: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[800], // 쨍한 파란색
        title: Row(
          children: [
            Image.asset(
              'assets/borrow_logo.png',
              height: 70,
              width: 70,
            ),
            SizedBox(width: 37),
            Text(
              '회원가입',
              style: TextStyle(
                fontSize: 32,
                color: Colors.white, // 텍스트 흰색
                fontFamily: 'BlackHanSans', // 폰트 변경
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              buildTextField(
                '아이디',
                '아이디를 입력하세요',
                controller: _loginIdController,
                suffix: ElevatedButton(
                  onPressed: _checkLoginIdAvailability,
                  child: Text('중복확인'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    minimumSize: Size(100, 36),
                  ),
                ),
              ),
              if (_isLoginIdAvailable)
                Text(
                  '사용 가능한 아이디입니다.',
                  style: TextStyle(color: Colors.green),
                ),
              buildTextField('이름', '이름을 입력하세요', controller: _nameController),
              buildTextField('닉네임', '닉네임을 입력하세요', controller: _nicknameController),
              buildTextField('비밀번호', '비밀번호를 입력하세요', controller: _passwordController, obscureText: true),
              buildTextField('비밀번호 확인', '비밀번호를 다시 입력하세요', controller: _confirmPasswordController, obscureText: true),
              buildTextField('이메일', 'abc1234@university.edu', controller: _emailController),
              SizedBox(height: 50),
              ElevatedButton(
                onPressed: _signUp,
                child: Text('회원가입'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  textStyle: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTextField(String label, String placeholder,
      {bool obscureText = false, TextEditingController? controller, Widget? suffix}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          labelText: label,
          hintText: placeholder,
          border: OutlineInputBorder(),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.blue[900]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.blue[700]!),
          ),
          suffixIcon: suffix,
        ),
      ),
    );
  }
}
