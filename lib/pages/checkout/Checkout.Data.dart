import 'package:states_rebuilder/states_rebuilder.dart';

import '../cart/Cart.Data.dart';

final checkoutName = RM.inject<String>(() => '', autoDisposeWhenNotUsed: false);
final checkoutWhatsapp = RM.inject<String>(() => '', autoDisposeWhenNotUsed: false);
final checkoutEmail = RM.inject<String>(() => '', autoDisposeWhenNotUsed: false);
final checkoutAddress = RM.inject<String>(() => '', autoDisposeWhenNotUsed: false);
final checkoutNote = RM.inject<String>(() => '', autoDisposeWhenNotUsed: false);
final checkoutNameError = RM.inject<String?>(() => null, autoDisposeWhenNotUsed: false);
final checkoutWhatsappError = RM.inject<String?>(() => null, autoDisposeWhenNotUsed: false);
final checkoutEmailError = RM.inject<String?>(() => null, autoDisposeWhenNotUsed: false);
final checkoutAddressError = RM.inject<String?>(() => null, autoDisposeWhenNotUsed: false);
final checkoutPrivacyError = RM.inject<String?>(() => null, autoDisposeWhenNotUsed: false);
final checkoutShowName = RM.inject<bool>(() => false, autoDisposeWhenNotUsed: false);
final checkoutPrivacyAccepted = RM.inject<bool>(() => false, autoDisposeWhenNotUsed: false);
final checkoutForm = RM.injectForm();

int get checkoutSubtotal => cartSubtotal;
const checkoutShipping = 4000;
const checkoutUniqueCode = 127;
int get checkoutTotal => checkoutSubtotal + checkoutShipping + checkoutUniqueCode;
