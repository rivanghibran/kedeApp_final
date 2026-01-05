// lib/screens/product_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Tambahkan ini untuk QuerySnapshot

import '../main.dart'; 
// PERBAIKAN 1: Sesuaikan nama file import model
import '../models/product_model.dart'; 
import '../services/firestore_service.dart'; 
import 'write_review_screen.dart'; 
import 'shopping_cart_screen.dart'; 

class ProductDetailScreen extends StatefulWidget {
  final Product product;
  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen>
    with TickerProviderStateMixin {
      
  final PageController _imagePageController = PageController();
  late TabController _tabController;
  
  // State Logika Bisnis
  int _quantity = 1; 
  bool _isAdding = false; 
  final FirestoreService _firestoreService = FirestoreService();

  // List gambar dummy (untuk slider selain gambar utama)
  final List<String> _productImages = [
    'assets/images/tomatoes.jpg',
    'assets/images/avocado.jpg', 
    'assets/images/brocoli.jpg',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    // Tambahkan gambar utama produk ke posisi pertama slider
    // Cek dulu agar tidak duplikat jika di-hot reload
    if (!_productImages.contains(widget.product.imagePath)) {
       _productImages.insert(0, widget.product.imagePath);
    }
  }

  @override
  void dispose() {
    _imagePageController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  // --- LOGIKA STEPPER ---
  void _increment() => setState(() => _quantity++);
  void _decrement() {
    if (_quantity > 1) setState(() => _quantity--);
  }

  // --- LOGIKA ADD TO CART ---
  Future<void> _handleAddToCart() async {
    setState(() => _isAdding = true);
    try {
      await _firestoreService.addToCart(widget.product, _quantity);
      if (!mounted) return;
      
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ShoppingCartScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if (mounted) setState(() => _isAdding = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildImageSlider(context),
                _buildProductInfo(),
                const SizedBox(height: 24),
                _buildTabs(),
                const SizedBox(height: 120), // Spacer bottom
              ],
            ),
          ),
          
          _buildBottomActionButtons(),
        ],
      ),
    );
  }

  Widget _buildImageSlider(BuildContext context) {
    return SizedBox(
      height: 300,
      child: Stack(
        children: [
          PageView.builder(
            controller: _imagePageController,
            itemCount: _productImages.length,
            itemBuilder: (context, index) {
              return Image.asset(
                _productImages[index],
                fit: BoxFit.cover,
                width: double.infinity,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[200],
                    child: const Icon(Icons.broken_image, color: Colors.grey, size: 50),
                  );
                },
              );
            },
          ),
          
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildTransparentButton(Icons.arrow_back, () => Navigator.pop(context)),
                  _buildTransparentButton(Icons.share, () {}),
                ],
              ),
            ),
          ),
          
          Positioned(
            bottom: 20, left: 0, right: 0,
            child: Center(
              child: SmoothPageIndicator(
                controller: _imagePageController,
                count: _productImages.length,
                effect: const WormEffect(
                  dotColor: Colors.white54,
                  activeDotColor: Colors.white,
                  dotHeight: 8, dotWidth: 8,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransparentButton(IconData icon, VoidCallback onPressed) {
    return CircleAvatar(
      backgroundColor: Colors.black.withOpacity(0.3),
      child: IconButton(icon: Icon(icon, color: Colors.white), onPressed: onPressed),
    );
  }

  Widget _buildProductInfo() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('FRUITS', style: TextStyle(color: kTextLightColor, fontSize: 16)),
          const SizedBox(height: 8),
          Text(widget.product.name, style: const TextStyle(color: kTextColor, fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text('\$${widget.product.price}', style: const TextStyle(color: kPrimaryColor, fontSize: 24, fontWeight: FontWeight.bold)),
              
              // MANUAL STEPPER
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(20)
                ),
                child: Row(
                  children: [
                    IconButton(onPressed: _decrement, icon: const Icon(Icons.remove)),
                    Text("$_quantity", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    IconButton(onPressed: _increment, icon: const Icon(Icons.add)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          Row(
            children: [
              const Icon(Icons.star, color: Colors.amber, size: 24),
              const SizedBox(width: 8),
              const Text('4.5', style: TextStyle(color: kTextColor, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(width: 8),
              const Text('(128 reviews)', style: TextStyle(color: kTextLightColor, fontSize: 16)),
              const Spacer(),
              _buildReviewerAvatars(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReviewerAvatars() {
    return SizedBox(
      width: 100, height: 40,
      child: Stack(
        children: [
          _buildAvatar('assets/images/images.jpg', left: 0),
          _buildAvatar('assets/images/images.jpg', left: 25),
          _buildAvatar('assets/images/images.jpg', left: 50),
        ],
      ),
    );
  }
  
  Widget _buildAvatar(String imagePath, {double left = 0}) {
    return Positioned(
      left: left,
      child: Container(
        width: 40, height: 40,
        decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
        child: ClipOval(child: Image.asset(imagePath, fit: BoxFit.cover, errorBuilder: (c, e, s) => Container(color: Colors.grey))),
      ),
    );
  }

  Widget _buildTabs() {
    return Column(
      children: [
        TabBar(
          controller: _tabController,
          labelColor: kPrimaryColor, unselectedLabelColor: kTextLightColor,
          indicatorColor: kPrimaryColor, indicatorWeight: 3,
          labelStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          unselectedLabelStyle: const TextStyle(fontSize: 16),
          tabs: const [Tab(text: 'Description'), Tab(text: 'Review'), Tab(text: 'Discussion')],
        ),
        
        const Divider(height: 1, color: Colors.black12),
        
        SizedBox(
          height: 300, // Tinggi area tab
          child: TabBarView(
            controller: _tabController,
            children: [
              // 1. Description Tab
              const Padding(
                padding: EdgeInsets.all(20.0),
                child: Text(
                  'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.',
                  style: TextStyle(color: kTextLightColor, fontSize: 16, height: 1.5),
                ),
              ),
              
              // 2. Review Tab (DYNAMIC FROM FIRESTORE)
              // PERBAIKAN 2: Gunakan StreamBuilder untuk menampilkan review asli
              StreamBuilder<QuerySnapshot>(
                stream: _firestoreService.getReviewsStream(widget.product.id),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  // Jika kosong
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                     return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('No reviews yet. Be the first!'),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (c) => WriteReviewScreen(product: widget.product))),
                            icon: const Icon(Icons.edit, color: Colors.white), 
                            label: const Text('WRITE A REVIEW'),
                            style: ElevatedButton.styleFrom(backgroundColor: kPrimaryColor, foregroundColor: Colors.white),
                          ),
                        ],
                      ),
                    );
                  }

                  // Jika ada data
                  final reviews = snapshot.data!.docs;
                  return Column(
                    children: [
                      // Tombol Tulis Review kecil
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: TextButton.icon(
                            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (c) => WriteReviewScreen(product: widget.product))),
                            icon: const Icon(Icons.rate_review, size: 18),
                            label: const Text("Write Review"),
                          ),
                        ),
                      ),
                      
                      // List Review
                      Expanded(
                        child: ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: reviews.length,
                          separatorBuilder: (c, i) => const Divider(),
                          itemBuilder: (context, index) {
                            final data = reviews[index].data() as Map<String, dynamic>;
                            final double rating = (data['rating'] ?? 0).toDouble();
                            
                            return ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: CircleAvatar(
                                backgroundColor: Colors.grey[300],
                                child: Text((data['userName'] ?? 'U')[0].toUpperCase()),
                              ),
                              title: Row(
                                children: [
                                  Text(data['userName'] ?? 'Anonymous', style: const TextStyle(fontWeight: FontWeight.bold)),
                                  const Spacer(),
                                  const Icon(Icons.star, size: 16, color: Colors.amber),
                                  Text(" $rating", style: const TextStyle(fontWeight: FontWeight.bold)),
                                ],
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(data['comment'] ?? '', style: const TextStyle(color: Colors.black87)),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),

              // 3. Discussion Tab
              const Center(child: Text('Discussion will be shown here')),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomActionButtons() {
    double totalPrice = widget.product.price * _quantity;
    // ID unik untuk wishlist
    String docId = widget.product.id.isNotEmpty ? widget.product.id : widget.product.name.replaceAll(' ', '_');

    return Positioned(
      bottom: 0, left: 0, right: 0,
      child: Container(
        padding: const EdgeInsets.all(20.0).copyWith(bottom: 30.0),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Row(
          children: [
            // STREAM LOVE BUTTON (WISHLIST)
            StreamBuilder<bool>(
              stream: _firestoreService.isWishlistedStream(docId),
              builder: (context, snapshot) {
                bool isFav = snapshot.data ?? false;
                return GestureDetector(
                  onTap: () => _firestoreService.toggleWishlist(widget.product),
                  child: Container(
                    width: 56, height: 56,
                    decoration: BoxDecoration(
                      color: isFav ? Colors.pink.withOpacity(0.1) : Colors.grey[100],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      isFav ? Icons.favorite : Icons.favorite_border,
                      color: isFav ? Colors.pink : kTextColor,
                      size: 28,
                    ),
                  ),
                );
              }
            ),
            const SizedBox(width: 16),
            
            // TOMBOL ADD TO CART
            Expanded(
              child: ElevatedButton(
                onPressed: _isAdding ? null : _handleAddToCart,
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isAdding 
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : Text(
                      'ADD TO CART \$${totalPrice.toStringAsFixed(1)}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}