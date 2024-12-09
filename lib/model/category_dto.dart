class CategoryDto {
  final BigInt id;
  final String name;

  CategoryDto({
    required this.id,
    required this.name,
  });

  factory CategoryDto.fromJson(Map<String, dynamic> json) {
    return CategoryDto(
      id: BigInt.from(json['id']),
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id.toString(),
      'name': name,
    };
  }
}
