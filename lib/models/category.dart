import 'package:cloud_firestore/cloud_firestore.dart';

class Category {
  final String id;
  final String name;
  final int itemCount;
  final String iconPath; // URL atau path asset SVG

  const Category({
    required this.id,
    required this.name,
    required this.itemCount,
    required this.iconPath,
  });

  // 1. Mengambil data dari Firestore (Read)
  factory Category.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Category(
      id: doc.id,
      name: data['name'] ?? 'Unknown',
      // Pastikan konversi ke int aman
      itemCount: (data['itemCount'] ?? 0).toInt(),
      iconPath: data['iconPath'] ?? '',
    );
  }

  // 2. Mengubah object menjadi Map untuk disimpan ke Firestore (Create/Update)
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'itemCount': itemCount,
      'iconPath': iconPath,
    };
  }

  // 3. (Opsional) Factory untuk data dummy/statis jika belum ada backend
  factory Category.fromMap(Map<String, dynamic> map, String id) {
    return Category(
      id: id,
      name: map['name'] ?? '',
      itemCount: map['itemCount'] ?? 0,
      iconPath: map['iconPath'] ?? '',
    );
  }
}