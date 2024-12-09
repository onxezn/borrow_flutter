class ItemDetailsDto {
  final BigInt itemId;
  final String imageUrl;
  final String name;
  final BigInt dailyPrice;
  final int likeCount;

  ItemDetailsDto({
    required this.itemId,
    required this.imageUrl,
    required this.name,
    required this.dailyPrice,
    required this.likeCount,
  });

  factory ItemDetailsDto.fromJson(Map<String, dynamic> json) {
    return ItemDetailsDto(
      itemId: BigInt.from(json['itemId']),
      imageUrl: json['imageUrl'] ?? 'https://via.placeholder.com/150', // 기본 이미지 URL
      name: json['name'],
      dailyPrice: BigInt.from(json['dailyPrice']),
      likeCount: json['likeCount'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'itemId': itemId.toString(),
      'imageUrl': imageUrl,
      'name': name,
      'dailyPrice': dailyPrice.toString(),
      'likeCount': likeCount,
    };
  }
}