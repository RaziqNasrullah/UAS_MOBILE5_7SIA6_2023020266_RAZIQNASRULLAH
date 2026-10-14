import 'package:get/get.dart';

import '../bindings/checkout_binding.dart';
import '../bindings/dashboard_binding.dart';
import '../bindings/kategori_binding.dart';
import '../bindings/main_binding.dart';
import '../bindings/pesanan_detail_binding.dart';
import '../bindings/produk_binding.dart';
import '../bindings/produk_detail_binding.dart';
import '../bindings/splash_binding.dart';
import '../bindings/struk_binding.dart';
import '../views/cart/cart_view.dart';
import '../views/checkout/checkout_sukses_view.dart';
import '../views/checkout/checkout_view.dart';
import '../views/dashboard/dashboard_view.dart';
import '../views/kategori/kategori_form_view.dart';
import '../views/kategori/kategori_view.dart';
import '../views/main/main_view.dart';
import '../views/pesanan_detail/pesanan_detail_view.dart';
import '../views/produk/produk_form_view.dart';
import '../views/produk/produk_view.dart';
import '../views/produk_detail/produk_detail_view.dart';
import '../views/splash/splash_view.dart';
import '../views/struk/struk_view.dart';
import 'app_routes.dart';

/// Daftar GetPage (route -> view + binding).
class AppPages {
  AppPages._();

  static const initial = Routes.splash;

  static final pages = <GetPage>[
    GetPage(name: Routes.splash, page: () => const SplashView(), binding: SplashBinding()),
    GetPage(name: Routes.main, page: () => const MainView(), binding: MainBinding()),
    GetPage(
      name: Routes.produkDetail,
      page: () => const ProdukDetailView(),
      binding: ProdukDetailBinding(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: Routes.keranjang,
      page: () => const CartView(standalone: true),
      transition: Transition.rightToLeft,
    ),
    GetPage(name: Routes.checkout, page: () => const CheckoutView(), binding: CheckoutBinding()),
    GetPage(
      name: Routes.checkoutSukses,
      page: () => const CheckoutSuksesView(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: Routes.pesananDetail,
      page: () => const PesananDetailView(),
      binding: PesananDetailBinding(),
    ),
    GetPage(name: Routes.struk, page: () => const StrukView(), binding: StrukBinding()),
    GetPage(name: Routes.dashboard, page: () => const DashboardView(), binding: DashboardBinding()),
    GetPage(name: Routes.kategori, page: () => const KategoriView(), binding: KategoriBinding()),
    GetPage(
      name: Routes.kategoriForm,
      page: () => const KategoriFormView(),
      binding: KategoriFormBinding(),
    ),
    GetPage(name: Routes.produk, page: () => const ProdukView(), binding: ProdukBinding()),
    GetPage(name: Routes.produkForm, page: () => const ProdukFormView(), binding: ProdukFormBinding()),
  ];
}
