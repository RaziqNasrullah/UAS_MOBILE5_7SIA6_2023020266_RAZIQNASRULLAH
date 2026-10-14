import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/splash_controller.dart';
import '../../data/services/api_config.dart';
import '../../theme/app_colors.dart';

class SplashView extends GetView<SplashController> {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/logo/logo_icon.png', width: 150),
            const SizedBox(height: 16),
            const Text(
              ApiConfig.namaAplikasi,
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900, color: AppColors.teal),
            ),
            const Text(
              ApiConfig.taglineToko,
              style: TextStyle(color: AppColors.textMuted, letterSpacing: 0.4),
            ),
            const SizedBox(height: 36),
            const SizedBox(
              width: 26,
              height: 26,
              child: CircularProgressIndicator(strokeWidth: 2.6, color: AppColors.primaryDark),
            ),
          ],
        ),
      ),
    );
  }
}
