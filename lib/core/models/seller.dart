class Seller {
  final String id;
  final String name;
  final String location;
  final double rating;

  const Seller({
    required this.id,
    required this.name,
    required this.location,
    this.rating = 0,
  });

  Seller copyWith({String? name, String? location, double? rating}) {
    return Seller(
      id: id,
      name: name ?? this.name,
      location: location ?? this.location,
      rating: rating ?? this.rating,
    );
  }
}
