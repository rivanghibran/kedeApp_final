// lib/screens/category_list_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Tambahkan ini
// import 'package:flutter_svg/flutter_svg.dart'; // Hapus/Comment ini jika tidak dipakai lagi

import '../main.dart';
import '../models/category.dart';
import 'category_detail_screen.dart';

class CategoryListScreen extends StatelessWidget {
  const CategoryListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: kTextColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Categories',
          style: TextStyle(color: kTextColor, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
      ),
      // MENGGUNAKAN STREAMBUILDER UNTUK DATA REALTIME
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('categories').snapshots(),
        builder: (context, snapshot) {
          // 1. Loading State
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // 2. Error State
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          // 3. Empty State
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No categories found."));
          }

          final docs = snapshot.data!.docs;

          return ListView.separated(
            padding: const EdgeInsets.all(20.0),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              // Konversi Dokumen Firestore -> Model Category
              final category = Category.fromFirestore(docs[index]);
              return _buildCategoryCard(context, category);
            },
            separatorBuilder: (context, index) => const SizedBox(height: 16),
          );
        },
      ),
    );
  }

  Widget _buildCategoryCard(BuildContext context, Category category) {
    // Logika ubah SVG ke PNG (Konsisten dengan halaman detail)
    final String pngIconPath = category.iconPath.replaceAll('.svg', '.png');

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CategoryDetailScreen(
              categoryName: category.name,
              iconPath: category.iconPath, // Kirim path asli (atau pngIconPath jika mau diubah dari awal)
              itemCount: category.itemCount,
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(20.0),
        height: 110,
        decoration: BoxDecoration(
          color: kPrimaryColor, // Pastikan kPrimaryColor ada di main.dart
          borderRadius: BorderRadius.circular(20),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Background Icon (Besar & Transparan)
            Positioned(
              left: -20,
              bottom: -40,
              child: Image.asset(
                pngIconPath,
                width: 120,
                height: 120,
                // Efek transparan menggunakan Image.asset
                color: Colors.white.withOpacity(0.1),
                colorBlendMode: BlendMode.srcIn,
                errorBuilder: (context, error, stackTrace) =>
                    const SizedBox(), // Sembunyikan jika error
              ),
            ),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${category.itemCount} Items',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                
                // Icon Kecil di Kanan
                Image.asset(
                  pngIconPath,
                  width: 50,
                  height: 50,
                  color: Colors.white,
                  colorBlendMode: BlendMode.srcIn,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.image_not_supported, color: Colors.white),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}