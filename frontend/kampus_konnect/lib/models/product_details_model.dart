import '../main.dart';
class ProductDetails {
  final int postId;
  final String owner;
  final String title;
  final String body;
  final bool sold;
  final String openingTimestamp;
  final int price;
  final List<String> imageUrls;
  final int reports;

  ProductDetails({
    required this.postId,
    required this.owner,
    required this.title,
    required this.body,
    required this.sold,
    required this.openingTimestamp,
    required this.price,
    required this.imageUrls,
    required this.reports,
  });

  factory ProductDetails.fromJson(Map<String, dynamic> json) {
    const String baseUrl=MyApp.baseUrl;
    return ProductDetails(
      postId: json['post_id'],
      owner: json['owner'],
      title: json['title'],
      body: json['body'],
      sold: json['sold'],
      openingTimestamp: json['opening_timestamp'],
      price: json['price'],
       imageUrls: (json['images'] as String)
          .split(',')
          .map((imagePath) => '$baseUrl/res/$imagePath')
          .toList(),
      reports: json['reports'],
    );
  }
}