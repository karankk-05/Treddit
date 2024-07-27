import '../../main.dart';

class PostCard {
  final int postId;
  final String title;
  final int price;
  final String image;
  static String _baseUrl = MyApp.baseUrl;

  PostCard({
    required this.postId,
    required this.title,
    required this.price,
    required this.image,
  });

  factory PostCard.fromJson(Map<String, dynamic> json, int postId) {
    return PostCard(
      postId: postId,
      title: json['title'],
      price: json['price'],
      image: '$_baseUrl/res/${json['image']}',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'post_id': postId,
      'title': title,
      'price': price,
      'image': image,
    };
  }
}
