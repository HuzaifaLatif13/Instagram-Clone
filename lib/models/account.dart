import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class Account {
  var uid = ''.obs;
  var username = ''.obs;
  var email = ''.obs;
  var name = ''.obs;
  var bio = ''.obs;
  var profileImage = ''.obs;
  var posts = 0.obs;
  var followers = <String>[].obs; // Changed to a list of UIDs
  var following = <String>[].obs; // Changed to a list of UIDs
  var highlights = <String>[].obs;
  var photos = <String>[].obs;
  var accountType = 'public'.obs; // Default to 'public'

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Account({
    required String uid,
    required String username,
    required String name,
    required String email,
    required String bio,
    required String profileImage,
    required int posts,
    required List<String> followers,
    required List<String> following,
    required List<String> highlights,
    required List<String> photos,
    required String accountType,
  }) {
    this.uid.value = uid;
    this.username.value = username;
    this.email.value = email;
    this.name.value = name;
    this.bio.value = bio;
    this.profileImage.value = profileImage;
    this.posts.value = posts;
    this.followers.assignAll(followers);
    this.following.assignAll(following);
    this.highlights.assignAll(highlights);
    this.photos.assignAll(photos);
    this.accountType.value = accountType;
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid.value,
      'username': username.value,
      'name': name.value,
      'email': email.value,
      'bio': bio.value,
      'profileImage': profileImage.value,
      'posts': posts.value,
      'followers': followers.toList(), // Converted to list
      'following': following.toList(), // Converted to list
      'highlights': highlights.toList(),
      'photos': photos.toList(),
      'accountType': accountType.value,
    };
  }

  factory Account.fromMap(Map<String, dynamic> map) {
    return Account(
      uid: map['uid'] ?? '',
      username: map['username'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      bio: map['bio'] ?? '',
      profileImage: map['profileImage'] ?? '',
      posts: map['posts'] ?? 0,
      followers:
          List<String>.from(map['followers'] ?? []), // Converting to list
      following:
          List<String>.from(map['following'] ?? []), // Converting to list
      highlights: List<String>.from(map['highlights'] ?? []),
      photos: List<String>.from(map['photos'] ?? []),
      accountType: map['accountType'] ?? 'public',
    );
  }

  factory Account.fromDocument(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Account.fromMap(data);
  }

  /// **Follow a user and update Firestore**
  Future<void> followUser(String targetUserId) async {
    if (!following.contains(targetUserId)) {
      try {
        // Update Firestore: Add targetUserId to current user's following list
        await _firestore.collection('users').doc(uid.value).update({
          'following': FieldValue.arrayUnion([targetUserId]),
        });

        // Update Firestore: Add current user to target user's followers list
        await _firestore.collection('users').doc(targetUserId).update({
          'followers': FieldValue.arrayUnion([uid.value]),
        });

        // Update local state (GetX)
        following.add(targetUserId);
      } catch (e) {
        print('Error following user: $e');
      }
    }
  }

  /// **Unfollow a user**
  Future<void> unfollowUser(String targetUserId) async {
    if (following.contains(targetUserId)) {
      try {
        // Update Firestore: Remove targetUserId from current user's following list
        await _firestore.collection('users').doc(uid.value).update({
          'following': FieldValue.arrayRemove([targetUserId]),
        });

        // Update Firestore: Remove current user from target user's followers list
        await _firestore.collection('users').doc(targetUserId).update({
          'followers': FieldValue.arrayRemove([uid.value]),
        });

        // Update local state (GetX)
        following.remove(targetUserId);
      } catch (e) {
        print('Error unfollowing user: $e');
      }
    }
  }

  Future<void> listenToUserUpdates() async {
    FirebaseFirestore.instance
        .collection('users')
        .doc(uid.value) // Assuming 'uid' is stored in the class
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        var data = snapshot.data() as Map<String, dynamic>;

        // Update reactive variables dynamically
        username.value = data['username'] ?? '';
        name.value = data['name'] ?? '';
        bio.value = data['bio'] ?? '';
        profileImage.value = data['profileImage'] ?? '';
        accountType.value = data['accountType'] ?? 'public';

        // Ensure lists are updated properly
        followers.value = List<String>.from(data['followers'] ?? []);
        following.value = List<String>.from(data['following'] ?? []);
        posts.value = data['posts'] ?? 0;
        highlights.value = List<String>.from(data['highlights'] ?? []);
      }
    });
  }
}
