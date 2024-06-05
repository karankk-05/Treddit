// models/product.dart
class Product {
  final int id;
  final String owner;
  final String title;
  final String body;
  final DateTime openingTimestamp;
  final int price;
  final List<String> imageUrls;
  final int reports;

  Product({
    required this.id,
    required this.owner,
    required this.title,
    required this.body,
    required this.openingTimestamp,
    required this.price,
    required this.imageUrls,
    required this.reports,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    const String baseUrl = 'http://10.0.2.2:3000/res/';
    return Product(
      id: json['post_id'],
      owner: json['owner'],
      title: json['title'],
      body: json['body'],
      openingTimestamp: DateTime.parse(json['opening_timestamp']),
      price: json['price'],
      imageUrls: (json['images'] as String)
          .split(',')
          .map((imagePath) => baseUrl + imagePath)
          .toList(),
      reports: json['reports'],
    );
  }
}
