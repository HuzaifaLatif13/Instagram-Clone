import 'dart:convert';
import 'dart:typed_data';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_insta/screens/post/post_detail_screen.dart';

import '../../controllers/auth_controller.dart';
import '../../models/account.dart';
import '../../models/post.dart';
import '../../widgets/build_stat.dart';
import '../chat/chat_screen.dart';
import 'followers_followings_screen.dart';

class AccountDetailScreen extends StatefulWidget {
  final Account user;

  AccountDetailScreen({super.key, required this.user}) {
    user.listenToUserUpdates();
  }

  @override
  State<AccountDetailScreen> createState() => _AccountDetailScreenState();
}

class _AccountDetailScreenState extends State<AccountDetailScreen> {
  Account account = AuthController.instance.currentUser.value!;

  @override
  Widget build(BuildContext context) {
    return Obx(() => Scaffold(
          appBar: AppBar(
            title: Text(widget.user.username.value,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: 10),
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.white70,
                  backgroundImage: CachedNetworkImageProvider(
                      widget.user.profileImage.toString()),
                ),
                Text(widget.user.name.value,
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text(widget.user.bio.value,
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                    textAlign: TextAlign.center),
                _buildStatsRow(),
                _buildFollowMessageSection(),
                _buildHighlights(widget.user.highlights),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Divider(color: Colors.white54),
                ),
                SizedBox(height: 10),
                _buildUserPosts(widget.user),
              ],
            ),
          ),
        ));
  }

  Widget _buildFollowMessageSection() {
    String targetUserId = widget.user.uid.value;
    RxBool isFollowing = RxBool(account.following.contains(targetUserId));
    RxBool isFollowingBack = RxBool(account.followers
        .contains(targetUserId)); // Target user follows current user
    RxBool isLoading = false.obs;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Follow/Unfollow/Follow Back Button
          Expanded(
            child: Obx(() => ElevatedButton(
                  onPressed: isLoading.value
                      ? null
                      : () async {
                          isLoading.value = true;

                          bool previousState = isFollowing.value;
                          isFollowing.value = !isFollowing.value;

                          try {
                            if (isFollowing.value) {
                              await account.followUser(targetUserId);
                              isFollowingBack.value =
                                  false; // Once followed, remove "Follow Back"
                            } else {
                              await account.unfollowUser(targetUserId);
                            }
                          } catch (e) {
                            // Revert if API call fails
                            isFollowing.value = previousState;
                          } finally {
                            isLoading.value = false;
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        isFollowing.value ? Colors.grey : Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: isLoading.value
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          isFollowing.value
                              ? "Following" // Show "Following" when clicked
                              : isFollowingBack.value
                                  ? "Follow Back" // Show "Follow Back" if the other user is following
                                  : "Follow", // Default follow state
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                )),
          ),
          SizedBox(width: 10), // Add spacing between buttons

          // Message Button
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                Get.to(() => ChatScreen(
                      currentUser: account,
                      targetUser: widget.user,
                    ));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[800],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                "Message",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
          SizedBox(width: 10), // Add spacing before the icon button

          // More Options Button
          IconButton(
            onPressed: () {
              // Handle more options
            },
            icon: Icon(Icons.person_add, color: Colors.white),
            splashRadius: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildUserPosts(user) {
    String currentUserId = account.uid.value;
    bool isPrivateAccount = user.accountType.value == 'private';
    bool isFollowing = user.following.contains(currentUserId);

    if (isPrivateAccount && !isFollowing) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(color: Colors.red)),
                child: Icon(Icons.lock, size: 50, color: Colors.red)),
            SizedBox(height: 10),
            Text(
              'Add user to see posts',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    } else {
      return StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('posts')
            .doc(user.uid.value) // Access .value here
            .collection('user-posts')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Padding(
              padding: EdgeInsets.only(top: 50),
              child: Center(
                child: Text(
                  "No posts available",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            );
          }

          List<Map<String, dynamic>> allImages =
              snapshot.data!.docs.expand((doc) {
            return (doc['postImages'] as List<dynamic>).map((img) => {
                  'postId': doc.id,
                  'postImage': img, // This should be a URL string
                });
          }).toList();

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 8),
              itemCount: allImages.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 4,
                mainAxisSpacing: 4,
              ),
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () async {
                    String postId = allImages[index]['postId'];
                    print('Post ID: $postId');

                    try {
                      DocumentSnapshot postDoc = await FirebaseFirestore
                          .instance
                          .collection('posts')
                          .doc(widget.user.uid.value)
                          .collection('user-posts')
                          .doc(postId)
                          .get();

                      if (postDoc.exists) {
                        Post post = Post.fromFirestore(postDoc);
                        Get.to(() => PostDetailScreen(post: post));
                      } else {
                        print("⚠️ Post not found!");
                      }
                    } catch (e) {
                      print("❌ Error fetching post: $e");
                    }
                  },
                  child: ClipRRect(
                    borderRadius:
                        BorderRadius.circular(8), // Smooth rounded corners
                    child: Image.network(
                      allImages[index]['postImage'], // Use URL here
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const Center(child: CircularProgressIndicator());
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.broken_image,
                            color: Colors.grey);
                      },
                    ),
                  ),
                );
              },
            ),
          );
        },
      );
    }
  }

  /// **🔹 Profile Image Handling (Base64)**

  /// **🔹 Stats Row (Posts, Followers, Following)**
  Widget _buildStatsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Buildstat(label: "Posts", count: widget.user.posts.value),
        GestureDetector(
          onTap: () => Get.to(() =>
              FollowersFollowingsScreen(user: widget.user, initialTabIndex: 0)),
          child: Buildstat(
              count: widget.user.followers.length.toInt(), label: "Followers"),
        ),
        GestureDetector(
            onTap: () => Get.to(() => FollowersFollowingsScreen(
                user: widget.user, initialTabIndex: 1)),
            child: Buildstat(
                count: widget.user.following.length.toInt(),
                label: "Following")),
      ],
    );
  }

  /// **🔹 Highlights Handling (Base64)**
  Widget _buildHighlights(RxList<String> highlights) {
    if (highlights.isEmpty) return Container();
    return SizedBox(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: highlights.length,
        itemBuilder: (context, index) {
          Uint8List? imageBytes = _decodeBase64(highlights[index]);
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 5),
            child: CircleAvatar(
              radius: 30,
              backgroundImage: imageBytes != null
                  ? MemoryImage(imageBytes)
                  : AssetImage('assets/default_highlight.png') as ImageProvider,
            ),
          );
        },
      ),
    );
  }

  /// **🔹 Base64 Decoder with Error Handling**
  Uint8List? _decodeBase64(String base64String) {
    try {
      // Remove data URI prefix if present
      if (base64String.startsWith("data:image")) {
        base64String = base64String.split(",")[1];
      }
      return base64Decode(base64String);
    } catch (e) {
      print("Base64 Decode Error: $e");
      return null; // Return null if decoding fails
    }
  }
}
