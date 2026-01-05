import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; 
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../screens/main_app_screen.dart'; 

// --- Placeholder for Constants ---
const kTextColor = Colors.black; 
const kTextLightColor = Colors.grey; 
const kPrimaryColor = Colors.blue; 

// ====================================================================
// 1. MAIN SHOW BOTTOM SHEET FUNCTION
// ====================================================================

void showAuthSheet(BuildContext context, Widget child) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return DraggableScrollableSheet(
        initialChildSize: 0.8,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.all(24),
              child: child,
            ),
          );
        },
      );
    },
  );
}

// ====================================================================
// 2. REUSABLE WIDGETS: HEADER AND FIELD
// ====================================================================

class AuthSheetHeader extends StatelessWidget {
  final String title;
  const AuthSheetHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: Theme.of(context).textTheme.headlineSmall),
        IconButton(
          // Request: Close button uses popUntil to return to the first route
          onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
          icon: const Icon(Icons.close, color: kTextColor, size: 28),
        ),
      ],
    );
  }
}

class CustomAuthField extends StatelessWidget {
  final String hintText;
  final bool isPassword;
  final TextEditingController controller;
  final String? error;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;

  const CustomAuthField({
    super.key,
    required this.hintText,
    required this.controller,
    this.isPassword = false,
    this.error,
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    );
    final errorBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Colors.red, width: 1.5),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          obscureText: isPassword,
          keyboardType: keyboardType, 
          inputFormatters: inputFormatters, 
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(color: kTextLightColor),
            filled: true,
            fillColor: error != null ? Colors.red.withOpacity(0.05) : Colors.grey[100], 
            border: border,
            enabledBorder: border,
            focusedBorder: error != null ? errorBorder : border,
            errorBorder: errorBorder,
            focusedErrorBorder: errorBorder,
            contentPadding: const EdgeInsets.symmetric(
              vertical: 16,
              horizontal: 20,
            ),
          ),
        ),
        if (error != null) ...[
          const SizedBox(height: 4),
          Text(
            error!, 
            style: const TextStyle(color: Colors.red, fontSize: 12.0),
          ),
        ]
      ],
    );
  }
}

// ====================================================================
// 3. SIGN IN SHEET
// ====================================================================

class SignInSheetContent extends StatefulWidget {
  const SignInSheetContent({super.key});

  @override
  State<SignInSheetContent> createState() => _SignInSheetContentState();
}

class _SignInSheetContentState extends State<SignInSheetContent> {
  final emailC = TextEditingController();
  final passC = TextEditingController();

  String? emailError;
  String? passError;
  bool isLoading = false;
  String? generalError; 

  final auth = FirebaseAuth.instance;

  // --- PERBAIKAN LOGIKA ERROR DISINI ---
  void _setFirebaseError(FirebaseAuthException e) {
    setState(() {
      generalError = null; 
      switch (e.code) {
        // KASUS 1: Email belum terdaftar
        case "user-not-found":
          emailError = "This email is not registered.";
          passError = null;
          break;
        // KASUS 2: Format email salah
        case "invalid-email":
          emailError = "Invalid email format.";
          passError = null;
          break;
        // KASUS 3: Password Salah
        case "wrong-password":
          passError = "The password you entered is incorrect.";
          emailError = null;
          break;
        // Tambahan: Terkadang Firebase mengembalikan 'invalid-credential'
        case "invalid-credential":
           generalError = "Invalid email or password.";
           break;
        case "network-request-failed":
          generalError = "Network error. Please check your internet connection.";
          emailError = null;
          passError = null;
          break;
        default:
          generalError = "An unexpected error occurred (${e.code}).";
          emailError = null;
          passError = null;
          break;
      }
    });
  }

  Future<void> handleSignIn() async {
    setState(() {
      emailError = null;
      passError = null;
      generalError = null;
    });

    final email = emailC.text.trim();
    final pass = passC.text.trim();
    bool hasValidationError = false;

    // Client-Side Validation
    if (email.isEmpty || !RegExp(r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(email)) {
      setState(() => emailError = "Invalid email format (e.g., info@email.com).");
      hasValidationError = true;
    }
    if (pass.isEmpty) {
      setState(() => passError = "Password cannot be empty.");
      hasValidationError = true;
    }

    if (hasValidationError) return;

    try {
      setState(() => isLoading = true);

      await auth.signInWithEmailAndPassword(email: email, password: pass);

      if (mounted) {
        // Navigate to main app screen and remove all previous routes
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (c) => const MainAppScreen()),
          (_) => false,
        );
      }
    } on FirebaseAuthException catch (e) {
      _setFirebaseError(e); 
    } catch (e) {
      setState(() => generalError = "An unexpected error occurred: ${e.toString()}");
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const AuthSheetHeader(title: 'Sign In'),
        const SizedBox(height: 24),
        
        if (generalError != null) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Text(
              'Error: $generalError',
              style: const TextStyle(color: Colors.red, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ),
        ],

        CustomAuthField(
          hintText: "email",
          controller: emailC,
          keyboardType: TextInputType.emailAddress,
          error: emailError,
        ),
        const SizedBox(height: 16),

        CustomAuthField(
          hintText: "passwrord",
          controller: passC,
          isPassword: true,
          error: passError,
        ),
        const SizedBox(height: 12),

        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () {
              Navigator.pop(context);
              showAuthSheet(context, const ForgotPassSheetContent());
            },
            child: const Text("Forgot Password?",
                style: TextStyle(color: kPrimaryColor)),
          ),
        ),
        const SizedBox(height: 24),

        ElevatedButton(
          onPressed: isLoading ? null : handleSignIn,
          child: isLoading
              ? const CircularProgressIndicator(color: Colors.white)
              : const Text("SIGN IN"),
        ),
        const SizedBox(height: 16),

        OutlinedButton(
          onPressed: () {
            Navigator.pop(context);
            showAuthSheet(context, const SignUpSheetContent());
          },
          child: const Text("CREATE AN ACCOUNT"),
        ),
      ],
    );
  }
}

// ====================================================================
// 4. SIGN UP SHEET
// ====================================================================

class SignUpSheetContent extends StatefulWidget {
  const SignUpSheetContent({super.key});

  @override
  State<SignUpSheetContent> createState() => _SignUpSheetContentState();
}

class _SignUpSheetContentState extends State<SignUpSheetContent> {
  final firstC = TextEditingController();
  final lastC = TextEditingController();
  final emailC = TextEditingController();
  final passC = TextEditingController();

  String? emailError;
  String? passError;
  String? firstNameError; 
  String? lastNameError; 
  String? generalError; 

  bool isLoading = false;
  final auth = FirebaseAuth.instance;

  void _setFirebaseError(FirebaseAuthException e) {
    setState(() {
      generalError = null;
      emailError = null;
      passError = null;
      switch (e.code) {
        case "email-already-in-use":
          emailError = "This email is already registered. Try signing in.";
          break;
        case "invalid-email":
          emailError = "Invalid email format.";
          break;
        case "weak-password":
          passError = "Password is too weak. Must be at least 8 characters.";
          break; 
        case "network-request-failed":
          generalError = "Network error. Please check your internet connection.";
          break;
        default:
          generalError = "An unexpected error occurred.";
          break;
      }
    });
  }

  Future<void> handleSignUp() async {
    setState(() {
      emailError = null;
      passError = null;
      firstNameError = null;
      lastNameError = null;
      generalError = null;
    });

    final first = firstC.text.trim();
    final last = lastC.text.trim();
    final email = emailC.text.trim();
    final pass = passC.text.trim();
    bool hasValidationError = false;
    
    // Client-Side Validation
    if (first.isEmpty) {
      setState(() => firstNameError = "First name cannot be empty.");
      hasValidationError = true;
    } else if (first.length < 2) {
      setState(() => firstNameError = "First name must be at least 2 characters.");
      hasValidationError = true;
    } else if (!RegExp(r"^[a-zA-Z]+$").hasMatch(first)) { 
      setState(() => firstNameError = "First name can only contain letters.");
      hasValidationError = true;
    }
    
    if (last.isEmpty) {
      setState(() => lastNameError = "Last name cannot be empty.");
      hasValidationError = true;
    } else if (last.length < 2) {
      setState(() => lastNameError = "Last name must be at least 2 characters.");
      hasValidationError = true;
    } else if (!RegExp(r"^[a-zA-Z]+$").hasMatch(last)) {
      setState(() => lastNameError = "Last name can only contain letters.");
      hasValidationError = true;
    }

    if (email.isEmpty || !RegExp(r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(email)) {
      setState(() => emailError = "Invalid email format (e.g., info@email.com).");
      hasValidationError = true;
    }
    if (pass.length < 8) {
      setState(() => passError = "Password must be at least 8 characters.");
      hasValidationError = true;
    }

    if (hasValidationError) return;

    try {
      setState(() => isLoading = true);

      await auth.createUserWithEmailAndPassword(email: email, password: pass);

      final uid = auth.currentUser!.uid;

      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'firstName': first,
        'lastName': last,
        'email': email,
        'createdAt': DateTime.now(),
      });

      await auth.currentUser?.updateDisplayName('$first $last');

      if (mounted) {
        Navigator.pop(context);
        showAuthSheet(context, const SignInSheetContent());
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Registration successful! Welcome to KEDE App, $first.'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      _setFirebaseError(e);
    } catch (e) {
      setState(() => generalError = "An unexpected error occurred: ${e.toString()}");
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const AuthSheetHeader(title: 'Create your account'),
        const SizedBox(height: 24),
        
        if (generalError != null) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Text(
              'Error: $generalError',
              style: const TextStyle(color: Colors.red, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ),
        ],

        Row(children: [
          Expanded(child: CustomAuthField(
            hintText: "First name", 
            controller: firstC, 
            error: firstNameError,
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z]'))],
          )),
          const SizedBox(width: 16),
          Expanded(child: CustomAuthField(
            hintText: "Last name", 
            controller: lastC, 
            error: lastNameError,
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z]'))],
          )),
        ]),
        const SizedBox(height: 16),

        CustomAuthField(
          hintText: "email",
          controller: emailC,
          keyboardType: TextInputType.emailAddress,
          error: emailError,
        ),
        const SizedBox(height: 16),

        CustomAuthField(
          hintText: "password",
          controller: passC,
          isPassword: true,
          error: passError,
        ),
        const SizedBox(height: 24),

        ElevatedButton(
          onPressed: isLoading ? null : handleSignUp,
          child: isLoading
              ? const CircularProgressIndicator(color: Colors.white)
              : const Text("CREATE AN ACCOUNT"),
        ),
      ],
    );
  }
}

// ====================================================================
// 5. FORGOT PASSWORD SHEET
// ====================================================================

class ForgotPassSheetContent extends StatefulWidget {
  const ForgotPassSheetContent({super.key});

  @override
  State<ForgotPassSheetContent> createState() => _ForgotPassSheetContentState();
}

class _ForgotPassSheetContentState extends State<ForgotPassSheetContent> {
  final emailC = TextEditingController();
  String? emailError;
  String? generalError;
  bool isLoading = false;
  bool success = false;

  final auth = FirebaseAuth.instance;

  // --- PERBAIKAN LOGIKA ERROR DISINI ---
  void _setFirebaseError(FirebaseAuthException e) {
    setState(() {
      generalError = null;
      emailError = null; 
      switch (e.code) {
        // KASUS: Email tidak terdaftar saat reset password
        case "user-not-found":
           emailError = "This email is not registered.";
           break;
        case "invalid-email":
          emailError = "Invalid email format."; 
          break;
        case "network-request-failed":
          generalError = "Network error. Please check your internet connection.";
          break;
        default:
          generalError = "An unexpected error occurred.";
          break;
      }
    });
  }

  Future<void> handleReset() async {
    setState(() {
      emailError = null;
      generalError = null;
      success = false;
    });

    final email = emailC.text.trim();

    // Client-Side Validation
    if (email.isEmpty || !RegExp(r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(email)) {
      setState(() => emailError = "Invalid email format (e.g., info@email.com).");
      return;
    }

    try {
      setState(() => isLoading = true);
      
      await auth.sendPasswordResetEmail(email: email);
      
      setState(() => success = true);

    } on FirebaseAuthException catch (e) {
      _setFirebaseError(e);
      
    } catch (e) {
      setState(() => generalError = "An unexpected error occurred: ${e.toString()}");
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const AuthSheetHeader(title: 'Forget Password'),
        const SizedBox(height: 24),
        
        if (generalError != null) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Text(
              'Error: $generalError',
              style: const TextStyle(color: Colors.red, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ),
        ],

        CustomAuthField(
          hintText: "Your email",
          controller: emailC,
          keyboardType: TextInputType.emailAddress,
          error: emailError, 
        ),
        const SizedBox(height: 24),

        ElevatedButton(
          onPressed: isLoading ? null : handleReset,
          child: isLoading
              ? const CircularProgressIndicator(color: Colors.white)
              : const Text("SUBMIT"),
        ),
        const SizedBox(height: 24),
        
        if (success)
          const Text(
            "✅ Password reset link has been sent! Check your email.",
            style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          
        const SizedBox(height: 10),

        TextButton(
          onPressed: () {
            Navigator.pop(context);
            showAuthSheet(context, const SignInSheetContent());
          },
          child: const Text(
            "Back to Sign In",
            style: TextStyle(color: kPrimaryColor),
          ),
        )
      ],
    );
  }
}