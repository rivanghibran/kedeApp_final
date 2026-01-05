import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imagePath; // Diubah dari imageUrl agar sesuai UI Anda
  final String category;
  final double rating;
  final int stock;
  final bool isFavorite; // Untuk kompatibilitas dengan UI lama

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imagePath,
    required this.category,
    this.rating = 0.0,
    this.stock = 0,
    this.isFavorite = false,
  });

  // Konversi dari DocumentSnapshot Firestore ke Object Dart
  factory Product.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Product(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      // Pastikan konversi ke double aman (kadang Firestore simpan int)
      price: (data['price'] ?? 0).toDouble(),
      imagePath: data['imagePath'] ?? '', // Menggunakan key imagePath
      category: data['category'] ?? 'General',
      rating: (data['rating'] ?? 0.0).toDouble(),
      stock: data['stock'] ?? 0,
      isFavorite: false, // Default false, nanti dicek via Wishlist Service
    );
  }

  // Konversi dari Object Dart ke Map untuk upload ke Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'imagePath': imagePath,
      'category': category,
      'rating': rating,
      'stock': stock,
      'searchKeywords': _generateKeywords(name), // Opsional: untuk fitur search
    };
  }

  // Helper untuk pencarian sederhana di Firestore
  List<String> _generateKeywords(String title) {
    List<String> keywords = [];
    String temp = "";
    for (int i = 0; i < title.length; i++) {
      temp = temp + title[i].toLowerCase();
      keywords.add(temp);
    }
    return keywords;
  }
}