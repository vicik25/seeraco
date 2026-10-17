import 'package:states_rebuilder/states_rebuilder.dart';

final loggedInAdmin = RM.inject<Map<String, dynamic>?>(
  () => null,
  autoDisposeWhenNotUsed: false,
);
