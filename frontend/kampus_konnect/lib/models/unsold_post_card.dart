import '../main.dart';
class PostCard {
  final String title;
  final int price;
  final String image;
  final bool? isWishlisted;
  static String _baseUrl=MyApp.baseUrl;

  PostCard(
      {required this.title,
      required this.price,
      required this.image,
      this.isWishlisted});

  factory PostCard.fromJson(Map<String, dynamic> json) {
    return PostCard(
      title: json['title'],
      price: json['price'],
      image:  '$_baseUrl/res/${json['image']}'
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'price': price,
      'image': image,
    };
  }
}
