import 'package:states_rebuilder/states_rebuilder.dart';

import '../../domains/_models/recent_buyer.dart';

export '../catalog/Catalog.Data.dart'
    show
        favoriteProducts,
        recentTestimonials,
        isCatalogLoading,
        catalogLoadError,
        isReviewsLoading,
        reviewsLoadError,
        loadStoreData;

final recentBuyers = RM.inject<List<RecentBuyer>>(
  () => const [],
  autoDisposeWhenNotUsed: false,
);
