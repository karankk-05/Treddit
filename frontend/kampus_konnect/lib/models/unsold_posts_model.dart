// models/product.dart
import '../main.dart';

class Product {
  final int id;
  final String owner;
  final String title;
  final String body;
  final DateTime openingTimestamp;
  final int price;
  final bool isSold;
  final List<String> imageUrls;
  final int reports;
  bool? isWishlisted;

  Product({
    required this.id,
    required this.owner,
    required this.title,
    required this.body,
    required this.openingTimestamp,
    required this.price,
    required this.isSold,
    required this.imageUrls,
    required this.reports,
    this.isWishlisted,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    const String baseUrl = MyApp.baseUrl;
    return Product(
      id: json['post_id'],
      owner: json['owner'],
      title: json['title'],
      body: json['body'],
      openingTimestamp: DateTime.parse(json['opening_timestamp']),
      price: json['price'],
      isSold: json['sold'],
      imageUrls: (json['images'] as String)
          .split(',')
          .map((imagePath) => '${baseUrl}/res$imagePath')
          .toList(),
      reports: json['reports'],
    );
  }
}
