import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import '../../controllers/user_controller.dart';
import '../../models/account.dart';
import '../../widgets/custom_list_view.dart';

class UsersListScreen extends StatefulWidget {
  const UsersListScreen({super.key});

  @override
  State<UsersListScreen> createState() => _UsersListScreenState();
}

class _UsersListScreenState extends State<UsersListScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Users')),
      body: GetX<UserController>(
        init: UserController(), // Initialize controller
        builder: (controller) {
          if (controller.isLoading.value) {
            return ListView.builder(
              itemCount: 5, // Show shimmer effect for loading state
              itemBuilder: (context, index) => _buildShimmerUser(),
            );
          }

          final currentUserUID = controller.currentUserUid;
          List<Account> usersToDisplay = controller.users
              .where((user) => user.uid.value != currentUserUID)
              .toList();

          return CustomListView(usersToDisplay: usersToDisplay);
        },
      ),
    );
  }

  // Function to build a shimmer placeholder user
  Widget _buildShimmerUser() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[800]!,
        highlightColor: Colors.grey[500]!,
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: Colors.grey[700],
            ),
            SizedBox(width: 16),
            Expanded(
              child: Container(
                height: 40,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(width: 16),
            Icon(Icons.person_add_alt, color: Colors.grey[700]),
          ],
        ),
      ),
    );
  }
}
