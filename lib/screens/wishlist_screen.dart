// lib/screens/wishlist_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Ganti 'kede_app' dengan nama package project Anda jika perlu
import '../main.dart'; 
import '../models/product_model.dart'; // Pastikan import model Product yang baru
import '../widgets/product_card.dart'; // Import widget ProductCard

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  // Ambil UID user yang sedang login
  final String? uid = FirebaseAuth.instance.currentUser?.uid;

  @override
  Widget build(BuildContext context) {    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 1,
        title: const Text(
          'Wishlist',
          style: TextStyle(color: kTextColor, fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
      ),
      
      // MENGGUNAKAN STREAM UNTUK REALTIME DATA
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('wishlist')
            .orderBy('addedAt', descending: true) // Urutkan dari yang terbaru
            .snapshots(),
        builder: (context, snapshot) {
          // 1. Loading State
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // 2. Empty State
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border, size: 60, color: Colors.grey),
                  SizedBox(height: 16),
                  Text("Your wishlist is empty", style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          final docs = snapshot.data!.docs;

          return GridView.builder(
            padding: const EdgeInsets.all(20.0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.8,
            ),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              
              // Konversi data wishlist Firestore ke Model Product
              // Kita beri nilai default untuk field yang tidak disimpan di wishlist (seperti description/category)
              final product = Product(
                id: docs[index].id, // ID dokumen wishlist
                name: data['name'] ?? '',
                description: '', // Default kosong karena tidak disimpan di wishlist
                price: (data['price'] ?? 0).toDouble(),
                imagePath: data['imagePath'] ?? '',
                category: 'General', // Default
                isFavorite: true, // Pasti true karena ada di halaman wishlist
              );

              return ProductCard(product: product);
            },
          );
        },
      ),
    );
  }
}