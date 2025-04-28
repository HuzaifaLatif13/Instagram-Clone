import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_insta/widgets/divider_with_text.dart';
import '../../controllers/auth_controller.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/image_asset.dart';
import 'login_screen.dart';

class SignUpScreen extends StatelessWidget {
  SignUpScreen({super.key});
  final AuthController controller = Get.put(AuthController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.black,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ImageAsset(imagePath: 'assets/images/app_title.png'),
                const SizedBox(height: 10),
                const Text(
                  "Sign up to see photos and videos from your friends.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 20),

                /// **🔹 Login with Facebook Button**
                Obx(() => CustomButton(
                      text: "Log in with Facebook",
                      onPressed: () {},
                      color: Colors.blueAccent,
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

                const SizedBox(height: 15),
                const DividerWithText(text: 'OR'),
                const SizedBox(height: 15),

                /// **🔹 Email Field**
                CustomTextField(
                  hintText: "Email",
                  errorText: controller.emailError.value
                      ? 'Email can\'t be empty.'
                      : null,
                  onChanged: (value) {
                    controller.email.value = value;
                  },
                ),
                const SizedBox(height: 10),

                /// **🔹 Full Name Field**
                CustomTextField(
                  hintText: "Full Name",
                  errorText: controller.nameError.value
                      ? 'Name can\'t be empty.'
                      : null,
                  onChanged: (value) => controller.name.value = value,
                ),
                const SizedBox(height: 10),

                /// **🔹 Username Field**
                CustomTextField(
                  hintText: "Username",
                  errorText: controller.usernameError.value
                      ? 'Username can\'t be empty.'
                      : null,
                  onChanged: (value) => controller.username.value = value,
                ),
                const SizedBox(height: 10),

                /// **🔹 Password Field**
                CustomTextField(
                  hintText: "Password",
                  obscureText: true,
                  errorText: controller.passwordError.value
                      ? 'Password can\'t be empty.'
                      : null,
                  onChanged: (value) {
                    controller.password.value = value;
                  },
                ),
                const SizedBox(height: 20),

                /// **🔹 Signup Button**
                Obx(() => CustomButton(
                      text: "Sign up",
                      onPressed: controller.signup,
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

                /// **🔹 Terms & Conditions**
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 50),
                  child: const Text(
                    "By signing up, you agree to our\nTerms, Data Policy and Cookies Policy.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white60, fontSize: 12),
                  ),
                ),
                const SizedBox(height: 30),

                /// **🔹 Already Have an Account?**
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: const BoxDecoration(
                    border: Border(
                      top: BorderSide(color: Colors.white38),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Have an account?",
                        style: TextStyle(color: Colors.white),
                      ),
                      TextButton(
                        onPressed: () {
                          Get.to(LoginScreen());
                        },
                        child: const Text(
                          "Log in",
                          style: TextStyle(color: Colors.blueAccent),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
