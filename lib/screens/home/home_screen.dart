import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_insta/screens/story/story_view_screen.dart';
import 'package:shimmer/shimmer.dart';
import 'package:my_insta/widgets/build_post.dart';
import '../../controllers/post_controller.dart';
import '../../controllers/story_controller.dart';
import '../../models/account.dart';
import '../../models/story.dart';
import '../chat/chat_user_screen.dart';
import '../post/media_selection_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PostController postController = Get.put(PostController());
  final StoryController storyController = Get.put(StoryController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        toolbarHeight: 65,
        titleSpacing: 10,
        backgroundColor: Colors.black,
        elevation: 0,
        title: Image.asset('assets/images/app_title.png', height: 40),
        actions: [
          IconButton(
              icon: Icon(Icons.favorite_border, size: 30), onPressed: () {}),
          IconButton(
            icon: Icon(Icons.message, size: 30),
            onPressed: () {
              Get.to(() => ChatUsersScreen());
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        color: Colors.blue,
        onRefresh: () {
          postController.fetchPosts();
          return storyController.fetchAllStories();
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [
                  GestureDetector(
                    onTap: () {
                      Get.to(() => MediaSelectionScreen(screen: 'Story'));
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8.0, vertical: 5),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircleAvatar(
                            radius: 35,
                            backgroundColor: Colors.blue,
                            child: CircleAvatar(
                              radius: 33,
                              backgroundImage: NetworkImage(
                                  'https://img.freepik.com/premium-vector/default-avatar-profile-icon-social-media-user-image-gray-avatar-icon-blank-profile-silhouette-vector-illustration_561158-3383.jpg'),
                            ),
                          ),
                          SizedBox(height: 5),
                          Text("Add",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 12)),
                        ],
                      ),
                    ),
                  ),
                  _buildStoryList(),
                ],
              ),
            ),
            Expanded(
              child: Obx(() {
                return postController.isLoading.value
                    ? _buildShimmerList()
                    : _buildPostList();
              }),
            ),
          ],
        ),
      ),
    );
  }

  /// 📌 **Story Section with Grouping**
  Widget _buildStoryList() {
    return SizedBox(
      height: 110,
      child: Obx(() {
        if (storyController.stories.isEmpty) {
          return Center(
              child: Text("No stories yet, Let add your\'s",
                  style: TextStyle(color: Colors.white)));
        }

        // Group stories by user
        Map<String, List<Story>> groupedStories = {};
        for (var story in storyController.stories) {
          groupedStories.putIfAbsent(story.userId, () => []).add(story);
        }

        return SizedBox(
          width: 400,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: groupedStories.entries
                .map((entry) => _buildStoryItem(entry.key, entry.value))
                .toList(),
          ),
        );
      }),
    );
  }

  /// 📌 **Grouped Story Item**
  Widget _buildStoryItem(String userId, List<Story> stories) {
    // Find the user associated with this story
    Account? user =
        storyController.users.firstWhereOrNull((u) => u.uid == userId);

    if (user == null) {
      return SizedBox(); // Return an empty widget if no user is found
    }

    return GestureDetector(
      onTap: () {
        Get.to(() => StoryViewScreen(
              stories: stories,
            ));
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 5),
        child: Column(
          children: [
            CircleAvatar(
              radius: 35,
              backgroundColor: Colors.blue,
              child: CircleAvatar(
                radius: 33,
                backgroundColor: Colors.grey[700],
                backgroundImage: CachedNetworkImageProvider(
                  stories.first.mediaUrl.toString(),
                ),
              ),
            ),
            const SizedBox(height: 5), // Add spacing
            Text(
              user.name.toString(), // Show user's name
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  /// 📌 **Shimmer Effect for Posts**
  Widget _buildShimmerList() {
    return ListView.builder(
      itemCount: 3,
      itemBuilder: (context, index) => _buildShimmerPost(index),
    );
  }

  /// 📌 **Actual Post List**
  Widget _buildPostList() {
    if (postController.posts.isEmpty) {
      return Center(
          child: Text('No posts available',
              style: TextStyle(color: Colors.white)));
    }

    return Obx(() {
      return ListView.builder(
        itemCount: postController.posts.length,
        itemBuilder: (context, index) {
          final post = postController.posts[index];
          return BuildPost(post: post);
        },
      );
    });
  }

  /// 📌 **Shimmer Post Placeholder**
  Widget _buildShimmerPost(int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[800]!,
        highlightColor: Colors.grey[500]!,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(radius: 25, backgroundColor: Colors.grey[700]),
                SizedBox(width: 10),
                Container(
                  width: 150,
                  height: 15,
                  decoration: BoxDecoration(
                    color: Colors.grey[700],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Container(
              height: index % 3 == 0 ? 300 : 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[700],
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
