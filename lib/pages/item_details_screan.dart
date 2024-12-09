import 'package:borrow_app/model/item_dto.dart';
import 'package:borrow_app/model/user_profile_dto.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:borrow_app/global_variables.dart';
import 'post_update_screen.dart';

class ItemDetailScreen extends StatefulWidget {
  final BigInt itemId;
  final String openChatLink;

  const ItemDetailScreen({
    required this.itemId,
    required this.openChatLink,
  });

  @override
  _ItemDetailScreenState createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends State<ItemDetailScreen> {
  ItemDto? itemDetails;
  UserProfileDto? userProfileDto;
  bool isLoading = true;
  bool isLiked = false; // 좋아요 상태 관리

  @override
  void initState() {
    super.initState();
    _initializeScreen();
  }

  Future<void> _initializeScreen() async {
    await _fetchItemDetails(); // itemDetails를 먼저 가져옴
    if (itemDetails?.userId != globalUserId) {
      await _checkLikeStatus(); // 좋아요 상태 확인
    }
  }

  // 게시글 상세 정보 가져오기
  Future<void> _fetchItemDetails() async {
    final itemUrl = Uri.parse('http://10.0.2.2:8080/items/posted/${widget.itemId}');
    try {
      final response = await http.get(itemUrl);
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        print("Fetched JSON Data: $jsonData"); // JSON 데이터 출력
        setState(() {
          itemDetails = ItemDto.fromJson(json.decode(response.body));
          print("Fetched JSON Data: $jsonData"); // JSON 데이터 출력
        });
        _fetchUserProfile(itemDetails!.userId);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('게시글 정보를 불러오지 못했습니다.')),
        );
        setState(() => isLoading = false);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('네트워크 오류: $e')),
      );
      setState(() => isLoading = false);
    }
  }

  // 작성자 프로필 정보 가져오기
  Future<void> _fetchUserProfile(BigInt userId) async {
    final userUrl = Uri.parse('http://10.0.2.2:8080/user/profile/$userId');
    try {
      final response = await http.get(userUrl);
      if (response.statusCode == 200) {
        setState(() {
          userProfileDto = UserProfileDto.fromJson(json.decode(response.body));
          isLoading = false;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('작성자 정보를 불러오지 못했습니다.')),
        );
        setState(() => isLoading = false);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('네트워크 오류: $e')),
      );
      setState(() => isLoading = false);
    }
  }

  // 좋아요 상태 확인
  Future<void> _checkLikeStatus() async {
    if (itemDetails?.userId == BigInt.from(globalUserId ?? 0)) return; // 작성자는 좋아요 확인 X
    final url = Uri.parse('http://10.0.2.2:8080/check-likes?userId=$globalUserId&itemId=${widget.itemId}');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          isLiked = json.decode(response.body);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('좋아요 상태를 확인할 수 없습니다.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('네트워크 오류: $e')),
      );
    }
  }

  // 좋아요 토글
  Future<void> _toggleLike() async {
    final url = Uri.parse('http://10.0.2.2:8080/items/like/${widget.itemId}?userId=$globalUserId');
    try {
      final response = await http.post(url);
      if (response.statusCode == 200) {
        setState(() {
          isLiked = !isLiked;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('좋아요 상태 변경 실패: ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('네트워크 오류: $e')),
      );
    }
  }

  Future<void> updateItem(BigInt itemId, ItemDto updatedItem) async {
    final url = Uri.parse('http://10.0.2.2:8080/items/posted/$itemId');
    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(updatedItem.toJson()),
      );

      if (response.statusCode == 200) {
        // 수정 성공
        final String redirectUrl = response.body;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('게시글이 성공적으로 수정되었습니다!')),
        );

        // 수정된 상세 페이지로 이동
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ItemDetailScreen(
              itemId: itemId,
              openChatLink: updatedItem.openChatLink ?? '',
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('게시글 수정 실패: ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('네트워크 오류: $e')),
      );
    }
  }

  Future<bool> deleteItem(BigInt itemId) async {
    final url = Uri.parse('http://10.0.2.2:8080/items/posted/$itemId');
    try {
      final response = await http.delete(url);

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('게시글이 삭제되었습니다.')),
        );
        return true;

      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('게시글 삭제 실패: ${response.body}')),
        );
        return false;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('네트워크 오류: $e')),
      );
      return false;
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true, // 뒤로가기 버튼 활성화
        backgroundColor: Colors.blue[800],
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text(
              '게시글 상세',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            SizedBox(width: 130),
            Image.asset(
              'assets/borrow_logo.png',
              width: 60,
              height: 60,
              fit: BoxFit.contain,
            ),
          ],
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 이미지
              Container(
                width: double.infinity,
                height: MediaQuery.of(context).size.height * 0.4,
                child: itemDetails!.imageUrls.isNotEmpty
                    ? Image.network(
                  itemDetails!.imageUrls[0],
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(Icons.image_not_supported, size: 100);
                  },
                )
                    : Icon(Icons.image_not_supported, size: 100),
              ),
              SizedBox(height: 20),
              // 작성자 정보와 수정/삭제 버튼
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.grey[300],
                        backgroundImage: userProfileDto != null &&
                            userProfileDto!.profilePic.isNotEmpty
                            ? NetworkImage(userProfileDto!.profilePic)
                            : null,
                        child: userProfileDto == null ||
                            userProfileDto!.profilePic.isEmpty
                            ? Icon(Icons.person, size: 30, color: Colors.white)
                            : null,
                      ),
                      SizedBox(width: 10),
                      Text(
                        userProfileDto?.nickName ?? '알 수 없음',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),

                  if (itemDetails?.userId == BigInt.from(globalUserId ?? 0))
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit, color: Colors.lightBlue),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PostUpdateScreen(
                                  itemDetails: itemDetails!.toJson(), // JSON 형식으로 전달
                                ),
                              ),
                            ).then((result) {
                              if (result == true) {
                                _fetchItemDetails(); // 수정 후 상세 페이지 데이터 새로고침
                              }
                            });
                          },
                        ),

                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text('게시글 삭제'),
                                  content: Text('정말로 게시글을 삭제하시겠습니까?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop(); // 다이얼로그 닫기
                                      },
                                      child: Text('취소'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop(); // 다이얼로그 닫기
                                        deleteItem(itemDetails!.id).then((isDeleted) {
                                          if (isDeleted) {
                                            Navigator.pop(context, true); // 호출 화면으로 true 반환
                                          }
                                        });
                                      },
                                      child: Text('삭제', style: TextStyle(color: Colors.red)),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                ],
              ),
              SizedBox(height: 20),
              // 제목과 좋아요 버튼
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    itemDetails!.name,
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  if (itemDetails?.userId != BigInt.from(globalUserId ?? 0))
                    IconButton(
                      icon: Icon(
                        isLiked ? Icons.favorite : Icons.favorite_border,
                        color: isLiked ? Colors.red : Colors.grey,
                      ),
                      onPressed: _toggleLike,
                    ),
                ],
              ),
              SizedBox(height: 10),
              // 위치 정보
              Row(
                children: [
                  Icon(Icons.location_on, color: Colors.grey),
                  SizedBox(width: 5),
                  Text(
                    '위치: ${itemDetails!.location}',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Text(
                '내용:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 5),
              Text(
                itemDetails!.content,
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 20),
              Divider(thickness: 1, color: Colors.grey[300]),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '하루 가격',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${itemDetails!.dailyPrice}원',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '한달 가격',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${itemDetails!.monthlyPrice}원',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Text(
                '오픈채팅방 링크:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 5),
          SelectableText(
            itemDetails?.openChatLink ?? '오픈채팅방 링크가 없습니다.',
            style: TextStyle(
              fontSize: 16,
              color: Colors.blue,
              decoration: TextDecoration.underline,
            ),
            contextMenuBuilder: (BuildContext context, EditableTextState editableTextState) {
              return AdaptiveTextSelectionToolbar(
                anchors: editableTextState.contextMenuAnchors,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // 메뉴 닫기
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('복사하여 브라우저에서 열어주세요.')),
                      );
                    },
                    child: Text('복사'), // 텍스트만 변경
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // 메뉴 닫기
                    },
                    child: Text('닫기'),
                  ),
                ],
              );
            },
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('복사하여 브라우저에서 열어주세요.')),
              );
            },
          )

          ],
          ),
        ),
      ),
    );
  }
}
