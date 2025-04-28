import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_insta/screens/story/new_story_screen.dart';
import 'new_post_screen.dart';

class MediaSelectionScreen extends StatelessWidget {
  final String screen;
  final ImagePicker _picker = ImagePicker();
  final RxList<XFile> _selectedMedia = <XFile>[].obs;

  MediaSelectionScreen({super.key, required this.screen});

  /// **Pick Multiple Images from Gallery**
  Future<void> _pickGalleryMedia() async {
    final List<XFile>? media = await _picker.pickMultipleMedia();
    if (media != null && media.isNotEmpty) {
      _selectedMedia.addAll(media);
      if (screen == 'NewPostScreen') {
        _navigateToNewPost();
      }
      if (screen == 'Story') {
        _navigateToNewStory();
      }
    }
  }

  /// **Pick a Single Image from Camera**
  Future<void> _pickCameraMedia() async {
    final XFile? media = await _picker.pickImage(source: ImageSource.camera);
    if (media != null) {
      _selectedMedia.add(media);
      if (screen == 'NewPostScreen') {
        _navigateToNewPost();
      }
      if (screen == 'Story') {
        _navigateToNewStory();
      }
    }
  }

  /// **Navigate to NewPostScreen**
  void _navigateToNewPost() {
    if (_selectedMedia.isNotEmpty) {
      Get.to(() => NewPostScreen(selectedMedia: _selectedMedia));
    }
  }

  /// **Navigate to NewPostScreen**
  void _navigateToNewStory() {
    if (_selectedMedia.isNotEmpty) {
      Get.to(() => NewStoryScreen(selectedMedia: _selectedMedia));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 65,
        titleSpacing: 10,
        backgroundColor: Colors.black,
        title: Image.asset('assets/images/app_title.png'),
      ),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(20),
          constraints: const BoxConstraints(maxWidth: 250, maxHeight: 300),
          decoration: BoxDecoration(
            color: Colors.black38,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.grey.shade300),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Select Post Type', style: TextStyle(fontSize: 16)),
              const SizedBox(height: 30),
              _buildOption(
                  Icons.image, "Gallery", Colors.blue, _pickGalleryMedia),
              const SizedBox(height: 20),
              _buildOption(
                  Icons.camera_alt, "Camera", Colors.green, _pickCameraMedia),
            ],
          ),
        ),
      ),
    );
  }

  /// **Reusable Button for Options**
  Widget _buildOption(
      IconData icon, String text, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 30, color: color),
          const SizedBox(width: 10),
          Text(text, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}
