import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:my_insta/screens/auth/login_screen.dart';
import 'package:my_insta/screens/home/main_screen.dart';
import '../models/account.dart';
import '../services/cloudinary_service.dart';
import 'package:image_picker/image_picker.dart';

class AuthController extends GetxController {
  static AuthController instance = Get.find();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  RxBool emailError = false.obs;
  RxBool passwordError = false.obs;
  RxBool nameError = false.obs;
  RxBool usernameError = false.obs;

  Rx<Account?> currentUser = Rx<Account?>(null);
  var cuid = ''.obs;
  var name = ''.obs;
  var email = ''.obs;
  var username = ''.obs;
  var password = ''.obs;
  var isLoading = false.obs;

  final String defaultProfileImageURL =
      "https://img.freepik.com/premium-vector/default-avatar-profile-icon-social-media-user-image-gray-avatar-icon-blank-profile-silhouette-vector-illustration_561158-3383.jpg";

  Stream<DocumentSnapshot>? _userStream;

  @override
  void onReady() {
    super.onReady();
    _auth.authStateChanges().listen((User? user) {
      user != null ? listenToUserData(user.uid) : currentUser.value = null;
    });
  }

  /// **🔹 Listen to real-time user data updates**
  void listenToUserData(String uid) {
    _userStream = _firestore.collection('users').doc(uid).snapshots();
    _userStream?.listen((snapshot) {
      if (snapshot.exists) {
        currentUser.value =
            Account.fromMap(snapshot.data() as Map<String, dynamic>);
      }
    });
  }

  /// **🔹 Login Function**
  Future<void> login() async {
    if (email.value.isEmpty || password.value.isEmpty) {
      emailError.value = email.value.isEmpty;
      passwordError.value = password.value.isEmpty;
      _showSnackbar("Error", "All fields are required");
      return;
    }
    emailError.value = false;
    passwordError.value = false;

    _setLoading(true);
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email.value.trim(),
        password: password.value.trim(),
      );

      if (userCredential.user != null) {
        listenToUserData(userCredential.user!.uid);
        Get.offAll(() => MainScreen());
      }
    } on FirebaseAuthException catch (e) {
      _handleAuthError(e);
    } finally {
      _setLoading(false);
    }
  }

  /// **🔹 Signup Function (Now Uses Cloudinary)**
  Future<void> signup() async {
    if (name.value.isEmpty ||
        email.value.isEmpty ||
        username.value.isEmpty ||
        password.value.isEmpty) {
      nameError.value = name.value.isEmpty;
      emailError.value = email.value.isEmpty;
      usernameError.value = username.value.isEmpty;
      passwordError.value = password.value.isEmpty;
      _showSnackbar("Error", "All fields are required");
      return;
    }
    nameError.value = false;
    emailError.value = false;
    usernameError.value = false;
    passwordError.value = false;

    _setLoading(true);

    try {
      String normalizedUsername = username.value.trim().toLowerCase();

      bool isUsernameTaken = await _isUsernameTaken(normalizedUsername);
      if (isUsernameTaken) {
        _showSnackbar("Error", "Username is already taken");
        return;
      }

      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email.value.trim(),
        password: password.value.trim(),
      );

      String uid = userCredential.user!.uid;
      cuid.value = uid;

      String profileImageUrl =
          await _uploadProfileImage() ?? defaultProfileImageURL;

      Account newUser = Account(
        uid: uid,
        username: normalizedUsername,
        name: name.value,
        email: email.value,
        bio: "Hey there! I am using this app. #new",
        profileImage: profileImageUrl,
        posts: 0,
        followers: [],
        following: [],
        highlights: [],
        photos: [],
        accountType: 'public',
      );

      await _firestore.collection("users").doc(uid).set(newUser.toMap());

      _showSnackbar("Success", "Account created successfully");
      Get.offAll(() => MainScreen());

      listenToUserData(uid);
    } on FirebaseAuthException catch (e) {
      _handleAuthError(e);
    } finally {
      _setLoading(false);
    }
  }

  /// **🔹 Logout Function**
  Future<void> logout() async {
    await _auth.signOut();
    Get.offAll(() => LoginScreen());
  }

  /// **🔹 Pick Image from Gallery**
  Future<File?> pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    return pickedFile != null ? File(pickedFile.path) : null;
  }

  /// **🔹 Upload Profile Image to Cloudinary**
  Future<String?> _uploadProfileImage() async {
    try {
      File? imageFile = await pickImage();
      if (imageFile != null) {
        return await CloudinaryService.uploadImage(imageFile);
      }
    } catch (e) {
      print("Error uploading image: $e");
    }
    return null;
  }

  /// **🔹 Check if Username is Already Taken**
  Future<bool> _isUsernameTaken(String username) async {
    var usernameQuery = await _firestore
        .collection("users")
        .where("username", isEqualTo: username)
        .get();
    return usernameQuery.docs.isNotEmpty;
  }

  /// **🔹 Validate Form Fields**
  // bool validateFields(
  //     [String? name, String? email, String? username, String? password]) {
  //   if ((name?.isEmpty ?? true) ||
  //       (email?.isEmpty ?? true) ||
  //       (username?.isEmpty ?? true) ||
  //       (password?.isEmpty ?? true)) {
  //     emailError.value = email?.isEmpty ?? true;
  //     passwordError.value = password?.isEmpty ?? true;
  //     nameError.value = name?.isEmpty ?? true;
  //     usernameError.value = username?.isEmpty ?? true;
  //     _showSnackbar("Error", "All fields are required");
  //     return false;
  //   } else {
  //     emailError.value = false;
  //     passwordError.value = false;
  //     nameError.value = false;
  //     usernameError.value = false;
  //   }
  //   return true;
  // }

  /// **🔹 Handle Authentication Errors**
  void _handleAuthError(FirebaseAuthException e) {
    String errorMessage = "An error occurred. Please try again.";
    if (e.code == 'user-not-found') {
      errorMessage = "No user found for this email.";
    } else if (e.code == 'wrong-password') {
      errorMessage = "Incorrect password.";
    } else if (e.code == 'email-already-in-use') {
      errorMessage = "Email is already registered.";
    }
    _showSnackbar("Error", errorMessage);
  }

  /// **🔹 Show Snackbar for Messages**
  void _showSnackbar(String title, String message) {
    Get.snackbar(title, message,
        duration: Duration(seconds: 2), snackPosition: SnackPosition.BOTTOM);
  }

  /// **🔹 Set Loading State with Animation**
  void _setLoading(bool state) {
    isLoading.value = state;
    if (state) {
      Future.delayed(Duration(milliseconds: 500), () {
        if (isLoading.value) isLoading.value = false;
      });
    }
  }
}
