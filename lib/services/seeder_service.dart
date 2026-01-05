// lib/services/seeder_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class SeederService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> seedDatabase() async {
    try {
      // 1. CEK APAKAH DATABASE SUDAH TERISI
      // Kita cek collection 'categories'. Jika ada minimal 1 dokumen, kita anggap sudah di-seed.
      final QuerySnapshot check = await _db.collection('categories').limit(1).get();
      
      if (check.docs.isNotEmpty) {
        print("⚠️ Database sudah terisi. Auto-seeder dilewati.");
        return; // HENTIKAN PROSES JIKA SUDAH ADA DATA
      }

      print("🚀 Database kosong. Memulai pengisian data otomatis...");

      // 2. DATA KATEGORI
      final List<Map<String, dynamic>> categories = [
        {
          'name': 'Fruits',
          'itemCount': 15,
          'iconPath': 'assets/icons/grapes.svg',
        },
        {
          'name': 'Vegetables',
          'itemCount': 30,
          'iconPath': 'assets/icons/leaf.svg',
        },
        {
          'name': 'Mushrooms',
          'itemCount': 8,
          'iconPath': 'assets/icons/mushroom.svg',
        },
        {
          'name': 'Breads',
          'itemCount': 5,
          'iconPath': 'assets/icons/bread.svg',
        },
      ];

      // 3. DATA PRODUK
      final List<Map<String, dynamic>> products = [
        
        // --- KATEGORI BREADS ---
        {
          'name': 'Roti Tawar Kupas (Jumbo)',
          'description': 'Roti tawar tebal tanpa kulit, tekstur lembut, cocok untuk roti bakar atau sandwich.',
          'price': 16000.0,
          'imagePath': 'assets/images/images.jpg', 
          'category': 'Breads',
          'rating': 4.8,
          'stock': 25,
        },
        {
          'name': 'Roti Tawar Gandum',
          'description': 'Roti tawar dari gandum utuh, tinggi serat, cocok untuk diet.',
          'price': 22000.0,
          'imagePath': 'assets/images/images.jpg',
          'category': 'Breads',
          'rating': 4.7,
          'stock': 15,
        },
        {
          'name': 'Roti Burger Wijen (Isi 6)',
          'description': 'Bun roti burger polos tabur wijen, empuk, siap diolah.',
          'price': 18000.0,
          'imagePath': 'assets/images/images.jpg',
          'category': 'Breads',
          'rating': 4.6,
          'stock': 20,
        },
        {
          'name': 'Roti Hotdog Polos (Isi 6)',
          'description': 'Roti bentuk memanjang untuk hotdog, tekstur halus.',
          'price': 17000.0,
          'imagePath': 'assets/images/images.jpg',
          'category': 'Breads',
          'rating': 4.5,
          'stock': 20,
        },
        {
          'name': 'Baguette / Roti Perancis',
          'description': 'Roti tongkat panjang, kulit renyah, dalam lembut. Cocok untuk garlic bread.',
          'price': 15000.0,
          'imagePath': 'assets/images/images.jpg',
          'category': 'Breads',
          'rating': 4.7,
          'stock': 10,
        },

        // --- KATEGORI FRUITS ---
        {
          'name': 'Pisang Raja (1 Sisir)',
          'description': 'Pisang raja matang pohon, manis legit, kulit kuning bersih.',
          'price': 35000.0, 
          'imagePath': 'assets/images/avocado.jpg', 
          'category': 'Fruits',
          'rating': 4.9,
          'stock': 20,
        },
        {
          'name': 'Pisang Cavendish (1kg)',
          'description': 'Pisang meja kulit mulus, daging pulen manis.',
          'price': 22000.0,
          'imagePath': 'assets/images/avocado.jpg',
          'category': 'Fruits',
          'rating': 4.8,
          'stock': 30,
        },
        {
          'name': 'Alpukat Mentega (1kg)',
          'description': 'Alpukat daging tebal, kuning mentega, tidak berserat.',
          'price': 35000.0,
          'imagePath': 'assets/images/avocado.jpg',
          'category': 'Fruits',
          'rating': 4.9,
          'stock': 25,
        },
        {
          'name': 'Mangga Arumanis (1kg)',
          'description': 'Mangga lokal matang pohon, harum dan manis.',
          'price': 25000.0,
          'imagePath': 'assets/images/grapes.jpg',
          'category': 'Fruits',
          'rating': 4.7,
          'stock': 40,
        },
        {
          'name': 'Salak Pondoh (1kg)',
          'description': 'Salak asli Sleman, daging renyah manis, biji kecil.',
          'price': 10000.0,
          'imagePath': 'assets/images/grapes.jpg',
          'category': 'Fruits',
          'rating': 4.6,
          'stock': 50,
        },
        {
          'name': 'Jeruk Keprok (1kg)',
          'description': 'Jeruk lokal kulit tipis, rasa manis segar, air banyak.',
          'price': 18000.0,
          'imagePath': 'assets/images/grapes.jpg',
          'category': 'Fruits',
          'rating': 4.5,
          'stock': 35,
        },
        {
          'name': 'Nanas Madu Pemalang (1pcs)',
          'description': 'Nanas kecil rasa sangat manis, tidak gatal di lidah.',
          'price': 8000.0,
          'imagePath': 'assets/images/avocado.jpg',
          'category': 'Fruits',
          'rating': 4.8,
          'stock': 30,
        },
        {
          'name': 'Pepaya California (1pcs)',
          'description': 'Pepaya merah jingga, manis, ukuran sedang (1-1.5kg).',
          'price': 12000.0,
          'imagePath': 'assets/images/avocado.jpg',
          'category': 'Fruits',
          'rating': 4.7,
          'stock': 15,
        },
        {
          'name': 'Semangka Merah Non Biji (1kg)',
          'description': 'Semangka potong/utuh, merah merona, manis dan segar.',
          'price': 9000.0,
          'imagePath': 'assets/images/tomatoes.jpg',
          'category': 'Fruits',
          'rating': 4.6,
          'stock': 40,
        },
        {
          'name': 'Jambu Kristal (1kg)',
          'description': 'Jambu biji renyah, daging tebal hampir tanpa biji.',
          'price': 15000.0,
          'imagePath': 'assets/images/avocado.jpg',
          'category': 'Fruits',
          'rating': 4.7,
          'stock': 20,
        },

        // --- KATEGORI VEGETABLES ---
        {
          'name': 'Bayam Hijau (Ikat)',
          'description': 'Bayam segar petik pagi, daun lebar, batang muda.',
          'price': 4000.0,
          'imagePath': 'assets/images/brocoli.jpg',
          'category': 'Vegetables',
          'rating': 4.9,
          'stock': 50,
        },
        {
          'name': 'Kangkung Akar (Ikat)',
          'description': 'Kangkung segar, cocok untuk tumis terasi.',
          'price': 3500.0,
          'imagePath': 'assets/images/brocoli.jpg',
          'category': 'Vegetables',
          'rating': 4.8,
          'stock': 50,
        },
        {
          'name': 'Sawi Hijau / Caisim (Ikat)',
          'description': 'Sawi hijau segar untuk mie ayam atau tumisan.',
          'price': 5000.0,
          'imagePath': 'assets/images/brocoli.jpg',
          'category': 'Vegetables',
          'rating': 4.7,
          'stock': 30,
        },
        {
          'name': 'Pakcoy (500g)',
          'description': 'Sawi sendok, batang tebal renyah, daun hijau pekat.',
          'price': 8000.0,
          'imagePath': 'assets/images/brocoli.jpg',
          'category': 'Vegetables',
          'rating': 4.8,
          'stock': 25,
        },
        {
          'name': 'Brokoli (Per Bonggol)',
          'description': 'Brokoli hijau segar, kuntum rapat, bebas ulat.',
          'price': 12000.0,
          'imagePath': 'assets/images/brocoli.jpg',
          'category': 'Vegetables',
          'rating': 4.9,
          'stock': 20,
        },
        {
          'name': 'Kembang Kol (Per Bonggol)',
          'description': 'Kembang kol putih bersih, segar dan padat.',
          'price': 14000.0,
          'imagePath': 'assets/images/brocoli.jpg',
          'category': 'Vegetables',
          'rating': 4.7,
          'stock': 15,
        },
        {
          'name': 'Wortel Lokal (1kg)',
          'description': 'Wortel segar, manis, cocok untuk sop atau jus.',
          'price': 13000.0,
          'imagePath': 'assets/images/tomatoes.jpg',
          'category': 'Vegetables',
          'rating': 4.6,
          'stock': 40,
        },
        {
          'name': 'Kentang Dieng (1kg)',
          'description': 'Kentang kuning kualitas super (PL), tidak mudah hancur.',
          'price': 18000.0,
          'imagePath': 'assets/images/images.jpg',
          'category': 'Vegetables',
          'rating': 4.8,
          'stock': 50,
        },
        {
          'name': 'Tomat Buah (1kg)',
          'description': 'Tomat merah besar, daging tebal, air sedikit.',
          'price': 12000.0,
          'imagePath': 'assets/images/tomatoes.jpg',
          'category': 'Vegetables',
          'rating': 4.7,
          'stock': 35,
        },
        {
          'name': 'Cabai Merah Keriting (250g)',
          'description': 'Cabai merah pedas sedang, segar baru petik.',
          'price': 15000.0,
          'imagePath': 'assets/images/images.jpg',
          'category': 'Vegetables',
          'rating': 4.5,
          'stock': 30,
        },
        {
          'name': 'Cabai Rawit Merah (1 Ons)',
          'description': 'Cabai rawit setan super pedas.',
          'price': 8000.0,
          'imagePath': 'assets/images/images.jpg',
          'category': 'Vegetables',
          'rating': 4.9,
          'stock': 40,
        },
        {
          'name': 'Bawang Merah (500g)',
          'description': 'Bawang merah Brebes ukuran sedang.',
          'price': 20000.0,
          'imagePath': 'assets/images/images.jpg',
          'category': 'Vegetables',
          'rating': 4.8,
          'stock': 30,
        },
        {
          'name': 'Bawang Putih Kating (500g)',
          'description': 'Bawang putih siung besar, wangi kuat.',
          'price': 24000.0,
          'imagePath': 'assets/images/images.jpg',
          'category': 'Vegetables',
          'rating': 4.7,
          'stock': 30,
        },
        {
          'name': 'Labu Siam (1pcs)',
          'description': 'Labu siam hijau muda, ukuran sedang.',
          'price': 3000.0,
          'imagePath': 'assets/images/avocado.jpg', 
          'category': 'Vegetables',
          'rating': 4.5,
          'stock': 20,
        },
        {
          'name': 'Terong Ungu (1kg)',
          'description': 'Terong ungu panjang, kulit mulus mengkilap.',
          'price': 10000.0,
          'imagePath': 'assets/images/grapes.jpg',
          'category': 'Vegetables',
          'rating': 4.6,
          'stock': 25,
        },

        // --- KATEGORI MUSHROOMS ---
        {
          'name': 'Jamur Tiram (250g)',
          'description': 'Jamur tiram putih bersih, tekstur kenyal.',
          'price': 7000.0,
          'imagePath': 'assets/images/mushroom_placeholder.jpg',
          'category': 'Mushrooms',
          'rating': 4.7,
          'stock': 20,
        },
        {
          'name': 'Jamur Kancing (250g)',
          'description': 'Jamur champignon segar, cocok untuk tumis atau sop.',
          'price': 15000.0,
          'imagePath': 'assets/images/mushroom_placeholder.jpg',
          'category': 'Mushrooms',
          'rating': 4.8,
          'stock': 15,
        },
        {
          'name': 'Jamur Enoki (1 Pack)',
          'description': 'Jamur enoki impor, renyah untuk suki.',
          'price': 6000.0,
          'imagePath': 'assets/images/mushroom_placeholder.jpg',
          'category': 'Mushrooms',
          'rating': 4.9,
          'stock': 30,
        },
        {
          'name': 'Jamur Kuping Basah (250g)',
          'description': 'Jamur kuping hitam segar, tekstur garing.',
          'price': 8000.0,
          'imagePath': 'assets/images/mushroom_placeholder.jpg',
          'category': 'Mushrooms',
          'rating': 4.6,
          'stock': 15,
        },
      ];

      // EKSEKUSI UPLOAD (BATCH)
      final WriteBatch batch = _db.batch();

      // Upload Kategori
      for (var cat in categories) {
        DocumentReference ref = _db.collection('categories').doc(cat['name']);
        batch.set(ref, cat);
      }

      // Upload Produk
      for (var prod in products) {
        DocumentReference ref = _db.collection('products').doc(); 
        prod['searchKeywords'] = _generateKeywords(prod['name']);
        
        // --- LOGIKA FALLBACK GAMBAR ---
        // Kita cek apakah path gambar ada di daftar aset yang VALID.
        // Jika tidak, ganti dengan salah satu aset yang PASTI ada agar tidak crash.
        // Daftar ini berdasarkan aset yang Anda miliki:
        const validAssets = [
          'assets/images/avocado.jpg', 
          'assets/images/brocoli.jpg', 
          'assets/images/grapes.jpg', 
          'assets/images/tomatoes.jpg', 
          'assets/images/images.jpg'
        ];

        if (!validAssets.contains(prod['imagePath'])) {
           // Jika gambar placeholder tidak ada fisiknya, ganti ke default
           prod['imagePath'] = 'assets/images/images.jpg';
        }

        batch.set(ref, prod);
      }

      await batch.commit();
      print("✅ DATA AWAL BERHASIL DI-SEEDING!");
    
    } catch (e) {
      print("❌ Error seeding database: $e");
    }
  }

  // Helper Search Keywords
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