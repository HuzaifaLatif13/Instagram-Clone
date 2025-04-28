import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_insta/screens/auth/signup_screen.dart';
import '../../controllers/auth_controller.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/divider_with_text.dart';
import '../../widgets/image_asset.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController controller = Get.put(AuthController());

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ImageAsset(imagePath: 'assets/images/app_title.png'),
            const SizedBox(height: 30),

            // Email Field
            Obx(() => CustomTextField(
                  hintText: "Email",
                  errorText: controller.emailError.value
                      ? 'Email can\'t be empty.'
                      : null,
                  onChanged: (value) {
                    controller.email.value = value;
                  },
                )),
            const SizedBox(height: 15),

            // Password Field
            Obx(() => CustomTextField(
                  hintText: "Password",
                  errorText: controller.passwordError.value
                      ? 'Password can\'t be empty.'
                      : null,
                  obscureText: true,
                  onChanged: (value) {
                    controller.password.value = value;
                  },
                )),
            const SizedBox(height: 10),

            // Forgot Password Button
            Align(
              alignment: Alignment.centerRight,
              child: CustomTextButton(
                  callback: () {
                    // Handle forgot password logic
                  },
                  text: "Forgot password?",
                  color: Colors.blue),
            ),
            const SizedBox(height: 15),

            // Login Button with New Animation
            Obx(() => CustomButton(
                  text: "Log in",
                  onPressed: () => controller.login(),
                  color: Colors.blue,
                  isLoading: controller.isLoading.value,
                  loadingWidget: const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  ),
                )),
            const SizedBox(height: 20),

            // Divider with Text
            const DividerWithText(text: "OR"),
            const SizedBox(height: 20),

            // Sign-up Navigation
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Don't have an account? "),
                CustomTextButton(
                  text: "Sign up.",
                  color: Colors.blue,
                  callback: () {
                    Get.off(() => SignUpScreen());
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
