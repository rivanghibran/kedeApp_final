import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MyProfileScreen extends StatefulWidget {
  const MyProfileScreen({super.key});

  @override
  State<MyProfileScreen> createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen> {
  final _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    final currentUser = _auth.currentUser;

    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: const Text("My Profile"),
        centerTitle: true,
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser!.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          var data = snapshot.data!;
          final userData = data.data() as Map<String, dynamic>? ?? {};

          String firstName = userData['firstName']?.toString() ?? '-';
          String lastName = userData['lastName']?.toString() ?? '-';
          String fullName = "$firstName $lastName";
          String username = userData['username']?.toString().isNotEmpty == true
              ? userData['username']
              : '-';
          String phone = userData['phone']?.toString().isNotEmpty == true
              ? userData['phone']
              : '-';
          String address = userData['address']?.toString().isNotEmpty == true
              ? userData['address']
              : '-';


          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // ---------------- PROFILE HEADER ----------------
                Column(
                  children: [
                    CircleAvatar(
                      radius: 45,
                      backgroundImage:
                          NetworkImage("https://i.pravatar.cc/300"),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      fullName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "@$username",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // -------------------------------------------------
                // PROFILE CARD LIST
                // -------------------------------------------------

                _buildProfileCard("First Name", firstName),
                _buildProfileCard("Last Name", lastName),
                _buildProfileCard("Phone", phone),
                _buildProfileCard("Address", address),

                const SizedBox(height: 25),

                // ------------------ EDIT BUTTON ------------------
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, "/edit-profile");
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    "Edit Profile",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),

                const SizedBox(height: 15),

                // ---------------- DELETE ACCOUNT -----------------
                TextButton(
                  onPressed: () => _confirmDelete(context),
                  child: const Text(
                    "Delete Account",
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }

  // ---------- WIDGET CARD ----------
  Widget _buildProfileCard(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 6,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          Text(value,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
              )),
        ],
      ),
    );
  }

  // ---------- DELETE ACCOUNT FUNCTION ----------
  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text("Delete Account"),
          content: const Text(
              "Are you sure you want to delete your account? This action cannot be undone."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                final uid = _auth.currentUser!.uid;

                // Hapus dokumen user
                await FirebaseFirestore.instance
                    .collection("users")
                    .doc(uid)
                    .delete();

                // Hapus akun auth
                await _auth.currentUser!.delete();

                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Account deleted successfully."),
                  ),
                );

                Navigator.pushReplacementNamed(context, "/login");
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text(
                "Delete",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }
}
