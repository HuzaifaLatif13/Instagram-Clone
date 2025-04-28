import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../models/account.dart';
import '../screens/account/account_details_screen.dart';

class CustomListView extends StatelessWidget {
  final List<Account> usersToDisplay;
  const CustomListView({super.key, required this.usersToDisplay});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: usersToDisplay.length,
      itemBuilder: (context, index) {
        Account user = usersToDisplay[index];

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
            tileColor: Colors.transparent,
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
                    radius: 30,
                    backgroundColor: Colors.white70,
                    backgroundImage:
                        CachedNetworkImageProvider(user.profileImage.value),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Text(user.username.value),
                  ),
                  IconButton(
                    icon: Icon(Icons.person_add_alt),
                    onPressed: () {
                      // Add action to follow user
                    },
                  ),
                ],
              ),
            ),
            onTap: () {
              // Navigate to account details screen
              Get.to(() => AccountDetailScreen(user: user));
            },
          ),
        );
      },
    );
  }
}
