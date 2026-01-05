// lib/screens/product_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; 

import '../main.dart'; 
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

  // List gambar untuk slider
  final List<String> _productImages = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    // Inisialisasi gambar
    // 1. Masukkan gambar utama produk
    _productImages.add(widget.product.imagePath);
    
    // 2. Tambahkan dummy images hanya untuk efek slider (opsional)
    // Cek agar tidak duplikat
    if (!_productImages.contains('assets/images/tomatoes.jpg')) _productImages.add('assets/images/tomatoes.jpg');
    if (!_productImages.contains('assets/images/avocado.jpg')) _productImages.add('assets/images/avocado.jpg');
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
      
      // Navigasi ke Halaman Cart setelah berhasil
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
          // Konten Utama (Scrollable)
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildImageSlider(context),
                _buildProductInfo(),
                const SizedBox(height: 24),
                _buildTabs(),
                const SizedBox(height: 120), // Spacer agar konten tidak tertutup tombol bawah
              ],
            ),
          ),
          
          // Tombol Bawah (Fixed)
          _buildBottomActionButtons(),
        ],
      ),
    );
  }

  // Helper untuk menampilkan gambar (Network vs Asset)
  Widget _buildImage(String path, {BoxFit fit = BoxFit.cover}) {
    if (path.startsWith('http')) {
      return Image.network(
        path,
        fit: fit,
        width: double.infinity,
        errorBuilder: (context, error, stackTrace) => Container(
          color: Colors.grey[200],
          child: const Center(child: Icon(Icons.broken_image, color: Colors.grey)),
        ),
      );
    } else {
      return Image.asset(
        path,
        fit: fit,
        width: double.infinity,
        errorBuilder: (context, error, stackTrace) => Container(
          color: Colors.grey[200],
          child: const Center(child: Icon(Icons.image_not_supported, color: Colors.grey)),
        ),
      );
    }
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
              return _buildImage(_productImages[index]);
            },
          ),
          
          // Tombol Back & Share
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
          
          // Indikator Halaman
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
          Text(widget.product.category.toUpperCase(), style: const TextStyle(color: kTextLightColor, fontSize: 14)),
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
                height: 40,
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
        child: ClipOval(
          child: Image.asset(
            imagePath, 
            fit: BoxFit.cover, 
            errorBuilder: (c, e, s) => Container(color: Colors.grey[300]),
          ),
        ),
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
        
        // GUNAKAN SIZEDBOX AGAR TAB BAR VIEW MEMILIKI TINGGI TETAP
        SizedBox(
          height: 400, // Tinggikan sedikit agar review muat banyak
          child: TabBarView(
            controller: _tabController,
            children: [
              // 1. Description Tab
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: SingleChildScrollView(
                  child: Text(
                    widget.product.description.isNotEmpty 
                        ? widget.product.description 
                        : 'No description available for this product. Fresh from local farmers in Jateng & DIY.',
                    style: const TextStyle(color: kTextLightColor, fontSize: 16, height: 1.5),
                  ),
                ),
              ),
              
              // 2. Review Tab (Realtime Firestore)
              StreamBuilder<QuerySnapshot>(
                stream: _firestoreService.getReviewsStream(widget.product.id),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  // Empty State
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                     return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.rate_review_outlined, size: 50, color: Colors.grey),
                          const SizedBox(height: 10),
                          const Text('No reviews yet. Be the first!', style: TextStyle(color: Colors.grey)),
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

                  // List Reviews
                  final reviews = snapshot.data!.docs;
                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: TextButton.icon(
                            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (c) => WriteReviewScreen(product: widget.product))),
                            icon: const Icon(Icons.rate_review, size: 18),
                            label: const Text("Write Review"),
                          ),
                        ),
                      ),
                      
                      Expanded(
                        child: ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          itemCount: reviews.length,
                          separatorBuilder: (c, i) => const Divider(),
                          itemBuilder: (context, index) {
                            final data = reviews[index].data() as Map<String, dynamic>;
                            final double rating = (data['rating'] ?? 0).toDouble();
                            
                            return ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: CircleAvatar(
                                backgroundColor: kPrimaryColor.withOpacity(0.2),
                                child: Text((data['userName'] ?? 'U')[0].toUpperCase(), style: const TextStyle(color: kPrimaryColor, fontWeight: FontWeight.bold)),
                              ),
                              title: Row(
                                children: [
                                  Text(data['userName'] ?? 'Anonymous', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                  const Spacer(),
                                  const Icon(Icons.star, size: 14, color: Colors.amber),
                                  Text(" $rating", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
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
              const Center(child: Text('Discussion feature coming soon!')),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomActionButtons() {
    double totalPrice = widget.product.price * _quantity;
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
            // STREAM WISHLIST BUTTON
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