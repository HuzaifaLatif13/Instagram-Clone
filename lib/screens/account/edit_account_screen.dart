import 'dart:io';
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/account.dart';
import '../../controllers/auth_controller.dart';
import '../../services/cloudinary_service.dart';

class EditAccountScreen extends StatefulWidget {
  final Account user;

  const EditAccountScreen({super.key, required this.user});

  @override
  _EditAccountScreenState createState() => _EditAccountScreenState();
}

class _EditAccountScreenState extends State<EditAccountScreen> {
  late TextEditingController nameController;
  late TextEditingController usernameController;
  late TextEditingController bioController;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthController _authController = Get.find<AuthController>();
  late bool _isUpdatingImage = false;
  late String _profileImageUrl;
  String? accountType;

  // Using RxBool to manage saving state with GetX
  RxBool isSaving = false.obs;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.user.name.value);
    usernameController =
        TextEditingController(text: widget.user.username.value);
    bioController = TextEditingController(text: widget.user.bio.value);
    _profileImageUrl = widget.user.profileImage.value;
    accountType = widget.user.accountType.value;
  }

  @override
  void dispose() {
    nameController.dispose();
    usernameController.dispose();
    bioController.dispose();
    super.dispose();
  }

  /// **🔹 Pick Image from Gallery & Upload to Firestore**
  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image == null) return;

    setState(() {
      _isUpdatingImage = true;
    });

    File imageFile = File(image.path);

    try {
      // Upload to Cloudinary
      String? cloudinaryUrl = await CloudinaryService.uploadImage(imageFile);

      if (cloudinaryUrl == null) {
        throw Exception("Failed to upload image to Cloudinary");
      }

      // Update Firestore with the Cloudinary image URL
      await _firestore.collection("users").doc(widget.user.uid.value).update({
        "profileImage": cloudinaryUrl,
      });

      setState(() {
        _profileImageUrl = cloudinaryUrl;
      });

      Get.snackbar("Success", "Profile picture updated",
          snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar("Error", "Failed to update profile picture",
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      setState(() {
        _isUpdatingImage = false;
      });
    }
  }

  /// **🔹 Switch Account Type**
  Future<void> toggleAccountType() async {
    String newAccountType = accountType == 'private'
        ? 'public'
        : 'private'; // Toggle account type logic

    try {
      await _firestore.collection("users").doc(widget.user.uid.value).update({
        "accountType":
            newAccountType, // Update Firestore with the new account type
      });

      setState(() {
        accountType = newAccountType; // Update the local state
      });

      Get.snackbar("Success", "Account switched to $newAccountType",
          snackPosition: SnackPosition.BOTTOM);

      // Update local user object in AuthController
      _authController.currentUser.value = Account(
        uid: widget.user.uid.value,
        username: widget.user.username.value,
        name: widget.user.name.value,
        email: widget.user.email.value,
        bio: widget.user.bio.value,
        profileImage: _profileImageUrl,
        posts: widget.user.posts.value,
        followers: widget.user.followers,
        following: widget.user.following,
        highlights: widget.user.highlights,
        photos: widget.user.photos,
        accountType: newAccountType, // Updated account type
      );
    } catch (e) {
      Get.snackbar("Error", "Failed to switch account",
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  /// **🔹 Save Profile Changes**
  Future<void> saveChanges() async {
    if (isSaving.value) return;

    // Start saving process and show loading indicator
    isSaving.value = true;

    String newName = nameController.text.trim();
    String newUsername = usernameController.text.trim().toLowerCase();
    String newBio = bioController.text.trim();

    // Check if username has changed
    bool usernameChanged = newUsername != widget.user.username.value;

    try {
      // Skip checking for username if not changed
      if (usernameChanged) {
        var usernameQuery = await _firestore
            .collection("users")
            .where("username", isEqualTo: newUsername)
            .get();

        if (usernameQuery.docs.isNotEmpty &&
            usernameQuery.docs.first.id != widget.user.uid.toString()) {
          Get.snackbar("Error", "Username is already taken",
              snackPosition: SnackPosition.BOTTOM);
          // Stop saving and hide loading indicator
          isSaving.value = false;
          return;
        }
      }

      await _firestore.collection("users").doc(widget.user.uid.value).update({
        "name": newName,
        "username": newUsername,
        "bio": newBio,
      });

      _authController.currentUser.value = Account(
        uid: widget.user.uid.value,
        username: newUsername,
        name: newName,
        email: widget.user.email.value,
        bio: newBio,
        profileImage: _profileImageUrl,
        posts: widget.user.posts.value,
        followers: widget.user.followers,
        following: widget.user.following,
        highlights: widget.user.highlights,
        photos: widget.user.photos,
        accountType: accountType.toString(),
      );

      Get.snackbar("Success", "Profile updated successfully",
          snackPosition: SnackPosition.BOTTOM);
      Get.back();
      await Future.delayed(const Duration(milliseconds: 500));

      Get.back();
    } catch (e) {
      Get.snackbar("Error", "Failed to update profile",
          snackPosition: SnackPosition.BOTTOM);
    }

    // Stop saving and hide loading indicator
    isSaving.value = false;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Your existing content here (e.g., Column, TextFields, etc.)
        Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            elevation: 0,
            title: const Text("Edit Profile",
                style: TextStyle(color: Colors.white)),
            actions: [
              IconButton(
                icon: const Icon(Icons.check, color: Colors.white),
                onPressed: saveChanges,
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                GestureDetector(
                  onTap: pickImage,
                  child: Stack(
                    alignment:
                        Alignment.center, // Center the progress indicator
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.grey[700],
                        backgroundImage:
                            CachedNetworkImageProvider(_profileImageUrl),
                      ),
                      // Show circular progress indicator while updating the image
                      if (_isUpdatingImage)
                        const CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.blue),
                          strokeWidth: 4.0,
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: pickImage,
                  child: const Text(
                    "Update Profile Picture",
                    style: TextStyle(color: Colors.blue),
                  ),
                ),
                const SizedBox(height: 20),
                _buildTextField("Name", nameController),
                _buildTextField("Username", usernameController),
                _buildTextField("Bio", bioController, maxLines: null),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[900],
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: toggleAccountType,
                  child: Text(
                    accountType == 'private'
                        ? "Switch to Public Account"
                        : "Switch to Private Account",
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Add the loading overlay here
        Obx(() => isSaving.value
            ? Positioned.fill(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                  child: Container(
                    color: Colors.black.withOpacity(0.5),
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              )
            : const SizedBox.shrink()),
      ],
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {int? maxLines}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: Colors.white),
        maxLines: maxLines,
        keyboardType:
            maxLines != null ? TextInputType.multiline : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white70),
          enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white24)),
          focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white)),
        ),
      ),
    );
  }
}
