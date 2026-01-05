// lib/screens/category_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore

// Ganti 'kede_app' dengan nama proyek Anda di pubspec.yaml jika perlu
import '/main.dart'; 
import '../models/product_model.dart'; // Import model Product yang baru
import '/widgets/product_card.dart';

class CategoryDetailScreen extends StatelessWidget {
  final String categoryName;
  final String iconPath; 
  final int itemCount;

  const CategoryDetailScreen({
    super.key,
    required this.categoryName,
    required this.iconPath,
    required this.itemCount,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _buildHeader(context),
          _buildSearchBar(),
          const SizedBox(height: 16),
          
          // --- BAGIAN INI DIUBAH MENJADI STREAMBUILDER ---
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              // Query ke Firestore: ambil produk yang kategorinya sama dengan halaman ini
              stream: FirebaseFirestore.instance
                  .collection('products')
                  .where('category', isEqualTo: categoryName)
                  .snapshots(),
              builder: (context, snapshot) {
                // 1. Loading State
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                // 2. Error State
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                // 3. Empty State
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.search_off, size: 60, color: Colors.grey),
                        const SizedBox(height: 10),
                        Text('No items found in $categoryName', style: const TextStyle(color: Colors.grey)),
                      ],
                    ),
                  );
                }

                // 4. Data Ready State
                final docs = snapshot.data!.docs;
                
                return GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    // Konversi dokumen Firestore ke Model Product
                    Product product = Product.fromFirestore(docs[index]);
                    
                    // Tampilkan Card
                    return ProductCard(product: product);
                  },
                );
              },
            ),
          ),
          // --- BATAS PERUBAHAN ---
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    // Logika convert path SVG ke PNG (sesuai kode Anda sebelumnya)
    final String pngIconPath = iconPath.replaceAll('.svg', '.png');

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: kPrimaryColor,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            right: -40,
            bottom: -30,
            child: Image.asset(
              pngIconPath, 
              width: 150,
              height: 150,
              color: Colors.white.withOpacity(0.1), 
              colorBlendMode: BlendMode.srcIn,
              errorBuilder: (context, error, stackTrace) {
                // Fallback jika PNG tidak ditemukan, coba load original path atau icon default
                return const Icon(Icons.category, color: Colors.white10, size: 100);
              },
            ),
          ),
          
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.filter_list, color: Colors.white),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '$categoryName Category',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    // Jika data realtime, itemCount mungkin perlu diupdate dari snapshot, 
                    // tapi untuk sekarang kita pakai data dari halaman sebelumnya
                    '$itemCount items', 
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search here',
          hintStyle: const TextStyle(color: kTextLightColor),
          prefixIcon: const Icon(Icons.search, color: kTextLightColor),
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16.0),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
        // Implementasi logika search bisa ditambahkan di onChanged
        onChanged: (value) {
          // Todo: Implement local search filter logic
        },
      ),
    );
  }
}