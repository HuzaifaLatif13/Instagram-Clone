import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:video_player/video_player.dart';
import 'package:my_insta/models/story.dart';
import 'package:my_insta/models/account.dart';
import 'package:my_insta/controllers/story_controller.dart';

import '../home/main_screen.dart';

class StoryViewScreen extends StatefulWidget {
  final List<Story> stories; // Multiple stories support
  const StoryViewScreen({super.key, required this.stories});

  @override
  _StoryViewScreenState createState() => _StoryViewScreenState();
}

class _StoryViewScreenState extends State<StoryViewScreen> {
  int _currentIndex = 0;
  VideoPlayerController? _videoController;
  final StoryController storyController = Get.find<StoryController>();

  @override
  void initState() {
    super.initState();
    _loadStory();
  }

  void _loadStory() {
    final currentStory = widget.stories[_currentIndex];

    if (currentStory.mediaType == "video") {
      _videoController?.dispose();
      _videoController = VideoPlayerController.network(currentStory.mediaUrl)
        ..initialize().then((_) {
          setState(() {});
          _videoController!.play();
        });
    }
  }

  void _nextStory() {
    if (_currentIndex < widget.stories.length - 1) {
      setState(() {
        _currentIndex++;
        _loadStory();
      });
    } else {
      Get.back(); // Close if no more stories
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentStory = widget.stories[_currentIndex];

    // Find the user who posted the story
    Account? user = storyController.users
        .firstWhereOrNull((u) => u.uid == currentStory.userId);

    return GestureDetector(
      onVerticalDragEnd: (details) {
        if (details.primaryVelocity! > 0) {
          Get.back(); // Swipe down to exit
        } else if (details.primaryVelocity! < 0) {
          Get.back(); // Swipe up to exit
        }
      },
      onTap: _nextStory, // Tap to go to the next story
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            // Story Content (Image/Video)
            Center(
              child: currentStory.mediaType == "image"
                  ? CachedNetworkImage(
                      imageUrl: currentStory.mediaUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      progressIndicatorBuilder: (context, url, progress) =>
                          Center(
                        child: CircularProgressIndicator(
                          value: progress.progress,
                          strokeWidth: 3,
                          color: Colors.blue,
                        ),
                      ),
                    )
                  : _videoController != null &&
                          _videoController!.value.isInitialized
                      ? AspectRatio(
                          aspectRatio: _videoController!.value.aspectRatio,
                          child: VideoPlayer(_videoController!),
                        )
                      : Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        ),
            ),

            // Top Section - Profile Picture, Name, and Time Ago
            Positioned(
              top: 40,
              left: 10,
              right: 10,
              child: Row(
                children: [
                  // Profile Picture
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.white,
                    backgroundImage: user?.profileImage != null
                        ? NetworkImage(user!.profileImage.toString())
                        : AssetImage("assets/default_avatar.png")
                            as ImageProvider,
                  ),
                  const SizedBox(width: 10),

                  // User Name & Time Ago
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.name.toString() ?? "Unknown",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold),
                      ),
                      Text(
                        timeago.format(currentStory.timestamp.toDate()),
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),

                  Spacer(),

                  // Close Button
                  IconButton(
                    icon: Icon(Icons.close, color: Colors.white, size: 30),
                    onPressed: () {
                      Get.back();
                    },
                  ),
                ],
              ),
            ),

            // Story Caption
            Positioned(
              bottom: 50,
              left: 20,
              right: 20,
              child: Text(
                currentStory.caption,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
