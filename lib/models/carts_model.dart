import 'package:cloud_firestore/cloud_firestore.dart';

class CartItem {
  final String id; // ID dokumen di cart
  final String productId;
  final String name;
  final double price;
  final String imagePath; // Konsisten dengan Product model (sebelumnya imageUrl)
  final int quantity;
  final bool isSelected; // Tambahan untuk fitur Checkbox

  CartItem({
    required this.id,
    required this.productId,
    required this.name,
    required this.price,
    required this.imagePath,
    required this.quantity,
    this.isSelected = false, // Default tidak tercentang
  });

  double get totalPrice => price * quantity;

  // 1. Konversi dari Firestore DocumentSnapshot ke Object Dart
  factory CartItem.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return CartItem(
      id: doc.id,
      productId: data['productId'] ?? '',
      name: data['name'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      imagePath: data['imagePath'] ?? '', 
      quantity: (data['quantity'] ?? 1).toInt(),
      isSelected: data['isSelected'] ?? false,
    );
  }

  // 2. Konversi dari Map (Berguna jika data diambil dari field array 'items' di Order)
  factory CartItem.fromMap(Map<String, dynamic> data) {
    return CartItem(
      id: data['id'] ?? '',
      productId: data['productId'] ?? '',
      name: data['name'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      imagePath: data['imagePath'] ?? '',
      quantity: (data['quantity'] ?? 1).toInt(),
      isSelected: data['isSelected'] ?? false,
    );
  }

  // 3. Konversi ke Map untuk disimpan ke Firestore
  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'name': name,
      'price': price,
      'imagePath': imagePath,
      'quantity': quantity,
      'isSelected': isSelected,
    };
  }
}