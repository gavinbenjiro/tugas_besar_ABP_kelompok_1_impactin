import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import '../controllers/splash_controller.dart';

class SplashView extends GetView<SplashController> {
  const SplashView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: Center(
        child: Lottie.asset(
          'assets/lottie/splash_anim.json',
          width: 380,
          height: 380,
          fit: BoxFit.contain,
          repeat: false,
          onLoaded: (composition) {
            controller.startTransition(composition.duration);
          },
        ),
      ),
    );
  }
}