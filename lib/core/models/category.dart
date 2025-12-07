class Category {
  final String id;
  final String name;
  final String description;

  const Category({required this.id, required this.name, this.description = ''});

  Category copyWith({String? name, String? description}) {
    return Category(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
    );
  }
}
