import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/account.dart';

class UserController extends GetxController {
  var users = <Account>[].obs; // Full list of users
  var allUser = <Account>[].obs;
  var filteredUsers = <Account>[].obs; // Filtered users for search
  var isLoading = true.obs;
  var searchText = ''.obs; // Observable search text
  String currentUserUid = FirebaseAuth.instance.currentUser!.uid;

  @override
  void onInit() {
    super.onInit();
    fetchAllUsers();
    fetchUsers();
    debounce(searchText, (_) => filterUsers(),
        time: Duration(milliseconds: 300));
  }

  //fetch all user
  Future<void> fetchAllUsers() async {
    isLoading(true);
    try {
      var querySnapshot =
          await FirebaseFirestore.instance.collection('users').get();

      allUser.assignAll(querySnapshot.docs
          .map((doc) => Account.fromMap(doc.data()))
          .toList());
    } catch (e) {
      print("Error fetching users: $e");
    } finally {
      Future.delayed(Duration(milliseconds: 500), () {
        isLoading.value = false;
      });
    }
  }

  // Fetch all users except the current one
  Future<void> fetchUsers() async {
    isLoading(true);
    try {
      var querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('uid', isNotEqualTo: currentUserUid)
          .get();

      users.assignAll(querySnapshot.docs
          .map((doc) => Account.fromMap(doc.data()))
          .toList());

      filteredUsers.assignAll(users); // Initially, all users are visible
    } catch (e) {
      print("Error fetching users: $e");
    } finally {
      Future.delayed(Duration(milliseconds: 500), () {
        isLoading.value = false;
      });
    }
  }

  // Filter users based on search input
  void filterUsers() {
    if (searchText.value.isEmpty) {
      filteredUsers.assignAll(users);
    } else {
      String query = searchText.value.toLowerCase();
      filteredUsers.assignAll(users.where((user) {
        return user.username.toLowerCase().contains(query) ||
            user.name.toLowerCase().contains(query);
      }).toList());
    }
  }
}
