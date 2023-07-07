class CategoryModel {
  late String id;
  late String name;
  late String image;

  CategoryModel({
    required this.id,
    required this.name,
    required this.image,
  });

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['image'] = image;

    return data;
  }

  CategoryModel.fromJson(Map<String, dynamic> json) {
    id = json['id'] ?? '';
    name = json['name'] ?? '';
    image = json['image'] ?? '';
  }

  CategoryModel copyWith({
    String? id,
    String? name,
    String? image

  }) {
    return CategoryModel(
      id: id ?? this.id,
      name: name?? this.name,
      image: image?? this.image,

    );
  }
}
