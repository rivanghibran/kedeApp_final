// lib/screens/shopping_cart_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../main.dart'; 
import '../services/firestore_service.dart'; 
import 'checkout_screen.dart'; 

class ShoppingCartScreen extends StatefulWidget {
  const ShoppingCartScreen({super.key});

  @override
  State<ShoppingCartScreen> createState() => _ShoppingCartScreenState();
}

class _ShoppingCartScreenState extends State<ShoppingCartScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final String? uid = FirebaseAuth.instance.currentUser?.uid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: kTextColor),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        title: const Text(
          'Shopping Cart',
          style: TextStyle(color: kTextColor, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep, color: Colors.red),
            onPressed: () {
              // Opsional: Implementasi clear cart di service nanti
            },
          )
        ],
      ),
      
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('cart')
            .orderBy('addedAt', descending: true)
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
                  Icon(Icons.shopping_cart_outlined, size: 60, color: Colors.grey),
                  SizedBox(height: 16),
                  Text("Your cart is empty", style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          final cartDocs = snapshot.data!.docs;
          
          // 3. Hitung Total Harga (Hanya Item yang Dicentang)
          double totalPrice = 0;
          for (var doc in cartDocs) {
            final data = doc.data() as Map<String, dynamic>;
            if (data['isSelected'] == true) {
              totalPrice += (data['price'] * data['quantity']);
            }
          }

          return Column(
            children: [
              // LIST ITEM
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(20.0),
                  itemCount: cartDocs.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 24),
                  itemBuilder: (context, index) {
                    final doc = cartDocs[index];
                    final data = doc.data() as Map<String, dynamic>;
                    return _buildCartItem(doc.id, data);
                  },
                ),
              ),

              // BOTTOM CHECKOUT BAR
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05), 
                      blurRadius: 10, 
                      offset: const Offset(0, -5)
                    )
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Total:", style: TextStyle(color: kTextLightColor)),
                        Text(
                          "\$${totalPrice.toStringAsFixed(1)}", 
                          style: const TextStyle(
                            fontSize: 24, 
                            fontWeight: FontWeight.bold, 
                            color: kTextColor
                          ),
                        ),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: totalPrice > 0 ? () {
                         Navigator.push(
                           context, 
                           MaterialPageRoute(builder: (context) => const CheckoutScreen())
                         );
                      } : null, // Disable jika total 0
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text("Checkout", style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCartItem(String itemId, Map<String, dynamic> data) {
    // Helper untuk memastikan path gambar valid
    String imagePath = data['imagePath'] ?? '';
    if (imagePath.isEmpty) imagePath = 'assets/images/images.jpg';

    return SizedBox(
      height: 100,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center, // Ubah ke center agar checkbox rapi
        children: [
          // 1. CHECKBOX (PERBAIKAN: Hapus Center, ganti SizedBox/Padding)
          SizedBox(
            width: 30,
            child: Checkbox(
              value: data['isSelected'] ?? false,
              activeColor: kPrimaryColor,
              onChanged: (val) {
                _firestoreService.toggleCartSelection(itemId, val ?? false);
              },
            ),
          ),
          const SizedBox(width: 8),
          
          // 2. IMAGE (PERBAIKAN: Gunakan ClipRRect + ErrorBuilder)
          SizedBox(
            width: 80,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset(
                    imagePath,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    // Fallback jika gambar tidak ditemukan di assets
                    errorBuilder: (context, error, stackTrace) {
                      return Image.asset(
                        'assets/images/images.jpg', 
                        width: 80, height: 80, fit: BoxFit.cover
                      );
                    },
                  ),
                ),
                // Label Harga Kecil di Gambar
                Positioned(
                  bottom: -10, left: 0, right: 0,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: kPrimaryColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '\$${data['price']}',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),

          // 3. DETAILS
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Nama Produk & Tombol Hapus
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ITEM', 
                            style: const TextStyle(color: kTextLightColor, fontSize: 12),
                          ),
                          Text(
                            data['name'] ?? 'Unknown',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis, // Cegah teks panjang merusak layout
                            style: const TextStyle(
                              color: kTextColor,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Tombol Hapus Item
                    IconButton(
                      icon: const Icon(Icons.close, size: 20, color: Colors.grey),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () => _firestoreService.removeCartItem(itemId),
                    ),
                  ],
                ),
                
                // Harga Total Item & Stepper
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      '\$${((data['price'] ?? 0) * (data['quantity'] ?? 1)).toStringAsFixed(1)}',
                      style: const TextStyle(
                        color: kTextColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    
                    // Stepper Manual
                    Container(
                      height: 30,
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove, size: 14),
                            onPressed: () => _firestoreService.updateCartQuantity(itemId, (data['quantity'] ?? 1) - 1),
                          ),
                          Text(
                            "${data['quantity'] ?? 1}",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add, size: 14, color: kPrimaryColor),
                            onPressed: () => _firestoreService.updateCartQuantity(itemId, (data['quantity'] ?? 1) + 1),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}