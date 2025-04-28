import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../models/message.dart';

class ChatController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  RxList<Message> messages = <Message>[].obs;
  RxBool isLoading = true.obs; // Flag to track loading state

  // Load Messages with Firestore Listener
  void loadMessages(String currentUserId, String targetUserId) {
    _firestore
        .collection("chat")
        .doc(currentUserId)
        .collection("user-chats")
        .doc(targetUserId)
        .collection("messages")
        .orderBy("timestamp", descending: false)
        .snapshots()
        .listen((snapshot) {
      messages.value =
          snapshot.docs.map((doc) => Message.fromMap(doc.data())).toList();
      //duration
      Future.delayed(Duration(milliseconds: 400), () {
        isLoading.value = false;
      });
    });
  }

  // Send Message
  Future<void> sendMessage(
      String currentUserId, String targetUserId, String text) async {
    if (text.trim().isEmpty) return;

    Message message = Message(
      senderId: currentUserId,
      receiverId: targetUserId,
      text: text,
      timestamp: Timestamp.now(),
    );

    // Sender's Chat Collection
    await _firestore
        .collection("chat")
        .doc(currentUserId)
        .collection("user-chats")
        .doc(targetUserId)
        .collection("messages")
        .add(message.toMap());

    // Receiver's Chat Collection (Mirror Chat)
    await _firestore
        .collection("chat")
        .doc(targetUserId)
        .collection("user-chats")
        .doc(currentUserId)
        .collection("messages")
        .add(message.toMap());

    // **Add Users to chats-lists Collection**
    await _updateChatList(currentUserId, targetUserId);
    await _updateChatList(targetUserId, currentUserId);
  }

  /// **Helper Function to Add User to Chat List**
  Future<void> _updateChatList(String userId, String targetUserId) async {
    DocumentReference chatListRef =
        _firestore.collection("chats-lists").doc(userId);

    DocumentSnapshot chatListSnapshot = await chatListRef.get();

    if (chatListSnapshot.exists) {
      // Cast data() as Map<String, dynamic> before accessing fields
      Map<String, dynamic> data =
          chatListSnapshot.data() as Map<String, dynamic>;

      List<dynamic> users = data["users"] ?? [];

      if (!users.contains(targetUserId)) {
        await chatListRef.update({
          "users": FieldValue.arrayUnion([targetUserId]),
        });
      }
    } else {
      // If the document doesn't exist, create it with the target user ID
      await chatListRef.set({
        "users": [targetUserId],
      });
    }
  }
}
