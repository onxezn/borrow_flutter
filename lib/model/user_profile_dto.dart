class UserProfileDto {
  final String profilePic;
  final String nickName;
  final BigInt lendCnt;
  final BigInt borrowCnt;
  final double? reviewAvg;

  UserProfileDto({
    required this.profilePic,
    required this.nickName,
    required this.lendCnt,
    required this.borrowCnt,
    this.reviewAvg,
  });

  factory UserProfileDto.fromJson(Map<String, dynamic> json) {
    return UserProfileDto(
      profilePic: json['profilePic'] ?? 'https://via.placeholder.com/150',
      nickName: json['nickName'],
      lendCnt: BigInt.from(json['lendCnt']),
      borrowCnt: BigInt.from(json['borrowCnt']),
      reviewAvg: json['reviewAvg'] != null ? json['reviewAvg'].toDouble() : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'profilePic': profilePic,
      'nickName': nickName,
      'lendCnt': lendCnt.toString(),
      'borrowCnt': borrowCnt.toString(),
      'reviewAvg': reviewAvg,
    };
  }
}