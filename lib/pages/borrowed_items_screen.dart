import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:borrow_app/global_variables.dart';
import 'item_details_screan.dart';

class BorrowedItemsScreen extends StatelessWidget {
  Future<List<dynamic>> _fetchBorrowedItems() async {
    final url = Uri.parse('http://10.0.2.2:8080/items/borrowed/$globalUserId');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('빌린 목록 불러오기 실패');
      }
    } catch (e) {
      throw Exception('네트워크 오류: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[900],
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '빌린 목록',
              style: TextStyle(
                fontSize: 24,
                color: Colors.white,
              ),
            ),
            Image.asset(
              'assets/borrow_logo.png', // 로고 이미지 경로
              width: 50,
              height: 50,
              fit: BoxFit.contain,
            ),
          ],
        ),
        centerTitle: true,
        elevation: 5,
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _fetchBorrowedItems(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('오류 발생: ${snapshot.error}'));
          } else if (snapshot.data == null || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    '빌린 게시글이 없습니다.',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            );
          } else {
            final items = snapshot.data!;
            return ListView.builder(
              itemCount: items.length,
              padding: EdgeInsets.all(10),
              itemBuilder: (context, index) {
                final item = items[index];
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 4,
                  child: ListTile(
                    contentPadding: EdgeInsets.all(10),
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: item['imageUrl'] != null && item['imageUrl'].isNotEmpty
                          ? Image.network(
                        item['imageUrl'],
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(Icons.image_not_supported, size: 60);
                        },
                      )
                          : Icon(Icons.image_not_supported, size: 60),
                    ),
                    title: Text(
                      item['name'] ?? '제목 없음',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    subtitle: Text(
                      '가격: ${item['dailyPrice']}원',
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                    trailing: Icon(Icons.chevron_right, color: Colors.grey),
                    onTap: () {
                      // 게시글 상세 화면으로 이동
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ItemDetailScreen(
                            itemId: BigInt.from(item['itemId']),
                            openChatLink: item['openChatLink'] ?? '',
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
