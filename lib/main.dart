import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app/bindings/initial_binding.dart';
import 'app/data/services/api_config.dart';
import 'app/routes/app_pages.dart';
import 'app/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID');
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const MyHealthGwApp());
}

class MyHealthGwApp extends StatelessWidget {
  const MyHealthGwApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: ApiConfig.namaAplikasi,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      initialBinding: InitialBinding(),
      initialRoute: AppPages.initial,
      getPages: AppPages.pages,
      defaultTransition: Transition.rightToLeft,
      locale: const Locale('id', 'ID'),
      fallbackLocale: const Locale('id', 'ID'),
      supportedLocales: const [Locale('id', 'ID'), Locale('en', 'US')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}
