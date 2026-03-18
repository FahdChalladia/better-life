import 'package:flutter/material.dart';
import '../utils/constants.dart';

class CustomInput extends StatelessWidget {
  final String hint;
  final bool obscure;
  final TextEditingController controller;

  const CustomInput({
    super.key,
    required this.hint,
    this.obscure = false,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: AppColors.input,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
