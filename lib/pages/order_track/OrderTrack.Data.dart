import 'package:states_rebuilder/states_rebuilder.dart';

import '../../domains/_models/cart_item.dart';

final orderTrackCode = RM.inject<String>(
  () => '',
  autoDisposeWhenNotUsed: false,
);
final orderTrackWhatsapp = RM.inject<String>(
  () => '',
  autoDisposeWhenNotUsed: false,
);
final orderTrackAddress = RM.inject<String>(
  () => '',
  autoDisposeWhenNotUsed: false,
);
final orderTrackStatus = RM.inject<String>(
  () => '',
  autoDisposeWhenNotUsed: false,
);
final savedOrderCode = RM.inject<String>(
  () => '',
  autoDisposeWhenNotUsed: false,
);
final savedOrderWhatsapp = RM.inject<String>(
  () => '',
  autoDisposeWhenNotUsed: false,
);
final orderTrackItems = RM.inject<List<CartItem>>(
  () => const [],
  autoDisposeWhenNotUsed: false,
);
final orderTrackTotal = RM.inject<int>(() => 0, autoDisposeWhenNotUsed: false);
final orderTrackHasSearched = RM.inject<bool>(
  () => false,
  autoDisposeWhenNotUsed: false,
);
final orderTrackHasMatch = RM.inject<bool>(
  () => false,
  autoDisposeWhenNotUsed: false,
);
final orderTrackCompleted = RM.inject<bool>(
  () => false,
  autoDisposeWhenNotUsed: false,
);
final orderTrackExpectedWhatsapp = RM.inject<String>(
  () => '',
  autoDisposeWhenNotUsed: false,
);
final orderTrackForm = RM.injectForm();
