import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../main.dart';
import 'package:flutter/services.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final firstC = TextEditingController();
  final lastC = TextEditingController();
  final usernameC = TextEditingController();
  final phoneC = TextEditingController();
  final addressC = TextEditingController();

  String? firstError;
  String? lastError;
  String? usernameError;
  String? phoneError;

  bool isLoading = false;

  final _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final uid = _auth.currentUser!.uid;
    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    final data = doc.data() ?? {};

    firstC.text = data['firstName'] ?? "";
    lastC.text = data['lastName'] ?? "";
    usernameC.text = data['username'] ?? "";
    phoneC.text = data['phone'] ?? "";
    addressC.text = data['address'] ?? "";
  }

  Future<void> _saveProfile() async {
    setState(() {
      firstError = null;
      lastError = null;
      usernameError = null;
      phoneError = null;
    });

    final first = firstC.text.trim();
    final last = lastC.text.trim();
    final username = usernameC.text.trim();
    final phone = phoneC.text.trim();
    final fullName = "$first $last";

    bool hasError = false;

    // VALIDASI FIRST NAME
    if (first.isEmpty) {
      firstError = "First name cannot be empty.";
      hasError = true;
    } else if (first.length < 2) {
      firstError = "First name must be at least 2 characters.";
      hasError = true;
    } else if (!RegExp(r"^[a-zA-Z]+$").hasMatch(first)) {
      firstError = "First name can only contain letters.";
      hasError = true;
    }

    // VALIDASI LAST NAME
    if (last.isEmpty) {
      lastError = "Last name cannot be empty.";
      hasError = true;
    } else if (last.length < 2) {
      lastError = "Last name must be at least 2 characters.";
      hasError = true;
    } else if (!RegExp(r"^[a-zA-Z]+$").hasMatch(last)) {
      lastError = "Last name can only contain letters.";
      hasError = true;
    }

    // VALIDASI USERNAME
    if (username.isEmpty) {
      usernameError = "Username cannot be empty.";
      hasError = true;
    } else if (username.length < 3) {
      usernameError = "Username must be at least 3 characters.";
      hasError = true;
    }

    // VALIDASI PHONE
    if (phone.isEmpty) {
      phoneError = "Phone number cannot be empty.";
      hasError = true;
    } else if (!RegExp(r"^[0-9]+$").hasMatch(phone)) {
      phoneError = "Phone number must contain only digits.";
      hasError = true;
    } else if (phone.length < 8) {
      phoneError = "Phone number must be at least 8 digits.";
      hasError = true;
    }

    setState(() {}); // update UI error messages

    if (hasError) return;

    setState(() => isLoading = true);
    final uid = _auth.currentUser!.uid;

    try {
      await FirebaseFirestore.instance.collection("users").doc(uid).update({
        "firstName": first,
        "lastName": last,
        "fullName": fullName,
        "username": username,
        "phone": phone,
        "address": addressC.text.trim(),
      });

      await _auth.currentUser!.updateDisplayName(fullName);

      if (!mounted) return;

      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text("Profile Updated"),
          content: const Text("Your profile has been successfully updated."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pop(context); // Back to My Profile page
              },
              child: const Text("OK"),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to update profile: $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _deleteAccount() async {
    final uid = _auth.currentUser!.uid;

    try {
      // Hapus dokumen user
      await FirebaseFirestore.instance.collection("users").doc(uid).delete();

      // Hapus akun auth
      await _auth.currentUser!.delete();

      // Navigasi ke Onboarding page
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Account deleted successfully."),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pushNamedAndRemoveUntil(context, "/onboarding", (route) => false);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to delete account: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Edit Profile",
          style: TextStyle(color: kTextColor, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        automaticallyImplyLeading: true,
      ),
      backgroundColor: Colors.grey[100],
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _inputCard(
              title: "First Name", controller: firstC, errorText: firstError),
          _inputCard(
              title: "Last Name", controller: lastC, errorText: lastError),
          _inputCard(
              title: "Username", controller: usernameC, errorText: usernameError),
          _inputCard(
              title: "Phone Number",
              controller: phoneC,
              keyboard: TextInputType.phone,
              errorText: phoneError),
          _inputCard(title: "Address", controller: addressC, maxLines: 3),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: isLoading ? null : _saveProfile,
            child: isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text("SAVE CHANGES"),
          ),
          const SizedBox(height: 15),
          TextButton(
            onPressed: _deleteAccount,
            child: const Text(
              "Delete Account",
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  // CARD INPUT
  Widget _inputCard({
    required String title,
    required TextEditingController controller,
    String? errorText,
    TextInputType keyboard = TextInputType.text,
    int maxLines = 1,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
              color: Colors.black12, blurRadius: 3, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
                fontWeight: FontWeight.bold, color: kTextColor, fontSize: 16),
          ),
          TextField(
            controller: controller,
            maxLines: maxLines,
            keyboardType: keyboard,
            inputFormatters: keyboard == TextInputType.phone
                ? [FilteringTextInputFormatter.digitsOnly]
                : null,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: "Enter here...",
              errorText: errorText,
            ),
          ),
        ],
      ),
    );
  }
}
