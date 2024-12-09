import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PostUpdateScreen extends StatefulWidget {
  final Map<String, dynamic> itemDetails; // itemDetails를 직접 전달받음

  const PostUpdateScreen({required this.itemDetails});

  @override
  _PostUpdateScreenState createState() => _PostUpdateScreenState();
}

class _PostUpdateScreenState extends State<PostUpdateScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _contentController;
  late TextEditingController _dailyPriceController;
  late TextEditingController _monthlyPriceController;
  late TextEditingController _locationController;
  late TextEditingController _openChatLinkController;

  @override
  void initState() {
    super.initState();
    _initializeFields();
  }

  void _initializeFields() {
    // 전달받은 itemDetails를 사용해 필드 초기화
    _nameController = TextEditingController(text: widget.itemDetails['name']);
    _contentController = TextEditingController(text: widget.itemDetails['content']);
    _dailyPriceController = TextEditingController(text: widget.itemDetails['dailyPrice'].toString());
    _monthlyPriceController = TextEditingController(text: widget.itemDetails['monthlyPrice'].toString());
    _locationController = TextEditingController(text: widget.itemDetails['location']);
    _openChatLinkController = TextEditingController(text: widget.itemDetails['openChatLink']);
  }

  Future<void> _updatePost() async {
    if (!_formKey.currentState!.validate()) return;

    final url = Uri.parse('http://10.0.2.2:8080/items/posted/${widget.itemDetails['id']}');
    final Map<String, dynamic> updatedData = {
      'name': _nameController.text,
      'content': _contentController.text,
      'dailyPrice': int.parse(_dailyPriceController.text),
      'monthlyPrice': int.parse(_monthlyPriceController.text),
      'location': _locationController.text,
      'openChatLink': _openChatLinkController.text,
    };

    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(updatedData),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('게시글이 성공적으로 수정되었습니다.')),
        );
        Navigator.pop(context, true); // 데이터 새로고침 트리거
      } else {
        throw Exception('Failed to update post');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating post: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('게시글 수정'),
        backgroundColor: Colors.blue[900],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: '물품 이름'),
                validator: (value) =>
                value == null || value.isEmpty ? '이름을 입력해주세요' : null,
              ),
              TextFormField(
                controller: _contentController,
                decoration: InputDecoration(labelText: '물품 설명'),
                maxLines: 3,
                validator: (value) =>
                value == null || value.isEmpty ? '내용을 입력해주세요' : null,
              ),
              TextFormField(
                controller: _dailyPriceController,
                decoration: InputDecoration(labelText: '하루 가격'),
                keyboardType: TextInputType.number,
                validator: (value) =>
                value == null || value.isEmpty ? '하루 가격을 입력해주세요' : null,
              ),
              TextFormField(
                controller: _monthlyPriceController,
                decoration: InputDecoration(labelText: '한달 가격'),
                keyboardType: TextInputType.number,
                validator: (value) =>
                value == null || value.isEmpty ? '한달 가격을 입력해주세요' : null,
              ),
              TextFormField(
                controller: _locationController,
                decoration: InputDecoration(labelText: '거래 위치'),
                validator: (value) =>
                value == null || value.isEmpty ? '거래 위치를 입력해주세요' : null,
              ),
              TextFormField(
                controller: _openChatLinkController,
                decoration: InputDecoration(labelText: '오픈채팅방 링크'),
                validator: (value) =>
                value == null || value.isEmpty ? '오픈채팅방 링크를 입력해주세요' : null,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _updatePost,
                child: Text('수정'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: EdgeInsets.symmetric(vertical: 15),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
