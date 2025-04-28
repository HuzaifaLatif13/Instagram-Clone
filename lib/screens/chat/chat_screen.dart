import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import '../../controllers/chat_controller.dart';
import '../../models/message.dart';
import '../../models/account.dart';
import '../account/account_details_screen.dart';

class ChatScreen extends StatelessWidget {
  final Account currentUser;
  final Account targetUser;

  final ChatController chatController = Get.put(ChatController());
  final TextEditingController messageController = TextEditingController();

  ChatScreen({
    required this.currentUser,
    required this.targetUser,
  }) {
    chatController.loadMessages(currentUser.uid.value, targetUser.uid.value);
  }

  @override
  Widget build(BuildContext context) {
    // FocusNode focusNode = FocusNode();
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 70,
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.grey[700],
              backgroundImage: CachedNetworkImageProvider(
                targetUser.profileImage.toString(),
              ),
              radius: 20,
            ),
            SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  targetUser.name.value,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  "@${targetUser.username.value}",
                  style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.more_vert),
            onPressed: () {
              showMenu(
                context: context,
                position: RelativeRect.fromLTRB(100, 50, 0, 0),
                items: [
                  PopupMenuItem(
                    child: Text("View Profile"),
                    onTap: () {
                      Get.to(() => AccountDetailScreen(user: targetUser));
                    },
                  ),
                  PopupMenuItem(child: Text("Block User")),
                  PopupMenuItem(child: Text("Report")),
                ],
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 30, left: 10, right: 10),
        child: Column(
          children: [
            // Chat Messages
            Expanded(
              child: Obx(() {
                if (chatController.isLoading.value) {
                  return ListView.builder(
                    itemCount: 5, // Placeholder shimmer items
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          mainAxisAlignment: index % 2 == 0
                              ? MainAxisAlignment.start
                              : MainAxisAlignment.end,
                          children: [
                            Shimmer.fromColors(
                              baseColor: Colors.grey[300]!,
                              highlightColor: Colors.grey[100]!,
                              child: Column(
                                spacing: 3,
                                crossAxisAlignment: index % 2 == 0
                                    ? CrossAxisAlignment.start
                                    : CrossAxisAlignment.end,
                                children: [
                                  Container(
                                    width: 200,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  Container(
                                    width: 100,
                                    height: 10,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                }

                return ListView.builder(
                  reverse: false,
                  itemCount: chatController.messages.length,
                  itemBuilder: (context, index) {
                    Message message = chatController.messages[index];
                    bool isSender = message.senderId == currentUser.uid.value;

                    return Align(
                      alignment: isSender
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Column(
                        crossAxisAlignment: isSender
                            ? CrossAxisAlignment.end
                            : CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: EdgeInsets.symmetric(
                                vertical: 4, horizontal: 10),
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isSender ? Colors.blue : Colors.grey[300],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              message.text,
                              style: TextStyle(
                                  color:
                                      isSender ? Colors.white : Colors.black),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 10, right: 10),
                            child: Text(
                              DateFormat.jm().format(
                                  message.timestamp.toDate()), // Time format
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              }),
            ),

            // Message Input Field
            Padding(
              padding: const EdgeInsets.only(bottom: 20, left: 8, right: 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: messageController,
                      // focusNode: focusNode,
                      cursorColor: Colors.blue,
                      decoration: InputDecoration(
                        hintText: "Type a message...",
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.white),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.blue, width: 2),
                        ),
                        hintStyle: TextStyle(color: Colors.grey[400]),
                      ),
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  SizedBox(width: 8),
                  IconButton(
                    icon: Icon(Icons.send, color: Colors.blue),
                    onPressed: () {
                      if (messageController.text.trim().isNotEmpty) {
                        chatController.sendMessage(
                            currentUser.uid.value,
                            targetUser.uid.value,
                            messageController.text.trim());
                        messageController.clear();
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
