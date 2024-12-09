import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:borrow_app/pages/item_details_screan.dart';
import 'package:borrow_app/global_variables.dart'; // 전역 변수
import 'main_screen.dart';

class AddItemScreen extends StatefulWidget {
  @override
  _AddItemScreenState createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _componentsController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _dailyPriceController = TextEditingController();
  final TextEditingController _monthlyPriceController = TextEditingController();
  final TextEditingController _openChatController = TextEditingController();

  String? _selectedCategory;
  List<dynamic> _categories = [];
  List<String> _images = []; // 이미지 리스트

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    final url = Uri.parse('http://10.0.2.2:8080/items/post/form-data');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          _categories = json.decode(response.body)['categories'];
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('카테고리 불러오기 실패')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('네트워크 오류: $e')),
      );
    }
  }

  Future<void> _submitItem() async {
    if (_selectedCategory == null || _nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('모든 필드를 입력해주세요.')),
      );
      return;
    }

    final url = Uri.parse('http://10.0.2.2:8080/items/post');
    final Map<String, dynamic> itemData = {
      'name': _nameController.text,
      'categoryId': int.tryParse(_selectedCategory ?? "0"),
      'content': _contentController.text,
      'components': _componentsController.text,
      'location': _locationController.text,
      'dailyPrice': int.tryParse(_dailyPriceController.text),
      'monthlyPrice': int.tryParse(_monthlyPriceController.text),
      'images': _images,
      'userId': globalUserId, // 전역 변수
      'openChatLink': _openChatController.text, // 오픈채팅 링크 추가
    };

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(itemData),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final Map<String, dynamic> item = json.decode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('물품이 성공적으로 등록되었습니다!')),
        );
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => MainScreen(),
          ),
              (route) => false,
        );

      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('등록 실패: ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('네트워크 오류: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: Text('등록'),
        backgroundColor: Colors.blue[800],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(labelText: '물품 이름'),
              ),
              SizedBox(height: 15),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                items: _categories.map((category) {
                  return DropdownMenuItem(
                    value: category['id'].toString(),
                    child: Text(category['name']),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value;
                  });
                },
                decoration: InputDecoration(labelText: '카테고리 선택'),
              ),
              SizedBox(height: 15),
              TextField(
                controller: _contentController,
                decoration: InputDecoration(labelText: '물품 소개'),
                maxLines: 3,
              ),
              SizedBox(height: 15),
              TextField(
                controller: _componentsController,
                decoration: InputDecoration(labelText: '구성품'),
                maxLines: 2,
              ),
              SizedBox(height: 15),
              TextField(
                controller: _locationController,
                decoration: InputDecoration(labelText: '거래 위치'),
              ),
              SizedBox(height: 15),
              TextField(
                controller: _dailyPriceController,
                decoration: InputDecoration(labelText: '하루 가격'),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 15),
              TextField(
                controller: _monthlyPriceController,
                decoration: InputDecoration(labelText: '한달 가격'),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 15),
              TextField(
                controller: _openChatController,
                decoration: InputDecoration(labelText: '카카오톡 오픈채팅방 링크'),
              ),
              SizedBox(height: 20),
              Text(
                '대표 사진 포함 최대 5개 업로드:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Wrap(
                spacing: 8.0,
                children: _images.map((image) {
                  return Stack(
                    alignment: Alignment.topRight,
                    children: [
                      Image.network(
                        image,
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                      IconButton(
                        icon: Icon(Icons.close, color: Colors.blue),
                        onPressed: () {
                          setState(() {
                            _images.remove(image);
                          });
                        },
                      ),
                    ],
                  );
                }).toList(),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    if (_images.length < 5) {
                      _images.add('https://via.placeholder.com/150');
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('최대 5개의 이미지만 업로드할 수 있습니다.')),
                      );
                    }
                  });
                },
                child: Text('사진 추가'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitItem,
                child: Text('등록'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
