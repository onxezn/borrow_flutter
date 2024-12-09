class ItemDto {
  final BigInt id;
  final BigInt userId;
  final BigInt categoryId;
  final String name;
  final String content;
  final String location;
  final BigInt dailyPrice;
  final BigInt monthlyPrice;
  final DateTime recentTimestamp;
  final bool status;
  final List<String> imageUrls;
  final String? openChatLink;



  ItemDto({
    required this.id,
    required this.userId,
    required this.categoryId,
    required this.name,
    required this.content,
    required this.location,
    required this.dailyPrice,
    required this.monthlyPrice,
    required this.recentTimestamp,
    required this.status,
    required this.imageUrls,
    required this.openChatLink, // 선택적으로 추가


  });

  factory ItemDto.fromJson(Map<String, dynamic> json) {
    return ItemDto(
      id: BigInt.from(json['id']),
      // int -> BigInt 변환
      userId: BigInt.from(json['userId']),
      // int -> BigInt 변환
      categoryId: BigInt.from(json['categoryId']),
      // int -> BigInt 변환
      name: json['name'],
      content: json['content'],
      location: json['location'],
      dailyPrice: BigInt.from(json['dailyPrice']),
      // int -> BigInt 변환
      monthlyPrice: BigInt.from(json['monthlyPrice']),
      // int -> BigInt 변환
      recentTimestamp: DateTime.parse(json['recentTimestamp']),
      status: json['status'],
      imageUrls: List<String>.from(json['imageUrls']),
      openChatLink: json['openChatLink'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id.toString(),
      'userId': userId.toString(),
      'categoryId': categoryId.toString(),
      'name': name,
      'content': content,
      'location': location,
      'dailyPrice': dailyPrice.toString(),
      'monthlyPrice': monthlyPrice.toString(),
      'recentTimestamp': recentTimestamp.toIso8601String(),
      'status': status,
      'imageUrls': imageUrls,
      'openChatLink': openChatLink,
    };
  }
}