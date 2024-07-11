// models/product.dart
import '../../main.dart';
class Product {
  final int id;
  final String owner;
  final String title;
  final String body;
  final DateTime openingTimestamp;
  final int price;
  final List<String> imageUrls;
  final int reports;
  final bool isSold;

  Product({
    required this.id,
    required this.owner,
    required this.title,
    required this.body,
    required this.openingTimestamp,
    required this.price,
    required this.imageUrls,
    required this.reports,
    required this.isSold
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
      imageUrls: (json['images'] as String)
          .split(',')
          .map((imagePath) => '$baseUrl/res/$imagePath')
          .toList(),
      reports: json['reports'],
      isSold: json['sold']
    );
  }
}
