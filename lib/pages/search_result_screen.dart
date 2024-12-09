import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'item_details_screan.dart';

class SearchResultsScreen extends StatelessWidget {
  final String keyword;
  final String? category;

  SearchResultsScreen({required this.keyword, this.category});

  Future<List<dynamic>> _fetchSearchResults() async {
    final url = Uri.parse(
        'http://10.0.2.2:8080/items/search?categoryId=${category ?? ''}&keyword=$keyword');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('검색 결과 불러오기 실패');
      }
    } catch (e) {
      throw Exception('네트워크 오류: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[800],
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            SizedBox(width: 10), // 로고와 텍스트 간격
            Text(
              '검색 결과',
              style: TextStyle(
                color: Colors.white, // 하얀색 텍스트
                fontWeight: FontWeight.bold,
                fontSize: 24, // 텍스트 크기
              ),
            ),
            SizedBox(width: 130), // 로고와 텍스트 간격
            Image.asset(
              'assets/borrow_logo.png', // 로고 이미지 경로
              width: 60, // 로고 너비
              height: 60, // 로고 높이
              fit: BoxFit.contain,
            ),
          ],
        ),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _fetchSearchResults(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, color: Colors.red, size: 50),
                  SizedBox(height: 10),
                  Text(
                    '오류 발생: ${snapshot.error}',
                    style: TextStyle(color: Colors.red, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          } else if (snapshot.data == null || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_off, color: Colors.grey, size: 60),
                  SizedBox(height: 10),
                  Text(
                    '검색 결과가 없습니다.',
                    style: TextStyle(color: Colors.grey, fontSize: 18),
                  ),
                ],
              ),
            );
          } else {
            return ListView.builder(
              padding: EdgeInsets.all(8.0),
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final item = snapshot.data![index];
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 6,
                  shadowColor: Colors.blue[200],
                  margin: EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    contentPadding: EdgeInsets.all(12),
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: item['imageUrl'] != null
                          ? Image.network(
                        item['imageUrl'],
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(Icons.image_not_supported,
                              size: 60);
                        },
                      )
                          : Icon(Icons.image_not_supported, size: 60),
                    ),
                    title: Text(
                      item['name'] ?? '제목 없음',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '가격: ${item['dailyPrice']}원',
                          style:
                          TextStyle(color: Colors.black54, fontSize: 15),
                        ),
                        Text(
                          '찜: ${item['likeCount']}개',
                          style: TextStyle(color: Colors.grey, fontSize: 15),
                        ),
                      ],
                    ),
                    trailing: Icon(Icons.chevron_right, color: Colors.grey),
                    onTap: () {
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
