import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_insta/models/account.dart';

import '../../controllers/user_controller.dart';
import '../account/account_details_screen.dart';

class SearchScreen extends StatelessWidget {
  final UserController userController = Get.put(UserController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Container(
          padding: EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30), // Circular border
            border: Border.all(color: Colors.blue, width: 2), // Blue border
          ),
          child: TextField(
            onChanged: (value) => userController.searchText.value = value,
            cursorColor: Colors.blue,
            decoration: InputDecoration(
              hintText: "Search by name or username...",
              border: InputBorder.none,
            ),
          ),
        ),
        elevation: 0, // Remove shadow for a clean look
      ),
      body: Obx(() {
        if (userController.isLoading.value) {
          return _buildLoadingEffect();
        }

        if (userController.filteredUsers.isEmpty) {
          return Center(child: Text("No users found."));
        }

        return ListView.builder(
          itemCount: userController.filteredUsers.length,
          itemBuilder: (context, index) {
            Account user = userController.filteredUsers[index];
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.grey[700],
                backgroundImage: CachedNetworkImageProvider(
                  user.profileImage.toString(),
                ),
              ),
              title: Text(user.username.toString()),
              subtitle: Text(user.name.toString()),
              onTap: () {
                Get.to(() => AccountDetailScreen(user: user));
              },
            );
          },
        );
      }),
    );
  }

  Widget _buildLoadingEffect() {
    return ListView.builder(
      itemCount: 10,
      itemBuilder: (context, index) => ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.grey[300],
        ),
        title: Container(
          height: 10,
          width: 50,
          color: Colors.grey[300],
        ),
        subtitle: Container(
          height: 8,
          width: 30,
          color: Colors.grey[200],
        ),
      ),
    );
  }
}
