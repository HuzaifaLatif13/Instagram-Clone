import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_insta/screens/post/post_detail_screen.dart';
import 'package:my_insta/widgets/build_stat.dart';
import '../../controllers/auth_controller.dart';
import '../../models/account.dart';
import '../../models/post.dart';
import 'edit_account_screen.dart';
import 'followers_followings_screen.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final AuthController controller = Get.put(AuthController());

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final user = controller.currentUser.value;

      if (user == null) {
        return _buildNoUserScreen();
      }

      return Scaffold(
        backgroundColor: Colors.black,
        appBar: _buildAppBar(user.username.value), // Access .value here
        body: SingleChildScrollView(
          child: Column(
            children: [
              _buildProfileSection(user),
              Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: Text(
                      user.accountType.value.toUpperCase(),
                      style: TextStyle(
                          color: user.accountType.value == 'public'
                              ? Colors.blue
                              : Colors.red,
                          fontSize: 12),
                    ),
                  )),
              _buildBioSection(user),
              _buildEditProfileButton(user),
              SizedBox(
                height: 10,
              ),
              _buildHighlightsSection(user),
              SizedBox(
                height: 10,
              ),
              _buildTabBar(),
              _buildUserPosts(user),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildNoUserScreen() {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () => controller.logout(),
            icon: const Icon(Icons.menu, color: Colors.white),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: const Center(
        child: Text("No User Data Available",
            style: TextStyle(color: Colors.white)),
      ),
    );
  }

  AppBar _buildAppBar(String username) {
    return AppBar(
      backgroundColor: Colors.black,
      elevation: 0,
      title: Text(username, style: const TextStyle(color: Colors.white)),
      actions: [
        IconButton(
          onPressed: () => controller.logout(),
          icon: const Icon(Icons.menu, color: Colors.white),
        ),
        const SizedBox(width: 16),
      ],
    );
  }

  Widget _buildProfileSection(Account user) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: Colors.grey[700],
            backgroundImage:
                CachedNetworkImageProvider(user.profileImage.toString()),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Buildstat(count: user.posts.value, label: "Posts"),
                GestureDetector(
                  onTap: () => Get.to(() => FollowersFollowingsScreen(
                      user: user, initialTabIndex: 0)),
                  child: Buildstat(
                      count: user.followers.length.toInt(), label: "Followers"),
                ),
                GestureDetector(
                    onTap: () => Get.to(() => FollowersFollowingsScreen(
                        user: user, initialTabIndex: 1)),
                    child: Buildstat(
                        count: user.following.length.toInt(),
                        label: "Following")),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBioSection(user) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SizedBox(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(user.name.value, // Access .value here
                style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(user.bio.value, // Access .value here
                style: const TextStyle(color: Colors.white70)),
          ],
        ),
      ),
    );
  }

  Widget _buildEditProfileButton(user) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey[900],
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          onPressed: () => Get.to(() => EditAccountScreen(user: user)),
          child:
              const Text("Edit Profile", style: TextStyle(color: Colors.white)),
        ),
      ),
    );
  }

  Widget _buildHighlightsSection(user) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _buildHighlightCircle("New", null),
          ...user.highlights.map((image) =>
              _buildHighlightCircle("", image.value)), // Access .value here
        ],
      ),
    );
  }

  Widget _buildHighlightCircle(String label, String? image) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: Column(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.grey[700],
            backgroundImage: image != null ? AssetImage(image) : null,
            child: image == null
                ? const Icon(Icons.add, color: Colors.white)
                : null,
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.grid_on, color: Colors.white),
          SizedBox(width: 20),
          Icon(Icons.assignment_ind, color: Colors.grey),
        ],
      ),
    );
  }

  Widget _buildUserPosts(user) {
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
                    DocumentSnapshot postDoc = await FirebaseFirestore.instance
                        .collection('posts')
                        .doc(user.uid.value)
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
                      return const Icon(Icons.broken_image, color: Colors.grey);
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
