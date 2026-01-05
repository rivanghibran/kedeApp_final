import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/product_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get userId => _auth.currentUser?.uid;

  // --- CART FEATURES ---

  // 1. Tambah ke Cart (Cek duplicate, update qty jika ada, buat baru jika belum)
  Future<void> addToCart(Product product, int quantity) async {
    if (userId == null) return;
    
    // Gunakan ID produk jika ada. Jika data dummy (kosong), gunakan nama sebagai ID sementara
    String docId = product.id.isNotEmpty ? product.id : product.name.replaceAll(' ', '_');

    final cartRef = _db.collection('users').doc(userId).collection('cart').doc(docId);

    final doc = await cartRef.get();
    if (doc.exists) {
      // Jika barang sudah ada, update jumlahnya
      int currentQty = doc.data()?['quantity'] ?? 0;
      await cartRef.update({'quantity': currentQty + quantity});
    } else {
      // Jika belum ada, buat baru
      await cartRef.set({
        'productId': docId,
        'name': product.name,
        'price': product.price,
        'imagePath': product.imagePath,
        'quantity': quantity,
        'isSelected': true, // Default tercentang saat masuk cart
        'addedAt': FieldValue.serverTimestamp(),
      });
    }
  }

  // 2. Update Jumlah Item di Cart (+/-)
  Future<void> updateCartQuantity(String itemId, int newQty) async {
    if (userId == null || newQty < 1) return;
    await _db.collection('users').doc(userId).collection('cart').doc(itemId).update({
      'quantity': newQty
    });
  }

  // 3. Toggle Checkbox (Simpan status centang)
  Future<void> toggleCartSelection(String itemId, bool isSelected) async {
    if (userId == null) return;
    await _db.collection('users').doc(userId).collection('cart').doc(itemId).update({
      'isSelected': isSelected
    });
  }

  // 4. Hapus Item dari Cart
  Future<void> removeCartItem(String itemId) async {
    if (userId == null) return;
    await _db.collection('users').doc(userId).collection('cart').doc(itemId).delete();
  }

  // --- WISHLIST FEATURES ---

  // 5. Toggle Wishlist (Like/Unlike)
  Future<void> toggleWishlist(Product product) async {
    if (userId == null) return;
    String docId = product.id.isNotEmpty ? product.id : product.name.replaceAll(' ', '_');
    
    final wishlistRef = _db.collection('users').doc(userId).collection('wishlist').doc(docId);

    final doc = await wishlistRef.get();
    if (doc.exists) {
      await wishlistRef.delete(); // Hapus jika sudah ada (Unlike)
    } else {
      await wishlistRef.set({ // Tambah jika belum ada (Like)
        'productId': docId,
        'name': product.name,
        'price': product.price,
        'imagePath': product.imagePath,
        'addedAt': FieldValue.serverTimestamp(),
      });
    }
  }

  // 6. Cek Realtime apakah produk ada di wishlist (untuk warna icon hati merah/putih)
  Stream<bool> isWishlistedStream(String productId) {
    if (userId == null || productId.isEmpty) return Stream.value(false);
    return _db
        .collection('users')
        .doc(userId)
        .collection('wishlist')
        .doc(productId)
        .snapshots()
        .map((snapshot) => snapshot.exists);
  }
  // --- REVIEW FEATURES ---
  // 7. Tambah Review Baru
  Future<void> addReview(String productId, double rating, String comment, String userName) async {
    if (userId == null) return;
    
    // Simpan di sub-collection: products/{productId}/reviews
    await _db.collection('products').doc(productId).collection('reviews').add({
      'userId': userId,
      'userName': userName, // Simpan nama user agar mudah ditampilkan
      'rating': rating,
      'comment': comment,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // 8. Ambil Data Review (Realtime)
  Stream<QuerySnapshot> getReviewsStream(String productId) {
    return _db.collection('products')
        .doc(productId)
        .collection('reviews')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }
}