import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/post.dart';
import '../screens/account/account_details_screen.dart';
import '../screens/account/account_screen.dart';
import '../screens/home/main_screen.dart';
import '../screens/post/post_detail_screen.dart';
import '../controllers/post_controller.dart'; // Import your PostController

class BuildPost extends StatefulWidget {
  const BuildPost({super.key, required this.post});
  final Post post;

  @override
  State<BuildPost> createState() => _BuildPostState();
}

class _BuildPostState extends State<BuildPost> {
  @override
  Widget build(BuildContext context) {
    final PostController postController = Get.find<PostController>();

    return Obx(() {
      // Check if the post is in the posts list and retrieve the updated version
      final currentPost = postController.posts.firstWhere(
          (p) => p.postId == widget.post.postId,
          orElse: () => widget.post);

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.grey[700],
                  backgroundImage: CachedNetworkImageProvider(
                    currentPost.userProfileImage,
                  ),
                  radius: 20,
                ),
                SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(currentPost.username,
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold)),
                    Text(currentPost.location,
                        style: TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
                Spacer(),
                PopupMenuButton<String>(
                  color: Colors.black54,
                  icon: Icon(Icons.more_vert, color: Colors.white),
                  onSelected: (value) async {
                    if (value == 'profile') {
                      if (currentPost.userId ==
                          FirebaseAuth.instance.currentUser!.uid) {
                      } else {
                        Get.to(AccountDetailScreen(
                          user: await postController.fetchUser(currentPost),
                        ));
                      }
                    } else if (value == 'delete') {
                      Get.defaultDialog(
                        title: "Delete Post",
                        middleText:
                            "Are you sure you want to delete this post?",
                        textConfirm: "Yes",
                        textCancel: "No",
                        confirmTextColor: Colors.white,
                        onConfirm: () async {
                          bool res =
                              await postController.deletePost(currentPost);
                          Get.back();
                          if (res) {
                            Get.snackbar(
                                "Success", "Post deleted successfully!");
                          } else {
                            Get.snackbar("Error", "Failed to delete post!");
                          }
                        },
                      );
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'profile',
                      child: ListTile(
                        leading: Icon(Icons.person),
                        title: Text('View Profile'),
                      ),
                    ),
                    if (FirebaseAuth.instance.currentUser!.uid ==
                        currentPost.userId)
                      PopupMenuItem(
                        value: 'delete',
                        child: ListTile(
                          leading: Icon(Icons.delete, color: Colors.red),
                          title: Text('Delete',
                              style: TextStyle(color: Colors.red)),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          GestureDetector(
              onTap: () {
                Get.to(() => PostDetailScreen(post: currentPost));
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  height:
                      MediaQuery.of(context).size.width, // Ensure square shape
                  width: MediaQuery.of(context).size.width,
                  child: PageView.builder(
                    itemCount: currentPost.postImages.length,
                    itemBuilder: (context, index) {
                      return CachedNetworkImage(
                        imageUrl: currentPost.postImages[index],
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double
                            .infinity, // Use full size within the container
                        progressIndicatorBuilder:
                            (context, url, downloadProgress) => Center(
                          child: CircularProgressIndicator(
                            value: downloadProgress
                                .progress, // Shows download progress
                            strokeWidth: 3, // Adjust thickness
                            color: Colors.blue, // Customize color if needed
                          ),
                        ),
                        errorWidget: (context, url, error) => Image.asset(
                          'assets/images/f3.png',
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                        ),
                      );
                    },
                  ),
                ),
              )),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        currentPost.likedBy.contains(
                                FirebaseAuth.instance.currentUser!.uid)
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: currentPost.likedBy.contains(
                                FirebaseAuth.instance.currentUser!.uid)
                            ? Colors.red
                            : Colors.white,
                      ),
                      onPressed: () async {
                        await postController.toggleLike(currentPost);
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.textsms_outlined, color: Colors.white),
                      onPressed: () {
                        Get.to(() => PostDetailScreen(post: currentPost));
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.send, color: Colors.white),
                      onPressed: () {},
                    ),
                  ],
                ),
                IconButton(
                    icon: Icon(Icons.bookmark_border, color: Colors.white),
                    onPressed: () {}),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Text(
              currentPost.likedBy.isNotEmpty
                  ? "Liked by ${currentPost.likedBy.length} people"
                  : "Like",
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5),
            child: Text("${currentPost.username} ${currentPost.caption}",
                style: TextStyle(color: Colors.white)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5),
            child: GestureDetector(
              onTap: () {},
              child: Text("View all ${currentPost.comments.length} comments",
                  style: TextStyle(color: Colors.grey)),
            ),
          ),
        ],
      );
    });
  }
}
