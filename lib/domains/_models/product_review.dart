class ProductReview {
  const ProductReview({
    required this.id,
    required this.productName,
    required this.customerName,
    required this.comment,
    required this.rating,
  });

  final String id;
  final String productName;
  final String customerName;
  final String comment;
  final int rating;

  factory ProductReview.fromJson(Map<String, dynamic> json) {
    return ProductReview(
      id: _value(json, const ['id', 'id_review', 'review_id']),
      productName: _value(json, const [
        'nama_produk',
        'product_name',
        'produk',
      ]),
      customerName: _value(json, const [
        'nama_pelanggan',
        'nama_customer',
        'customer_name',
        'nama',
      ]),
      comment: _value(json, const [
        'ulasan',
        'isi_ulasan',
        'review',
        'komentar',
        'comment',
      ]),
      rating:
          int.tryParse(
            _value(json, const ['rating', 'nilai_rating', 'bintang']),
          ) ??
          0,
    );
  }
}

String _value(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value != null) return value.toString();
  }
  return '';
}
