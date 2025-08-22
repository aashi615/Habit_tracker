import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:habit_tracker/services/Firebase_AuthServices.dart';
import 'package:habit_tracker/services/firestore_services.dart';
import 'package:habit_tracker/util/widgets.dart';
import 'package:habit_tracker/views/Login_Page.dart';

class RegistrationPage extends StatefulWidget {
  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final FirebaseAuthService _auth = FirebaseAuthService();
  final FirestoreService _firestore = FirestoreService();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _motoController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _motoController.dispose();
    super.dispose();
  }

  void _register() async {
    setState(() {
      _isLoading = true; // Start loading when registration begins
    });

    String name = _nameController.text.trim();
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();
    String motivationalLine = _motoController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      setState(() {
        _isLoading = false; // Stop loading if fields are incomplete
      });
      _showErrorDialog("Please fill all required fields.");
      return;
    }

    try {
      // Create user with email and password
      User? user = await _auth.signUpWithEmailAndPassword(email, password);
      if (user != null) {
        // Store user data in Firestore
        await _firestore.storeUserData(
          uid: user.uid,
          name: name,
          email: email,
          motivationalLine: motivationalLine,
        );

        // Send verification email
        await user.sendEmailVerification();

        _showSnackBar("Successfully registered! Please verify your email.");

        // Show dialog after email verification
        _showEmailVerificationDialog();
      } else {
        _showErrorDialog("Registration failed. Try again.");
      }
    } catch (e) {
      _showErrorDialog("Error: ${e.toString()}");
    } finally {
      setState(() {
        _isLoading = false; // Stop loading after process ends
      });
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('OK')),
        ],
      ),
    );
  }

  void _showEmailVerificationDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Email Verification Sent'),
        content: Text(
            "A verification email has been sent to your email address. Please verify your email before logging in."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close the dialog
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()), // Navigate to Login Page
              );
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true, // Makes appBar float over the background
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFFDDDE6), Color(0xFF6A82FB)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Text(
                        'Register',
                        style: TextStyle(
                          fontSize: 42,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 40),
                      InputField(
                        controller: _nameController,
                        hintText: "Name",
                        icon: Icons.person,
                      ),
                      SizedBox(height: 20),
                      InputField(
                        controller: _emailController,
                        hintText: "Email",
                        icon: Icons.email,
                        isEmail: true,
                      ),
                      SizedBox(height: 20),
                      InputField(
                        controller: _passwordController,
                        hintText: "Password",
                        icon: Icons.lock,
                        isPassword: true,
                        isPasswordVisible: _isPasswordVisible,
                        togglePasswordVisibility: () {
                          setState(() => _isPasswordVisible = !_isPasswordVisible);
                        },
                      ),
                      SizedBox(height: 20),
                      InputField(
                        controller: _motoController,
                        hintText: "Motivational line (optional)",
                        icon: Icons.format_quote,
                      ),
                      SizedBox(height: 35),
                      ElevatedButton(
                        onPressed: _isLoading ? null : _register,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Color(0xFF0F0E47),
                          padding: EdgeInsets.symmetric(horizontal: 60, vertical: 16),
                          textStyle: TextStyle(fontSize: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 4,
                        ),
                        child: Text(
                          _isLoading ? 'Registering...' : 'Register',
                          style: TextStyle(
                            color: Color(0xFF0F0E47),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushReplacement(
                              context, MaterialPageRoute(builder: (_) => LoginPage()));
                        },
                        child: Text.rich(
                          TextSpan(
                            text: 'Already registered? ',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                            children: [
                              TextSpan(
                                text: 'Login Here',
                                style: TextStyle(
                                  color: Color(0xFF0F0E47),
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (_isLoading)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.4),
                child: Center(
                  child: Transform.rotate(
                    angle: 45,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
