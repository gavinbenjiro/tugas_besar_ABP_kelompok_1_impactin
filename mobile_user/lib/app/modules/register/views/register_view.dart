// =========================================================
// REGISTER VIEW
// =========================================================

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../routes/app_pages.dart';
import '../controllers/register_controller.dart';

class RegisterView extends GetView<RegisterController> {
  const RegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // =================================================
          // BACKGROUND IMAGE
          // =================================================
          SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: Image.asset(
              "assets/images/auth1_bg.png", // CHANGE THIS
              fit: BoxFit.cover,
            ),
          ),

          // =================================================
          // DARK OVERLAY
          // =================================================
          Container(
            color: Colors.black.withOpacity(0.35),
          ),

          // =================================================
          // CONTENT
          // =================================================
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.only(
                left: size.width * 0.06,
                right: size.width * 0.06,
                top: size.height * 0.04,
                bottom: MediaQuery.of(context).viewInsets.bottom +
                    size.height * 0.03,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Enter Into The\nNature World",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: size.width * 0.11,
                      fontWeight: FontWeight.w700,
                      height: 1.15,
                    ),
                  ),
                  SizedBox(height: size.height * 0.08),
                  Center(
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        horizontal: size.width * 0.055,
                        vertical: size.height * 0.04,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(28),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "ImpactIn",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: size.width * 0.075,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(
                            height: size.height * 0.015,
                          ),
                          Text(
                            "Welcome Back! drop your registered username",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: size.width * 0.026,
                            ),
                          ),
                          SizedBox(
                            height: size.height * 0.03,
                          ),
                          _textField(
                            context,
                            hint: "Email",
                            controller: controller.emailController,
                          ),
                          SizedBox(
                            height: size.height * 0.02,
                          ),
                          _textField(
                            context,
                            hint: "Username",
                            icon: Icons.person_outline,
                            controller: controller.usernameController,
                          ),
                          SizedBox(
                            height: size.height * 0.02,
                          ),
                          _textField(
                            context,
                            hint: "Password",
                            controller: controller.passwordController,
                            obscure: true,
                          ),
                          SizedBox(
                            height: size.height * 0.02,
                          ),
                          _textField(
                            context,
                            hint: "Confirm Password",
                            controller: controller.confirmPasswordController,
                            obscure: true,
                          ),
                          SizedBox(
                            height: size.height * 0.045,
                          ),
                          SizedBox(
                            width: double.infinity,
                            height: size.height * 0.06,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(
                                  0xFF1C6B46,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    14,
                                  ),
                                ),
                              ),
                              onPressed: () {
                                controller.register();
                              },
                              child: Text(
                                "SIGN IN",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: size.width * 0.043,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: size.height * 0.025,
                          ),
                          Center(
                            child: GestureDetector(
                              onTap: () {
                                Get.toNamed(
                                  Routes.LOGIN,
                                );
                              },
                              child: RichText(
                                text: TextSpan(
                                  text: "Already have an account? ",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: size.width * 0.032,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: "LOG IN",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // TEXTFIELD
  // =========================================================

  Widget _textField(
    BuildContext context, {
    required String hint,
    IconData? icon,
    TextEditingController? controller,
    bool obscure = false,
  }) {
    final size = MediaQuery.of(context).size;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(14),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        style: const TextStyle(
          color: Colors.white,
        ),
        decoration: InputDecoration(
          border: InputBorder.none,
          prefixIcon: icon != null
              ? Icon(
                  icon,
                  color: Colors.white70,
                  size: size.width * 0.05,
                )
              : null,
          hintText: hint,
          hintStyle: TextStyle(
            color: Colors.white70,
            fontSize: size.width * 0.04,
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: size.width * 0.05,
            vertical: size.height * 0.02,
          ),
        ),
      ),
    );
  }
}
