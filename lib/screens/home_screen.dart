// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; 

// Import file proyek
import '../main.dart'; 
import '../models/product_model.dart'; // Perbaikan: product.dart bukan product_model.dart
import '../models/category.dart'; 
import '../widgets/product_card.dart'; 
import '../services/seeder_service.dart'; // Import service untuk upload data

import 'category_list_screen.dart'; 
import 'category_detail_screen.dart'; 
import 'product_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _firstName = 'User';
  String _lastName = '';
  
  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  void _loadUserName() {
    final user = FirebaseAuth.instance.currentUser;
    final fullName = user?.displayName ?? 'Guest User'; 
    
    String tempFirstName = ''; 
    String tempLastName = '';

    if (fullName != 'Guest User' && fullName.isNotEmpty) {
      final nameParts = fullName.split(' ');
      if (nameParts.isNotEmpty) {
        tempFirstName = nameParts.first;
      }
      if (nameParts.length > 1) {
        tempLastName = nameParts.sublist(1).join(' '); 
      }
    }

    if (tempFirstName.isEmpty) {
      tempFirstName = 'Hello';
    }

    if (mounted) {
      setState(() {
        _firstName = tempFirstName;
        _lastName = tempLastName;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      
      // --- TOMBOL SEMENTARA UNTUK UPLOAD DATA ---
      // Klik tombol ini sekali untuk mengisi database, setelah sukses tombol ini boleh dihapus.
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.red,
        icon: const Icon(Icons.cloud_upload, color: Colors.white),
        label: const Text("Isi Data Awal", style: TextStyle(color: Colors.white)),
        onPressed: () async {
          try {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Sedang mengupload data...")),
            );
            
            await SeederService().seedDatabase();
            
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("✅ Sukses! Data Pasar Jateng/DIY berhasil diupload.")),
              );
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Gagal: $e")),
              );
            }
          }
        },
      ),
      // -------------------------------------------

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              _buildRecipeCard(),
              const SizedBox(height: 32),
              
              _buildSectionHeader(
                title: 'Categories',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CategoryListScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              _buildCategoryList(context), 
              const SizedBox(height: 32),

              _buildSectionHeader(title: 'Trending Deals', onPressed: () {}),
              const SizedBox(height: 16),
              _buildTrendingList(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Good Morning',
                style: TextStyle(color: kTextLightColor, fontSize: 16)),
            Text('$_firstName $_lastName',
                style: const TextStyle(
                    color: kTextColor,
                    fontSize: 22,
                    fontWeight: FontWeight.bold)),
          ],
        ),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.notifications_none_outlined,
              color: kTextColor, size: 28),
        ),
      ],
    );
  }

  Widget _buildRecipeCard() {
    return Container(
      height: 180,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        image: const DecorationImage(
          image: AssetImage('assets/images/recipe_banner.jpg'),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [Colors.black.withOpacity(0.6), Colors.transparent],
          ),
        ),
        child: const Padding(
          padding: EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Recomended Recipe\nToday',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
      {required String title, required VoidCallback onPressed}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title,
            style: const TextStyle(
                color: kTextColor, fontSize: 20, fontWeight: FontWeight.bold)),
        IconButton(
          onPressed: onPressed,
          icon: const Icon(Icons.arrow_forward, color: kPrimaryColor),
        ),
      ],
    );
  }

  Widget _buildCategoryList(BuildContext context) {
    return SizedBox(
      height: 100, 
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('categories').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return const Text("Error loading categories");
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final docs = snapshot.data!.docs;
          if (docs.isEmpty) return const Text("No categories");

          return ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final category = Category.fromFirestore(docs[index]);
              return _buildCategoryItem(context, category);
            },
          );
        },
      ),
    );
  }

  Widget _buildCategoryItem(BuildContext context, Category category) {
    // Logika konversi SVG ke PNG agar konsisten dengan layar lain
    final String pngIconPath = category.iconPath.replaceAll('.svg', '.png');

    return Padding(
      padding: const EdgeInsets.only(right: 16.0),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CategoryDetailScreen(
                categoryName: category.name,
                iconPath: category.iconPath,
                itemCount: category.itemCount,
              ),
            ),
          );
        },
        child: Column(
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: kPrimaryColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Image.asset(
                  pngIconPath,
                  height: 35,
                  width: 35,
                  color: kPrimaryColor,
                  colorBlendMode: BlendMode.srcIn,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.image_not_supported, color: kPrimaryColor),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(category.name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendingList(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 240, 
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('products')
                .limit(5) 
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) return const Text("Error loading deals");
              if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
              
              final docs = snapshot.data!.docs;
              if (docs.isEmpty) return const Text("No trending deals");

              return ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  final product = Product.fromFirestore(docs[index]);
                  return Padding(
                    padding: const EdgeInsets.only(right: 16.0),
                    child: SizedBox(
                      width: 160,
                      child: ProductCard(product: product),
                    ),
                  );
                },
              );
            },
          ),
        ),

        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const CategoryListScreen(),
              ),
            );
          },
          child: const Text('LOAD MORE'),
        ),
      ],
    );
  }
}