import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:borrow_app/model/user_profile_dto.dart';
import 'my_posts_screen.dart';
import 'borrowed_items_screen.dart';
import 'package:borrow_app/global_variables.dart';
import 'favorite_screen.dart';

class MyPageScreen extends StatelessWidget {
  Future<UserProfileDto> _fetchUserProfile() async {
    final url = Uri.parse('http://10.0.2.2:8080/user/profile/$globalUserId'); // 예시 userId
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return UserProfileDto.fromJson(json.decode(response.body));
      } else {
        throw Exception('프로필 불러오기 실패');
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
        title: Text(
          '마이페이지',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              // 설정 버튼 동작
            },
          ),
        ],
      ),
      body: FutureBuilder<UserProfileDto>(
        future: _fetchUserProfile(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('오류 발생: ${snapshot.error}'));
          } else {
            final profile = snapshot.data!;
            return SingleChildScrollView(
              child: Column(
                children: [
                  // 헤더 섹션
                  Stack(
                    children: [
                      Container(
                        height: 200,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.indigo, Colors.blueAccent],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                      ),
                      Positioned.fill(
                        child: Align(
                          alignment: Alignment.center,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircleAvatar(
                                radius: 50,
                                backgroundImage: profile.profilePic.isNotEmpty
                                    ? NetworkImage(profile.profilePic)
                                    : null,
                                child: profile.profilePic.isEmpty
                                    ? Icon(Icons.person,
                                    size: 50, color: Colors.white)
                                    : null,
                              ),
                              SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Baseline(
                                    baseline: 26.0, // 기준선 높이 동일
                                    baselineType: TextBaseline.alphabetic,
                                    child: Text(
                                      'LV. 1',
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 5),
                                  Baseline(
                                    baseline: 24.0, // 기준선 높이
                                    baselineType: TextBaseline.alphabetic,
                                    child: Text(
                                      profile.nickName,
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),


                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  // 프로필 정보 섹션
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 5,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '프로필 정보',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Divider(),
                            ListTile(
                              leading: Icon(Icons.star, color: Colors.amber),
                              title: Text(
                                '평점',
                                style: TextStyle(fontSize: 16),
                              ),
                              trailing: Text(
                                profile.reviewAvg?.toStringAsFixed(1) ?? 'N/A',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ),
                            ListTile(
                              leading: Icon(Icons.history, color: Colors.blue),
                              title: Text(
                                '빌려준 횟수',
                                style: TextStyle(fontSize: 16),
                              ),
                              trailing: Text(
                                '${profile.lendCnt}',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ),
                            ListTile(
                              leading: Icon(Icons.shopping_cart,
                                  color: Colors.green),
                              title: Text(
                                '빌린 횟수',
                                style: TextStyle(fontSize: 16),
                              ),
                              trailing: Text(
                                '${profile.borrowCnt}',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // 버튼 섹션
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                    child: Column(
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => BorrowedItemsScreen()),
                            );
                          },
                          child: Text('빌린 목록 보기', style: TextStyle(fontSize: 20)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            minimumSize: Size(double.infinity, 50),
                          ),
                        ),
                        SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => MyPostsScreen()),
                            );
                          },
                          child: Text('내 게시글 보기', style: TextStyle(fontSize: 20)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            foregroundColor: Colors.white,
                            minimumSize: Size(double.infinity, 50),
                          ),
                        ),
                        SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => FavoritesScreen()),
                            );
                          },
                          child: Text('찜한 목록 보기', style: TextStyle(fontSize: 20)), // 새 버튼 추가 및 글자 크기 설정
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.lightBlue,
                            foregroundColor: Colors.white,
                            minimumSize: Size(double.infinity, 50),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
