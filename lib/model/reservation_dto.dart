class ReservationDto {
  final BigInt id;
  final BigInt itemId;
  final BigInt userId;
  final DateTime startDate;
  final DateTime endDate;

  ReservationDto({
    required this.id,
    required this.itemId,
    required this.userId,
    required this.startDate,
    required this.endDate,
  });

  factory ReservationDto.fromJson(Map<String, dynamic> json) {
    return ReservationDto(
      id: BigInt.from(json['id']),
      itemId: BigInt.from(json['itemId']),
      userId: BigInt.from(json['userId']),
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id.toString(),
      'itemId': itemId.toString(),
      'userId': userId.toString(),
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
    };
  }
}
