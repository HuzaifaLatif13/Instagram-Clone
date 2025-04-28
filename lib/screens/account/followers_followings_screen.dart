import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_insta/controllers/user_controller.dart';
import '../../models/account.dart';
import '../../widgets/custom_list_view.dart';

class FollowersFollowingsScreen extends StatelessWidget {
  final Account user;
  final UserController userController = Get.find<UserController>();
  final int initialTabIndex; // Add this parameter

  FollowersFollowingsScreen({
    super.key,
    required this.user,
    this.initialTabIndex = 0, // Default to Followers tab
  });

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      initialIndex: initialTabIndex, // Set default tab here
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Connections"),
          bottom: TabBar(
            labelColor: Colors.blue,
            labelStyle: TextStyle(fontSize: 16),
            indicatorColor: Colors.blue,
            overlayColor: WidgetStateProperty.all(
                // ignore: deprecated_member_use
                Colors.blue.withOpacity(0.3)), // Splash color
            tabs: [
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Tab(text: "Followers"),
              ),
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Tab(text: "Followings"),
              ),
            ],
          ),
        ),
        body: Obx(() {
          if (userController.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          List<Account> followers = [];
          //loop
          for (Account account in userController.allUser) {
            print(account.uid);
            if (account.uid != user.uid) {
              if (user.followers.contains(account.uid.value)) {
                followers.add(account);
              }
            }
          }

          List<Account> followings = [];
          for (Account account in userController.allUser) {
            print(account.uid);
            if (account.uid != user.uid) {
              if (account.followers.contains(user.uid.toString())) {
                followings.add(account);
              }
            }
          }
          print(user.uid);
          print('Followers: ${followers}');
          print('Following: ${followings}');

          return TabBarView(
            children: [
              CustomListView(usersToDisplay: followers),
              CustomListView(usersToDisplay: followings),
            ],
          );
        }),
      ),
    );
  }
}
