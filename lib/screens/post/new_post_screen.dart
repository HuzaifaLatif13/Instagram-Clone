import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../controllers/post_controller.dart';
import 'package:my_insta/widgets/custom_button.dart';

import '../home/main_screen.dart';

class NewPostScreen extends StatelessWidget {
  final List<XFile> selectedMedia;
  NewPostScreen({super.key, required this.selectedMedia});

  final TextEditingController _captionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final PostController postController = Get.find<PostController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("New Post")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 215,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: selectedMedia.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Image.file(File(selectedMedia[index].path),
                        width: 215, height: 215, fit: BoxFit.cover),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            TextField(
                controller: _captionController,
                decoration: const InputDecoration(
                    hintText: 'Caption', border: OutlineInputBorder())),
            const SizedBox(height: 10),
            TextField(
                controller: _locationController,
                decoration: const InputDecoration(
                    hintText: 'Location', border: OutlineInputBorder())),
            const SizedBox(height: 10),
            Obx(() => CustomButton(
                  text: 'Share',
                  onPressed: () {
                    postController.sharePost(
                      _captionController.text.trim(),
                      _locationController.text.trim(),
                      selectedMedia,
                    );
                    //delay
                    Future.delayed(const Duration(seconds: 1), () {
                      Get.to(MainScreen());
                    });
                  },
                  color: Colors.blue,
                  isLoading: postController.isUploading.value,
                  loadingWidget: const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
