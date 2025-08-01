import 'package:flutter/material.dart';

OutlineInputBorder textFormFieldBorder() {
  return OutlineInputBorder(
    borderRadius: BorderRadius.circular(8),
    borderSide: BorderSide(
      color: Colors.blue.shade300,
    ), // <-- default border color
  );
}
