class Recipe {
  final String id;
  final String title;
  final String shortDescription;
  final String fullDescription;
  final String imageUrl;
  final double price;
  final String currency;
  final int likes;
  final double rating;
  final List<String> ingredients;
  final List<String> instructions;


  Recipe({
    required this.id,
    required this.title,
    required this.shortDescription,
    required this.fullDescription,
    required this.imageUrl,
    required this.price,
    this.currency = 'USD',
    required this.likes,
    required this.rating,
    required this.ingredients,
    required this.instructions,
  });


  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      shortDescription: json['shortDescription'] ?? '',
      fullDescription: json['fullDescription'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      price: (json['price'] ?? 0.0).toDouble(),
      currency: json['currency'] ?? 'USD',
      likes: json['likes'] ?? 0,
      rating: (json['rating'] ?? 0.0).toDouble(),
      ingredients: List<String>.from(json['ingredients'] ?? []),
      instructions: List<String>.from(json['instructions'] ?? []),
    );
  }


  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'shortDescription': shortDescription,
      'fullDescription': fullDescription,
      'imageUrl': imageUrl,
      'price': price,
      'currency': currency,
      'likes': likes,
      'rating': rating,
      'ingredients': ingredients,
      'instructions': instructions,
    };
  }
}