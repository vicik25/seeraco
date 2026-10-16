import 'package:states_rebuilder/states_rebuilder.dart';

final reviewProducts = RM.inject<List<String>>(
  () => const [],
  autoDisposeWhenNotUsed: false,
);
final reviewRatings = RM.inject<List<int>>(
  () => const [],
  autoDisposeWhenNotUsed: false,
);
final reviewText = RM.inject<String>(() => '', autoDisposeWhenNotUsed: false);
final reviewForm = RM.injectForm();

const reviewTextMaxLength = 500;
