import 'package:flutter/material.dart';

class Product {
  const Product({
    this.id = '',
    required this.name,
    required this.price,
    required this.colors,
    required this.description,
    this.category = 'Jam Beads',
    this.rating = 4.9,
    this.reviewCount = 32,
  });

  final String id;
  final String name;
  final int price;
  final List<Color> colors;
  final String description;
  final String category;
  final double rating;
  final int reviewCount;
}
