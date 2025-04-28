import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_insta/widgets/custom_text_field.dart';
import '../../controllers/story_controller.dart';
import '../../widgets/custom_button.dart';
import '../home/main_screen.dart';

class NewStoryScreen extends StatelessWidget {
  final List<XFile> selectedMedia;
  RxString caption = ''.obs;
  NewStoryScreen({super.key, required this.selectedMedia});

  final StoryController storyController = Get.find<StoryController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("New Story")),
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
                    child: selectedMedia[index].path.endsWith('.mp4')
                        ? Container(
                            width: 215,
                            height: 215,
                            decoration: BoxDecoration(
                              color: Colors.black12,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.videocam,
                                size: 50, color: Colors.white),
                          )
                        : Image.file(File(selectedMedia[index].path),
                            width: 215, height: 215, fit: BoxFit.cover),
                  );
                },
              ),
            ),
            //add field button to take caption input
            CustomTextField(
                hintText: 'Caption',
                onChanged: (value) {
                  caption.value = value;
                }),
            const SizedBox(height: 20),
            Obx(() => CustomButton(
                  text: 'Share Story',
                  onPressed: () async {
                    for (XFile media in selectedMedia) {
                      String mediaType =
                          media.path.endsWith('.mp4') ? "video" : "image";
                      await storyController.addStory(
                          FirebaseAuth.instance.currentUser!.uid,
                          File(media.path),
                          mediaType,
                          mediaType == "video" ? 15 : 5,
                          caption.value);
                    }
                    Get.offAll(
                      () => MainScreen(),
                    );
                  },
                  color: Colors.blue,
                  isLoading: storyController.isLoading.value,
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
