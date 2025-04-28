import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shimmer/shimmer.dart';
import '../../models/account.dart';
import 'chat_screen.dart';
import '../../controllers/auth_controller.dart';
import 'package:google_fonts/google_fonts.dart';

class ChatUsersScreen extends StatefulWidget {
  const ChatUsersScreen({super.key});

  @override
  State<ChatUsersScreen> createState() => _ChatUsersScreenState();
}

class _ChatUsersScreenState extends State<ChatUsersScreen> {
  final RxList<Account> users = RxList<Account>([]);
  final RxList<String> userNames = RxList<String>([]);
  final String currentUserId = FirebaseAuth.instance.currentUser!.uid;
  final RxBool _isLoading = true.obs;
  //firebase
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  Future<void> fetchChatUsers() async {
    DocumentReference chatListRef =
        _firestore.collection("chats-lists").doc(currentUserId);

    DocumentSnapshot chatListSnapshot = await chatListRef.get();

    if (chatListSnapshot.exists) {
      List<dynamic> users = chatListSnapshot.get("users") ?? [];

      // Update the reactive list
      userNames.assignAll(users.cast<String>());
    } else {
      // If no chat users exist, clear the list
      userNames.clear();
    }
  }

  Future<void> fetchUsers() async {
    await fetchChatUsers();
    List<Account> fetchedUsers = [];

    for (String uid in userNames) {
      try {
        DocumentSnapshot userSnapshot =
            await FirebaseFirestore.instance.collection('users').doc(uid).get();

        if (userSnapshot.exists) {
          Account user =
              Account.fromMap(userSnapshot.data() as Map<String, dynamic>);
          fetchedUsers.add(user);
        }
      } catch (e) {
        print('Error fetching user data: $e');
      }
    }

    // Delay before hiding shimmer for smoother transition
    await Future.delayed(Duration(milliseconds: 300));

    users.assignAll(fetchedUsers);
    _isLoading.value = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Chats",
          style: GoogleFonts.dancingScript(
              fontSize: 34, fontWeight: FontWeight.w700, color: Colors.white),
        ),
      ),
      body: Obx(() {
        return Padding(
          padding: const EdgeInsets.only(top: 10),
          child: AnimatedSwitcher(
            duration: Duration(milliseconds: 300), // Smooth fade transition
            child: _isLoading.value
                ? _buildShimmerList()
                : _buildUserList(), // Show shimmer or actual list
          ),
        );
      }),
    );
  }

  /// Shimmer Loading Effect
  Widget _buildShimmerList() {
    return ListView.builder(
      key: ValueKey(0), // Ensure AnimatedSwitcher recognizes state change
      itemCount: 6,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 16.0),
          child: Shimmer.fromColors(
            baseColor: Colors.grey[500]!,
            highlightColor: Colors.grey[100]!,
            period: Duration(seconds: 1), // ⬅️ Slows down shimmer animation
            child: Container(
              height: 80,
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundColor: Colors.grey[700],
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Container(
                      height: 20,
                      decoration: BoxDecoration(
                        color: Colors.grey[400],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  SizedBox(width: 30),
                  Container(
                    height: 20,
                    width: 20,
                    decoration: BoxDecoration(
                      color: Colors.grey[400],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// User List After Loading
  Widget _buildUserList() {
    return ListView.builder(
      key: ValueKey(1), // Ensure AnimatedSwitcher recognizes state change
      itemCount: users.length,
      itemBuilder: (context, index) {
        Account user = users[index];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
            title: Container(
              padding: EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.grey[700],
                    backgroundImage: CachedNetworkImageProvider(
                      user.profileImage.toString(),
                    ),
                    radius: 20,
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Text(user.name.value),
                  ),
                  IconButton(
                    icon: Icon(Icons.messenger_rounded),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
            onTap: () {
              Account account = AuthController.instance.currentUser.value!;
              Get.to(() => ChatScreen(
                    currentUser: account,
                    targetUser: user,
                  ));
            },
          ),
        );
      },
    );
  }
}
