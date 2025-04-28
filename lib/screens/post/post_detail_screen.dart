import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:my_insta/models/account.dart';
import 'package:my_insta/screens/home/main_screen.dart';
import '../../controllers/post_controller.dart';
import '../../models/post.dart';
import '../account/account_details_screen.dart';
import '../account/account_screen.dart';

class PostDetailController extends GetxController {
  final Post post;
  final TextEditingController commentController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final isLiked = false.obs;
  final likeCount = 0.obs;
  final comments = <Map<String, dynamic>>[].obs;

  PostDetailController(this.post);

  @override
  void onInit() {
    super.onInit();
    _initializeLikeStatus();
    _fetchComments();
  }

  @override
  void dispose() {
    if (Get.isRegistered<PostDetailController>()) {
      Get.delete<PostDetailController>();
    }
    super.dispose();
  }

  String get currentUserId => _auth.currentUser!.uid;

  void _initializeLikeStatus() {
    isLiked.value = post.likedBy.contains(currentUserId);
    likeCount.value = post.likes;
  }

  Future<Account> fetchUser() async {
    Account user;
    DocumentSnapshot userSnapshot =
        await _firestore.collection('users').doc(post.userId).get();
    return user = Account.fromDocument(userSnapshot);
  }

  void toggleLike() async {
    if (!Get.isRegistered<PostDetailController>()) return;

    DocumentReference postRef = _firestore
        .collection('posts')
        .doc(post.userId)
        .collection('user-posts')
        .doc(post.postId);

    if (isLiked.value) {
      await postRef.update({
        'likes': FieldValue.increment(-1),
        'likedBy': FieldValue.arrayRemove([currentUserId]),
      });
      isLiked.value = false;
      likeCount.value--;
    } else {
      await postRef.update({
        'likes': FieldValue.increment(1),
        'likedBy': FieldValue.arrayUnion([currentUserId]),
      });
      isLiked.value = true;
      likeCount.value++;
    }
  }

  void _fetchComments() async {
    DocumentSnapshot postSnapshot = await _firestore
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

  void addComment() async {
    String commentText = commentController.text.trim();
    if (commentText.isEmpty) return;

    DocumentSnapshot userSnapshot =
        await _firestore.collection('users').doc(currentUserId).get();

    String username = userSnapshot.get('name') ?? 'Unknown';
    String userProfileImage = userSnapshot.get('profileImage') ?? '';

    final comment = {
      'username': username,
      'userProfileImage': userProfileImage,
      'text': commentText,
      'timestamp': DateTime.now(),
    };

    DocumentReference postRef = _firestore
        .collection('posts')
        .doc(post.userId)
        .collection('user-posts')
        .doc(post.postId);

    await postRef.update({
      'comments': FieldValue.arrayUnion([comment])
    });

    commentController.clear();

    // Refresh comments from Firestore
    _fetchComments();
  }
}

class PostDetailScreen extends StatelessWidget {
  final Post post;
  PostDetailScreen({Key? key, required this.post}) : super(key: key);
  final PostController postController = Get.find<PostController>();

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PostDetailController(post));

    return Scaffold(
      resizeToAvoidBottomInset:
          false, // Prevents overflow when keyboard appears
      appBar: AppBar(title: Text('Post Details')),
      body: GestureDetector(
        onTap: () => FocusScope.of(context)
            .unfocus(), // Dismiss keyboard when tapping outside
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// User Info Row
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.grey[700],
                            backgroundImage: CachedNetworkImageProvider(
                                post.userProfileImage),
                          ),
                          SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(post.username,
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              Text(post.location,
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 12)),
                            ],
                          ),
                          Spacer(),
                          PopupMenuButton<String>(
                            color: Colors.black54,
                            icon: Icon(Icons.more_vert, color: Colors.white),
                            onSelected: (value) async {
                              if (value == 'profile') {
                                if (post.userId ==
                                    FirebaseAuth.instance.currentUser!.uid) {
                                } else {
                                  Get.to(AccountDetailScreen(
                                    user: await controller.fetchUser(),
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
                                        await postController.deletePost(post);
                                    Get.back();
                                    if (res) {
                                      Get.snackbar("Success",
                                          "Post deleted successfully!");
                                    } else {
                                      Get.snackbar(
                                          "Error", "Failed to delete post!");
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
                                  post.userId)
                                PopupMenuItem(
                                  value: 'delete',
                                  child: ListTile(
                                    leading:
                                        Icon(Icons.delete, color: Colors.red),
                                    title: Text('Delete',
                                        style: TextStyle(color: Colors.red)),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    /// Post Image
                    SizedBox(
                      height: MediaQuery.of(context)
                          .size
                          .width, // Ensure square shape
                      width: MediaQuery.of(context).size.width,
                      child: PageView.builder(
                        itemCount: post.postImages.length,
                        itemBuilder: (context, index) {
                          return CachedNetworkImage(
                            imageUrl: post.postImages[index],
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                            progressIndicatorBuilder:
                                (context, url, downloadProgress) => Center(
                                    child: CircularProgressIndicator(
                                        value: downloadProgress.progress)),
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

                    /// Like, Comment, Share, Save Icons
                    Obx(() => Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              IconButton(
                                icon: Icon(
                                  controller.isLiked.value
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color: controller.isLiked.value
                                      ? Colors.red
                                      : Colors.white,
                                ),
                                onPressed: controller.toggleLike,
                              ),
                              IconButton(
                                  icon: Icon(Icons.textsms_outlined),
                                  onPressed: () {}),
                              IconButton(
                                  icon: Icon(Icons.send), onPressed: () {}),
                              Spacer(),
                              IconButton(
                                  icon: Icon(Icons.bookmark_border),
                                  onPressed: () {}),
                            ],
                          ),
                        )),

                    /// Like Count
                    Obx(() => Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          child: Text(
                              "Liked by ${controller.likeCount.value} people",
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        )),

                    /// Post Caption
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10.0, vertical: 5),
                      child: Text("${post.username} ${post.caption}",
                          style: TextStyle()),
                    ),

                    /// Comments List
                    Obx(() => ListView.builder(
                          shrinkWrap:
                              true, // Important: prevents infinite height error
                          physics:
                              NeverScrollableScrollPhysics(), // Disables ListView scrolling
                          itemCount: controller.comments.length,
                          itemBuilder: (context, index) {
                            final comment = controller.comments[index];
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.grey[700],
                                backgroundImage: CachedNetworkImageProvider(
                                    comment['userProfileImage']),
                              ),
                              title: Text(comment['username'],
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text(comment['text']),
                            );
                          },
                        )),
                  ],
                ),
              ),
            ),

            /// Comment Input Field (Moves up with Keyboard)
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10.0, vertical: 20),
              child: Container(
                padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: TextField(
                        controller: controller.commentController,
                        decoration: InputDecoration(
                          hintText: 'Write a comment...',
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.white),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide:
                                BorderSide(color: Colors.blue, width: 2),
                          ),
                          hintStyle: TextStyle(color: Colors.grey[400]),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.send),
                      onPressed: () => controller.addComment(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// class PostDetailScreen extends StatelessWidget {
//   final Post post;
//   PostDetailScreen({Key? key, required this.post}) : super(key: key);
//   final PostController postController = Get.find<PostController>();
//
//   @override
//   Widget build(BuildContext context) {
//     final controller = Get.put(PostDetailController(post));
//
//     return Scaffold(
//       appBar: AppBar(title: Text('Post Details')),
//       body: SingleChildScrollView(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: Row(
//                 children: [
//                   CircleAvatar(
//                     backgroundColor: Colors.grey[700],
//                     backgroundImage:
//                         CachedNetworkImageProvider(post.userProfileImage),
//                   ),
//                   SizedBox(width: 10),
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(post.username,
//                           style: TextStyle(fontWeight: FontWeight.bold)),
//                       Text(post.location,
//                           style: TextStyle(color: Colors.grey, fontSize: 12)),
//                     ],
//                   ),
//                   Spacer(),
//                   PopupMenuButton<String>(
//                     color: Colors.black54,
//                     icon: Icon(Icons.more_vert, color: Colors.white),
//                     onSelected: (value) {
//                       if (value == 'profile') {
//                         Get.toNamed('/profile', arguments: post.userId);
//                       } else if (value == 'delete') {
//                         Get.defaultDialog(
//                           title: "Delete Post",
//                           middleText:
//                               "Are you sure you want to delete this post?",
//                           textConfirm: "Yes",
//                           textCancel: "No",
//                           confirmTextColor: Colors.white,
//                           onConfirm: () async {
//                             bool res = await postController.deletePost(post);
//                             Get.back();
//                             if (res) {
//                               Get.snackbar(
//                                   "Success", "Post deleted successfully!");
//                             } else {
//                               Get.snackbar("Error", "Failed to delete post!");
//                             }
//                           },
//                         );
//                       }
//                     },
//                     itemBuilder: (context) => [
//                       PopupMenuItem(
//                         value: 'profile',
//                         child: ListTile(
//                           leading: Icon(Icons.person),
//                           title: Text('View Profile'),
//                         ),
//                       ),
//                       if (FirebaseAuth.instance.currentUser!.uid == post.userId)
//                         PopupMenuItem(
//                           value: 'delete',
//                           child: ListTile(
//                             leading: Icon(Icons.delete, color: Colors.red),
//                             title: Text('Delete',
//                                 style: TextStyle(color: Colors.red)),
//                           ),
//                         ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//             SizedBox(
//               height: MediaQuery.of(context).size.width, // Ensure square shape
//               width: MediaQuery.of(context).size.width,
//               child: PageView.builder(
//                 itemCount: post.postImages.length,
//                 itemBuilder: (context, index) {
//                   return CachedNetworkImage(
//                     imageUrl: post.postImages[index],
//                     fit: BoxFit.cover,
//                     width: double.infinity,
//                     height:
//                         double.infinity, // Use full size within the container
//                     progressIndicatorBuilder:
//                         (context, url, downloadProgress) => Center(
//                       child: CircularProgressIndicator(
//                         value: downloadProgress
//                             .progress, // Shows download progress
//                         strokeWidth: 3, // Adjust thickness
//                         color: Colors.blue, // Customize color if needed
//                       ),
//                     ),
//                     errorWidget: (context, url, error) => Image.asset(
//                       'assets/images/f3.png',
//                       fit: BoxFit.cover,
//                       width: double.infinity,
//                       height: double.infinity,
//                     ),
//                   );
//                 },
//               ),
//             ),
//             Obx(() => Padding(
//                   padding: const EdgeInsets.all(8.0),
//                   child: Row(
//                     children: [
//                       IconButton(
//                         icon: Icon(
//                           controller.isLiked.value
//                               ? Icons.favorite
//                               : Icons.favorite_border,
//                           color: controller.isLiked.value
//                               ? Colors.red
//                               : Colors.white,
//                         ),
//                         onPressed: controller.toggleLike,
//                       ),
//                       IconButton(
//                           icon: Icon(Icons.textsms_outlined), onPressed: () {}),
//                       IconButton(icon: Icon(Icons.send), onPressed: () {}),
//                       Spacer(),
//                       IconButton(
//                           icon: Icon(Icons.bookmark_border), onPressed: () {}),
//                     ],
//                   ),
//                 )),
//             Obx(() => Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 10.0),
//                   child: Text("Liked by ${controller.likeCount.value} people",
//                       style: TextStyle(fontWeight: FontWeight.bold)),
//                 )),
//             Padding(
//               padding:
//                   const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5),
//               child:
//                   Text("${post.username} ${post.caption}", style: TextStyle()),
//             ),
//             Expanded(
//               child: Obx(() => ListView.builder(
//                     itemCount: controller.comments.length,
//                     itemBuilder: (context, index) {
//                       final comment = controller.comments[index];
//                       return ListTile(
//                         leading: CircleAvatar(
//                           backgroundColor: Colors.grey[700],
//                           backgroundImage: CachedNetworkImageProvider(
//                               comment['userProfileImage']),
//                         ),
//                         title: Text(comment['username'],
//                             style: TextStyle(fontWeight: FontWeight.bold)),
//                         subtitle: Text(comment['text']),
//                       );
//                     },
//                   )),
//             ),
//             Padding(
//               padding:
//                   const EdgeInsets.symmetric(horizontal: 10.0, vertical: 20),
//               child: Container(
//                 padding: EdgeInsets.only(
//                     bottom: MediaQuery.of(context).viewInsets.bottom),
//                 child: Row(
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: [
//                     Expanded(
//                       child: TextField(
//                         controller: controller.commentController,
//                         decoration: InputDecoration(
//                           hintText: 'Write a comment...',
//                           enabledBorder: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(8),
//                             borderSide: BorderSide(color: Colors.white),
//                           ),
//                           focusedBorder: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(8),
//                             borderSide:
//                                 BorderSide(color: Colors.blue, width: 2),
//                           ),
//                           hintStyle: TextStyle(color: Colors.grey[400]),
//                         ),
//                       ),
//                     ),
//                     IconButton(
//                       icon: Icon(Icons.send),
//                       onPressed: () => controller.addComment(),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
