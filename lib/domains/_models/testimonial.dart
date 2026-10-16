class Testimonial {
  const Testimonial({
    required this.quote,
    required this.displayName,
    required this.initials,
    this.rating = 0,
    this.productName = '',
  });

  final String quote;
  final String displayName;
  final String initials;
  final int rating;
  final String productName;
}
