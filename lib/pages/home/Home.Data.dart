import 'package:states_rebuilder/states_rebuilder.dart';

import '../../domains/_models/product.dart';
import '../../domains/_models/recent_buyer.dart';
import '../../domains/_models/testimonial.dart';
import '../../core/theme/seera_colors.dart';

final favoriteProducts = RM.inject<List<Product>>(
  () => const [
    Product(
      id: 'butterfly-watch',
      name: 'Butterfly Beads Watch',
      price: 45000,
      category: 'Jam Beads',
      colors: [SeeraColors.lilac, SeeraColors.pinkPop, SeeraColors.lemon],
      description: 'Jam tangan manik warna-warni dengan detail kupu-kupu.',
      rating: 4.9,
      reviewCount: 28,
    ),
    Product(
      id: 'daisy-bracelet',
      name: 'Pastel Daisy Bracelet',
      price: 28000,
      category: 'Gelang',
      colors: [SeeraColors.lemon, SeeraColors.pinkSoft, SeeraColors.babyBlueStar],
      description: 'Gelang bunga mungil untuk menemani hari cerahmu.',
      rating: 5,
      reviewCount: 19,
    ),
    Product(
      id: 'sweetheart-strap',
      name: 'Sweetheart Beads Strap',
      price: 35000,
      category: 'Custom',
      colors: [SeeraColors.pinkPop, SeeraColors.creamPaper, SeeraColors.lilac],
      description: 'Tali aksesori manik dengan aksen hati yang manis.',
      rating: 4.8,
      reviewCount: 16,
    ),
  ],
);

final recentTestimonials = RM.inject<List<Testimonial>>(
  () => const [
    Testimonial(quote: 'Warnanya gemas banget, dipakai seharian tetap nyaman!', displayName: 'Na***a', initials: 'N'),
    Testimonial(quote: 'Packing-nya lucu dan gelangnya persis seperti foto.', displayName: 'Pu***i', initials: 'P'),
    Testimonial(quote: 'Hadiah kecil yang bikin hari sahabatku makin colorful.', displayName: 'Al***a', initials: 'A'),
  ],
);

final recentBuyers = RM.inject<List<RecentBuyer>>(
  () => const [
    RecentBuyer(displayName: 'Ru***a', productName: 'Butterfly Beads Watch', city: 'Bandung', date: '12 Okt 2026'),
    RecentBuyer(displayName: 'Sa***i', productName: 'Pastel Daisy Bracelet', city: 'Yogyakarta', date: '11 Okt 2026'),
    RecentBuyer(displayName: 'De***a', productName: 'Sweetheart Beads Strap', city: 'Jakarta', date: '10 Okt 2026'),
    RecentBuyer(displayName: 'An***n', productName: 'Butterfly Beads Watch', city: 'Surabaya', date: '9 Okt 2026'),
    RecentBuyer(displayName: 'Mi***a', productName: 'Pastel Daisy Bracelet', city: 'Malang', date: '8 Okt 2026'),
  ],
);
