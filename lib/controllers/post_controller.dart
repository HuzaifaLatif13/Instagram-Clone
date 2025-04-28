import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:get/get.dart';
import '../models/account.dart';
import '../services/cloudinary_service.dart';
import '../models/post.dart';

class PostController extends GetxController {
  var posts = <Post>[].obs;
  RxBool isUploading = false.obs;
  RxBool isLoading = true.obs;
  final isLiked = false.obs;
  final likeCount = 0.obs;
  final comments = <Map<String, dynamic>>[].obs;
  final TextEditingController commentController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    fetchPosts();
  }

  String get currentUserId => FirebaseAuth.instance.currentUser!.uid;

  Future<Account> fetchUser(Post post) async {
    Account user;
    DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(post.userId)
        .get();
    return user = Account.fromDocument(userSnapshot);
  }

  void fetchPosts() {
    FirebaseFirestore.instance.collectionGroup("user-posts").snapshots().listen(
        (snapshot) {
      posts.assignAll(
          snapshot.docs.map((doc) => Post.fromFirestore(doc)).toList());
      Future.delayed(
          Duration(milliseconds: 500), () => isLoading.value = false);
    }, onError: (e) {
      print("❌ Error fetching posts: $e");
    });
  }

  Future<void> toggleLike(Post post) async {
    DocumentReference postRef = FirebaseFirestore.instance
        .collection('posts')
        .doc(post.userId)
        .collection('user-posts')
        .doc(post.postId);

    if (post.likedBy.contains(currentUserId)) {
      await postRef.update({
        'likes': FieldValue.increment(-1),
        'likedBy': FieldValue.arrayRemove([currentUserId]),
      });
    } else {
      await postRef.update({
        'likes': FieldValue.increment(1),
        'likedBy': FieldValue.arrayUnion([currentUserId]),
      });
    }
    posts.refresh();
  }

  void fetchComments(Post post) async {
    DocumentSnapshot postSnapshot = await FirebaseFirestore.instance
        .collection('posts')
        .doc(post.userId)
        .collection('user-posts')
        .doc(post.postId)
        .get();

    if (postSnapshot.exists) {
      List<dynamic> fetchedComments = postSnapshot['comments'] ?? [];
      comments.assignAll(fetchedComments.cast<Map<String, dynamic>>());
    }
  }

  void addComment(Post post) async {
    String commentText = commentController.text.trim();
    if (commentText.isEmpty) return;

    DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUserId)
        .get();

    String username = userSnapshot.get('name') ?? 'Unknown';
    String userProfileImage = userSnapshot.get('profileImage') ?? '';

    final comment = {
      'username': username,
      'userProfileImage': userProfileImage,
      'text': commentText,
      'timestamp': DateTime.now(),
    };

    DocumentReference postRef = FirebaseFirestore.instance
        .collection('posts')
        .doc(post.userId)
        .collection('user-posts')
        .doc(post.postId);

    await postRef.update({
      'comments': FieldValue.arrayUnion([comment])
    });

    commentController.clear();

    fetchComments(post);
  }

  /// **Compress Images Efficiently**
  Future<List<File>> compressImages(List<XFile> selectedMedia) async {
    List<File> compressedFiles = [];
    for (var media in selectedMedia) {
      try {
        File imageFile = File(media.path);
        final outPath = '${imageFile.path}_compressed.jpg';

        var compressedFile = await FlutterImageCompress.compressAndGetFile(
          imageFile.absolute.path,
          outPath,
          quality: 85, // Lower quality to reduce size
        );

        if (compressedFile != null) {
          compressedFiles.add(File(compressedFile.path));
        }
      } catch (e) {
        print("Compression Error: $e");
      }
    }
    return compressedFiles;
  }

  /// **Upload Post with Cloudinary**
  Future<void> sharePost(
      String caption, String location, List<XFile> selectedMedia) async {
    if (isUploading.value) return;
    isUploading.value = true;

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        Get.snackbar("Error", "User not logged in!");
        return;
      }

      String userId = user.uid;

      // Compress images
      List<File> compressedImages = await compressImages(selectedMedia);
      if (compressedImages.isEmpty) {
        Get.snackbar("Error", "No valid images to upload!");
        return;
      }

      // Upload to Cloudinary
      List<String> cloudinaryUrls = [];
      for (var image in compressedImages) {
        String? imageUrl = await CloudinaryService.uploadImage(image);
        if (imageUrl != null) {
          cloudinaryUrls.add(imageUrl);
        }
      }

      if (cloudinaryUrls.isEmpty) {
        Get.snackbar("Error", "Failed to upload images!");
        return;
      }

      // Save post data to Firestore
      await uploadPost(userId, caption, location, cloudinaryUrls);

      Get.snackbar("Success", "Post shared successfully!");
    } catch (e) {
      Get.snackbar("Error", "Error: $e");
    } finally {
      isUploading.value = false;
    }
  }

  /// **Upload post to Firestore**
  Future<void> uploadPost(String userId, String caption, String location,
      List<String> imageUrls) async {
    try {
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      Map<String, dynamic> userData =
          userSnapshot.data() as Map<String, dynamic>;

      String username = userData['username'] ?? 'Unknown';
      String userProfileImage = userData['profileImage'] ?? '';
      DocumentReference postRef = FirebaseFirestore.instance
          .collection('posts')
          .doc(userId)
          .collection('user-posts')
          .doc();
      String postId = postRef.id;

      await postRef.set({
        'postId': postId,
        'userId': userId,
        'username': username,
        'userProfileImage': userProfileImage,
        'postImages': imageUrls,
        'caption': caption,
        'location': location,
        'likes': 0,
        'likedBy': [],
        'timestamp': FieldValue.serverTimestamp(),
        'comments': [],
      });
    } catch (e) {
      Get.snackbar("Error", "Failed to upload post: $e");
    }
  }

  //delete
  Future<bool> deletePost(Post post) async {
    isUploading.value = true;
    try {
      final String userId = post.userId;
      final String postId = post.postId;

      // Reference to the post in Firestore
      DocumentReference postRef = FirebaseFirestore.instance
          .collection('posts')
          .doc(userId)
          .collection('user-posts')
          .doc(postId);

      // Delete images from Cloudinary
      for (String imageUrl in post.postImages) {
        await CloudinaryService.deleteImage(imageUrl);
      }

      // Delete post from Firestore
      await postRef.delete();

      // Update user document
      FirebaseFirestore.instance.collection('users').doc(userId).update({
        'posts': FieldValue.increment(-1),
        'photos': FieldValue.arrayRemove([postId])
      });
      isUploading.value = false;
      return true;
    } catch (e) {
      Get.snackbar("Error", "Failed to delete post: $e");
      return false;
    }
  }
}
