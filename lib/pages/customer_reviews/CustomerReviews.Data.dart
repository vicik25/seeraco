import 'package:states_rebuilder/states_rebuilder.dart';

import '../../domains/_models/product_review.dart';

final customerReviews = RM.inject<List<ProductReview>>(
  () => const [],
  autoDisposeWhenNotUsed: false,
);
final isCustomerReviewsLoading = RM.inject<bool>(
  () => true,
  autoDisposeWhenNotUsed: false,
);
final customerReviewsError = RM.inject<String?>(
  () => null,
  autoDisposeWhenNotUsed: false,
);
