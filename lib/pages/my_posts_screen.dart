import 'package:borrow_app/global_variables.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'item_details_screan.dart';

class MyPostsScreen extends StatelessWidget {
  Future<List<dynamic>> _fetchMyPosts() async {
    final url = Uri.parse('http://10.0.2.2:8080/items/lent/$globalUserId');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('내 게시글 불러오기 실패');
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
              '내 게시글',
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
        future: _fetchMyPosts(),
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
                  Icon(Icons.post_add, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    '내 게시글이 없습니다.',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            );
          } else {
            final items = snapshot.data!;
            return ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
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
                      '가격: ${item['dailyPrice'] ?? 'N/A'}원',
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                      onTap: () async {
                        print("Selected Item Data: $item"); // 클릭한 아이템 전체 데이터 출력
                        final itemId = BigInt.tryParse('${item['id']}');

                        try {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ItemDetailScreen(
                                itemId: BigInt.from(item['itemId']),
                                openChatLink: item['openChatLink'] ?? '',
                              ),
                            ),
                          );
                        } catch (e) {
                          print("Error navigating to ItemDetailScreen: $e");
                        }
                      }

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
