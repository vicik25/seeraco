import 'package:navigation_builder/navigation_builder.dart';

import 'pages/cart/Cart.View.dart';
import 'pages/catalog/Catalog.View.dart';
import 'pages/home/Home.View.dart';
import 'pages/product_detail/ProductDetail.View.dart';
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
    '/tasks': (RouteData data) => const TaskListContainer(),
  },
);
