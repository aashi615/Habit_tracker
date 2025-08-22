import 'package:flutter/material.dart';

class InputField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData icon;
  final bool isPassword;
  final bool isEmail;
  final bool isPasswordVisible;
  final VoidCallback? togglePasswordVisibility;

  const InputField({
    required this.controller,
    required this.hintText,
    required this.icon,
    this.isPassword = false,
    this.isEmail = false,
    this.isPasswordVisible = false,
    this.togglePasswordVisibility,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.65),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword && !isPasswordVisible,
        keyboardType: isEmail ? TextInputType.emailAddress : TextInputType.text,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color:Color(0xFF0F0E47)),
          suffixIcon: isPassword
              ? IconButton(
            icon: Icon(
              isPasswordVisible ? Icons.visibility : Icons.visibility_off,
              color: Color(0xFF0F0E47),
            ),
            onPressed: togglePasswordVisibility,
          )
              : null,
          hintText: hintText,
          hintStyle: TextStyle(color: Color(0xFF0F0E47)),
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(16.0),
        ),
        style: TextStyle(color:Color(0xFF0F0E47)),
      ),
    );
  }
}
