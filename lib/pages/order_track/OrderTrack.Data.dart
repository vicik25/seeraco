import 'package:states_rebuilder/states_rebuilder.dart';

final orderTrackCode = RM.inject<String>(() => '', autoDisposeWhenNotUsed: false);
final orderTrackWhatsapp = RM.inject<String>(() => '', autoDisposeWhenNotUsed: false);
final orderTrackHasSearched = RM.inject<bool>(() => false, autoDisposeWhenNotUsed: false);
final orderTrackHasMatch = RM.inject<bool>(() => false, autoDisposeWhenNotUsed: false);
final orderTrackCompleted = RM.inject<bool>(() => false, autoDisposeWhenNotUsed: false);
final orderTrackExpectedWhatsapp = RM.inject<String>(
  () => trackedOrderWhatsapp,
  autoDisposeWhenNotUsed: false,
);
final orderTrackForm = RM.injectForm();

const trackedOrderCode = 'SEERA-261013-001';
const trackedOrderWhatsapp = '81234567890';
const completedReviewOrderCode = 'SEERA-261012-004';
