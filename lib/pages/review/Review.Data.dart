import 'package:states_rebuilder/states_rebuilder.dart';

final reviewProducts = RM.inject<List<String>>(
  () => const ['Pastel Daisy Bracelet'],
  autoDisposeWhenNotUsed: false,
);
final reviewRatings = RM.inject<List<int>>(
  () => [0],
  autoDisposeWhenNotUsed: false,
);
final reviewText = RM.inject<String>(() => '', autoDisposeWhenNotUsed: false);
final reviewForm = RM.injectForm();

const reviewOrderCode = 'SEERA-261012-004';
const reviewTextMaxLength = 400;
