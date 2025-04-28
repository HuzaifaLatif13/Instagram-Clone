import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:my_insta/models/account.dart';
import '../models/story.dart';
import '../services/cloudinary_service.dart';

class StoryController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  var isLoading = true.obs; // Observable boolean
  var stories = <Story>[].obs; // Observable list of stories
  var users = <Account>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchAllStories();
  }

  /// Fetch all stories from Firestore
  Future<void> fetchAllStories() async {
    try {
      isLoading.value = true;

      QuerySnapshot snapshot =
          await _firestore.collectionGroup("user-stories").get();

      List<Story> fetchedStories = [];
      List<Account> fetchedUsers = [];

      for (var doc in snapshot.docs) {
        Story story = Story.fromMap(doc.data() as Map<String, dynamic>);
        DateTime storyTimestamp =
            story.timestamp.toDate(); // Convert to DateTime

        // Check if story is older than 24 hours
        if (DateTime.now().difference(storyTimestamp).inHours >= 24) {
          await _firestore.collection("user-stories").doc(doc.id).delete();
        } else {
          fetchedStories.add(story);

          // Fetch user details
          DocumentSnapshot userSnapshot =
              await _firestore.collection("users").doc(story.userId).get();

          if (userSnapshot.exists) {
            fetchedUsers.add(
                Account.fromMap(userSnapshot.data() as Map<String, dynamic>));
          }
        }
      }

      // Update the observable lists
      stories.value = fetchedStories;
      users.value = fetchedUsers;
      stories.refresh();
      users.refresh();
    } catch (e) {
      print("Error fetching stories: $e");
    } finally {
      isLoading.value = false;
    }
  }

  /// Upload media to Cloudinary and store story in Firestore
  Future<void> addStory(String userId, File mediaFile, String mediaType,
      int duration, String caption) async {
    isLoading.value = true;
    String? mediaUrl = await CloudinaryService.uploadImage(mediaFile);

    if (mediaUrl == null) {
      print("Failed to upload media");
      return;
    }

    String storyId = _firestore
        .collection("stories")
        .doc(userId)
        .collection("user-stories")
        .doc()
        .id;

    Story newStory = Story(
      storyId: storyId,
      userId: userId,
      mediaUrl: mediaUrl,
      mediaType: mediaType,
      duration: duration,
      timestamp: Timestamp.now(),
      seen: [],
      caption: caption, // Initially, no one has seen the story
    );

    await _firestore
        .collection("stories")
        .doc(userId)
        .collection("user-stories")
        .doc(storyId)
        .set(newStory.toMap());

    print("Story uploaded successfully!");
    isLoading.value = false;
  }

  /// Mark a story as seen by a user
  Future<void> markStoryAsSeen(
      String storyOwnerId, String storyId, String viewerUserId) async {
    DocumentReference storyRef = _firestore
        .collection("stories")
        .doc(storyOwnerId)
        .collection("user-stories")
        .doc(storyId);

    await storyRef.update({
      "seen": FieldValue.arrayUnion([viewerUserId]) // Add viewer to seen list
    });

    print("Story marked as seen by $viewerUserId");
  }

  /// Fetch all stories of a specific user
  Future<List<Story>> fetchUserStories(String userId) async {
    QuerySnapshot snapshot = await _firestore
        .collection("stories")
        .doc(userId)
        .collection("user-stories")
        .orderBy("timestamp", descending: true)
        .get();

    return snapshot.docs
        .map((doc) => Story.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  /// Delete a story
  Future<void> deleteStory(String userId, String storyId) async {
    await _firestore
        .collection("stories")
        .doc(userId)
        .collection("user-stories")
        .doc(storyId)
        .delete();

    print("Story deleted successfully!");
  }
}
