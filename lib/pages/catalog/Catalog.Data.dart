import 'package:states_rebuilder/states_rebuilder.dart';

import '../../core/theme/seera_colors.dart';
import '../../domains/_models/product.dart';

const catalogCategories = [
  'Semua',
  'Jam Beads',
  'Gelang',
  'Custom',
  'Bundling',
];

final catalogProducts = RM.inject<List<Product>>(
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
    Product(
      id: 'candy-watch',
      name: 'Candy Cloud Watch',
      price: 42000,
      category: 'Jam Beads',
      colors: [SeeraColors.babyBlueStar, SeeraColors.lilac, SeeraColors.pinkSoft],
      description: 'Jam tangan beads bernuansa pastel seperti permen.',
      rating: 4.9,
      reviewCount: 24,
    ),
    Product(
      id: 'bestie-set',
      name: 'Bestie Beads Set',
      price: 52000,
      category: 'Bundling',
      colors: [SeeraColors.pinkPop, SeeraColors.lemon, SeeraColors.skyPastel],
      description: 'Sepasang gelang manik untuk dipakai bareng bestie.',
      rating: 5,
      reviewCount: 11,
    ),
    Product(
      id: 'flower-bracelet',
      name: 'Tiny Flower Bracelet',
      price: 25000,
      category: 'Gelang',
      colors: [SeeraColors.lilac, SeeraColors.creamPaper, SeeraColors.pinkLocker],
      description: 'Gelang bunga sederhana dengan warna pilihanmu.',
      rating: 4.7,
      reviewCount: 9,
    ),
  ],
  autoDisposeWhenNotUsed: false,
);

final selectedCatalogCategory = RM.inject<String>(
  () => 'Semua',
  autoDisposeWhenNotUsed: false,
);
final isCatalogLoading = RM.inject<bool>(
  () => true,
  autoDisposeWhenNotUsed: false,
);
var _catalogLoadScheduled = false;

void scheduleCatalogLoad() {
  if (_catalogLoadScheduled) return;
  _catalogLoadScheduled = true;
  Future<void>.delayed(const Duration(milliseconds: 450)).then((_) {
    isCatalogLoading.state = false;
  });
}

List<Product> get filteredCatalogProducts {
  final category = selectedCatalogCategory.state;
  if (category == 'Semua') return catalogProducts.state;
  return catalogProducts.state
      .where((product) => product.category == category)
      .toList();
}
