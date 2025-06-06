import 'package:flutter/material.dart';

class ErrorInfoEntity {
  final String title;
  final String description;
  final IconData icon;
  final bool canRetry;

  ErrorInfoEntity({
    required this.title,
    required this.description,
    required this.icon,
    required this.canRetry,
  });
} 