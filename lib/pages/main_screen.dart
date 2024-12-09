import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'add_item_screen.dart';
import 'favorite_screen.dart';
import 'item_details_screan.dart';
import 'my_page_screen.dart';
import 'search_result_screen.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  List<dynamic> _recentItems = [];
  List<dynamic> _popularItems = [];
  bool _isLoadingRecent = true;
  bool _isLoadingPopular = true;

  @override
  void initState() {
    super.initState();
    _fetchRecentItems();
    _fetchPopularItems();
  }

  Future<void> _fetchRecentItems() async {
    final url = Uri.parse('http://10.0.2.2:8080/items/recent-items');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          _recentItems = json.decode(response.body);
          _isLoadingRecent = false;
        });
      } else {
        _showSnackBar('최근 게시글 불러오기 실패');
      }
    } catch (e) {
      _showSnackBar('네트워크 오류: $e');
    }
  }

  Future<void> _fetchPopularItems() async {
    final url = Uri.parse('http://10.0.2.2:8080/items/popular-items');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          _popularItems = json.decode(response.body);
          _isLoadingPopular = false;
        });
      } else {
        _showSnackBar('인기 게시글 불러오기 실패');
      }
    } catch (e) {
      _showSnackBar('네트워크 오류: $e');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        await _fetchRecentItems();
        await _fetchPopularItems();
        return true;
      },
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(60), // 앱바의 높이를 조정
          child: AppBar(
            backgroundColor: Colors.blue[800],
            title: Row(
              children: [
                Image.asset(
                  'assets/borrow_logo.png',
                  width: 70, // 로고 크기 확대
                  height: 70,
                ),
                SizedBox(width: 10),
                Text(
                  '빌려지누',
                  style: TextStyle(
                    fontFamily: 'BlackHanSans',
                    fontSize: 32, // 텍스트 크기 확대
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.search, size: 30), // 검색 아이콘 크기 확대
                onPressed: _showSearchDialog,
              ),
            ],
          ),
        ),
        body: _buildScreen(_currentIndex),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _currentIndex,
          onTap: (index) async {
            if (index == 2) {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddItemScreen(),
                ),
              );
              if (result == true) {
                _fetchRecentItems(); // 새로고침
              }
            } else {
              setState(() {
                _currentIndex = index;
              });
            }
          },
          items: [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: '홈'),
            BottomNavigationBarItem(icon: Icon(Icons.favorite), label: '찜한 목록'),
            BottomNavigationBarItem(icon: Icon(Icons.add), label: '등록'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: '마이페이지'),
          ],
        ),

      ),
    );
  }

  Widget _buildScreen(int index) {
    switch (index) {
      case 0:
        return _buildHomeScreen();
      case 1:
        return FavoritesScreen();
      case 2:
        return AddItemScreen();
      case 3:
        return MyPageScreen();
      default:
        return _buildHomeScreen();
    }
  }

  Widget _buildHomeScreen() {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildSectionTitle('최근 등록된 게시글'),
          _isLoadingRecent
              ? Center(child: CircularProgressIndicator())
              : _buildItemList(_recentItems),
          _buildSectionTitle('인기 게시글'),
          _isLoadingPopular
              ? Center(child: CircularProgressIndicator())
              : _buildItemList(_popularItems),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
      child: Text(
        title,
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildItemList(List<dynamic> items) {
    return items.isEmpty
        ? Center(child: Text('게시글이 없습니다.'))
        : ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final imageUrl = item['imageUrl'] ?? '';

        return Card(
          margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: ListTile(
            contentPadding: EdgeInsets.all(8),
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: imageUrl.isNotEmpty
                  ? Image.network(
                imageUrl,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(Icons.image_not_supported, size: 50);
                },
              )
                  : Icon(Icons.image_not_supported, size: 50),
            ),
            title: Text(
              item['name'] ?? '제목 없음',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            subtitle: Text(
              '가격: ${item['dailyPrice']}원\n찜: ${item['likeCount']}개',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ItemDetailScreen(
                    itemId: BigInt.from(item['itemId']),
                    openChatLink: item['openChatLink'] ?? '',
                  ),
                ),
              );
              if (result == true) {
                await _fetchRecentItems();
                await _fetchPopularItems();
              }
            },
          ),
        );
      },
    );
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) {
        String _searchKeyword = '';
        String? _selectedCategory;

        return AlertDialog(
          title: Text('검색'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                onChanged: (value) {
                  _searchKeyword = value;
                },
                decoration: InputDecoration(labelText: '키워드 입력'),
              ),
              DropdownButton<String>(
                value: _selectedCategory,
                hint: Text('카테고리 선택'),
                onChanged: (value) {
                  _selectedCategory = value;
                },
                items: ['가전', '가구', '디지털'].map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SearchResultsScreen(
                      keyword: _searchKeyword,
                      category: _selectedCategory,
                    ),
                  ),
                );
              },
              child: Text('검색'),
            ),
          ],
        );
      },
    );
  }
}
