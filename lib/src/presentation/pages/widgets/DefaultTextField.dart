import 'package:flutter/material.dart';

class DefaultTextField extends StatelessWidget {
  final String hintText;
  final String? initialValue;
  final TextEditingController? controller;
  final Function(String text) onChanged;
  final IconData icon;
  final bool obscureText;
  final TextInputType keyboardType;
  final double bottomMargin;
  final String? Function(String?)? validator;
  final Color backgroundColor;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixTap;

  const DefaultTextField({
    super.key,
    required this.hintText,
    required this.icon,
    required this.onChanged,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.bottomMargin = 16,
    this.validator,
    this.backgroundColor = Colors.white,
    this.initialValue,
    this.controller,
    this.suffixIcon,
    this.onSuffixTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: bottomMargin),
      child: TextFormField(
        controller: controller,
        onChanged: (text) {
          onChanged(text);
        },
        initialValue: controller == null ? initialValue : null,
        validator: validator,
        obscureText: obscureText,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(color: Colors.black),
          prefixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(width: 12),
              Icon(icon, color: Colors.grey),
              const SizedBox(width: 8),
              Container(
                width: 1,
                height: 24,
                color: backgroundColor,
              ),
            ],
          ),
          filled: true,
          fillColor: backgroundColor,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          suffixIcon: suffixIcon != null
              ? IconButton(
                  onPressed: onSuffixTap,
                  icon: Icon(suffixIcon, color: Colors.grey),
                )
              : null,
        ),
      ),
    );
  }
}
