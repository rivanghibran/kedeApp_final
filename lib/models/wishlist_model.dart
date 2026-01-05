import 'package:cloud_firestore/cloud_firestore.dart';

class WishlistItem {
  final String id; // ID dokumen wishlist
  final String productId;
  final String name;
  final double price;
  final String imagePath; // Diubah dari imageUrl agar konsisten
  final DateTime addedAt;

  WishlistItem({
    required this.id,
    required this.productId,
    required this.name,
    required this.price,
    required this.imagePath,
    required this.addedAt,
  });

  factory WishlistItem.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return WishlistItem(
      id: doc.id,
      productId: data['productId'] ?? '',
      name: data['name'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      imagePath: data['imagePath'] ?? '',
      // Konversi Timestamp Firestore ke DateTime Dart (dengan safety check)
      addedAt: (data['addedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'name': name,
      'price': price,
      'imagePath': imagePath,
      'addedAt': FieldValue.serverTimestamp(), // Gunakan waktu server
    };
  }
}