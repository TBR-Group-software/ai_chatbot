import 'package:flutter/material.dart';

class ErrorInfoEntity {

  ErrorInfoEntity({
    required this.title,
    required this.description,
    required this.icon,
    required this.canRetry,
  });
  final String title;
  final String description;
  final IconData icon;
  final bool canRetry;
} 
