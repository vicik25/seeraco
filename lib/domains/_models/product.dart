import 'package:flutter/material.dart';

class Product {
  const Product({
    this.id = '',
    required this.name,
    required this.price,
    this.colors = const [Color(0xFFF8509F), Color(0xFFFFD3E6)],
    required this.description,
    this.category = 'Jam Beads',
    this.rating = 4.9,
    this.reviewCount = 32,
    this.imageUrl = '',
    this.costPrice = 0,
    this.marker = '',
    this.stock = 0,
  });

  final String id;
  final String name;
  final int price;
  final List<Color> colors;
  final String description;
  final String category;
  final double rating;
  final int reviewCount;
  final String imageUrl;
  final int costPrice;
  final String marker;
  final int stock;

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: _readString(json, const [
        'id',
        'id_produk',
        'kode_produk',
        'produk_id',
      ]),
      name: _readString(json, const ['nama_produk', 'nama', 'product_name']),
      price: _readInt(json, const ['harga', 'harga_jual', 'price']),
      description: _readString(json, const [
        'deskripsi',
        'description',
        'detail_produk',
      ]),
      category: _readString(json, const ['kategori', 'category']).isEmpty
          ? 'Lainnya'
          : _readString(json, const ['kategori', 'category']),
      imageUrl: _readString(json, const [
        'gambar',
        'gambar_produk',
        'foto',
        'foto_produk',
        'image',
        'image_url',
      ]),
      costPrice: _readInt(json, const [
        'hpp',
        'hpp_satuan',
        'harga_pokok',
        'cost_price',
      ]),
      marker: _readString(json, const ['penanda', 'label', 'tag']),
      stock: _readInt(json, const ['stok', 'stock']),
      rating:
          double.tryParse(_readString(json, const ['rating', 'rata_rating'])) ??
          0,
      reviewCount: _readInt(json, const ['jumlah_ulasan', 'review_count']),
    );
  }
}

String _readString(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value != null) return value.toString();
  }
  return '';
}

int _readInt(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value != null) {
      if (value is num) return value.round();
      final normalized = value.toString().trim().replaceAll(
        RegExp(r'[^0-9,.-]'),
        '',
      );
      final dot = normalized.lastIndexOf('.');
      final comma = normalized.lastIndexOf(',');
      final separatorIndex = dot > comma ? dot : comma;
      if (separatorIndex >= 0 && normalized.length - separatorIndex - 1 <= 2) {
        final integerPart = normalized
            .substring(0, separatorIndex)
            .replaceAll(RegExp(r'[.,]'), '');
        final fractionalPart = normalized
            .substring(separatorIndex + 1)
            .replaceAll(RegExp(r'[.,]'), '');
        return int.tryParse('$integerPart.$fractionalPart') ??
            double.tryParse('$integerPart.$fractionalPart')?.round() ??
            0;
      }
      return int.tryParse(normalized.replaceAll(RegExp(r'[.,]'), '')) ?? 0;
    }
  }
  return 0;
}
