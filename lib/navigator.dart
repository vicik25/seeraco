import 'package:navigation_builder/navigation_builder.dart';

import 'pages/cart/Cart.View.dart';
import 'pages/customer_reviews/CustomerReviews.View.dart';
import 'pages/catalog/Catalog.View.dart';
import 'pages/about/About.View.dart';
import 'pages/admin/Admin.View.dart';
import 'pages/buyers/Buyers.View.dart';
import 'pages/home/Home.View.dart';
import 'pages/checkout/Checkout.View.dart';
import 'pages/order_track/OrderTrack.View.dart';
import 'pages/payment/Payment.View.dart';
import 'pages/product_detail/ProductDetail.View.dart';
import 'pages/review/Review.View.dart';
import 'pages/splash/Splash.View.dart';
import 'tasks/task_list.dart';

final nav = NavigationBuilder.create(
  initialLocation: '/splash',
  routes: {
    '/': (RouteData data) => const SplashView(),
    '/splash': (RouteData data) => const SplashView(),
    '/home': (RouteData data) => const HomeView(),
    '/catalog': (RouteData data) => const CatalogView(),
    '/product-detail': (RouteData data) => const ProductDetailView(),
    '/cart': (RouteData data) => const CartView(),
    '/checkout': (RouteData data) => const CheckoutView(),
    '/payment': (RouteData data) => const PaymentView(),
    '/order-track': (RouteData data) => const OrderTrackView(),
    '/buyers': (RouteData data) => const BuyersView(),
    '/about': (RouteData data) => const AboutView(),
    '/admin': (RouteData data) => const AdminView(),
    '/review': (RouteData data) => const ReviewView(),
    '/customer-reviews': (RouteData data) => const CustomerReviewsView(),
    '/tasks': (RouteData data) => const TaskListContainer(),
  },
);
