import 'package:cloud_firestore/cloud_firestore.dart';

class Story {
  final String storyId;
  final String userId;
  final String mediaUrl;
  final String caption;
  final String mediaType; // "image" or "video"
  final int duration; // in seconds
  final Timestamp timestamp;
  final List<String> seen; // List of userIds who have seen the story

  Story({
    required this.storyId,
    required this.userId,
    required this.mediaUrl,
    required this.caption,
    required this.mediaType,
    required this.duration,
    required this.timestamp,
    required this.seen,
  });

  /// Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      "storyId": storyId,
      "userId": userId,
      "mediaUrl": mediaUrl,
      "mediaType": mediaType,
      "duration": duration,
      "timestamp": timestamp,
      "caption": caption,
      "seen": seen, // Save list of user IDs who have seen the story
    };
  }

  /// Create Story from Firestore Document
  factory Story.fromMap(Map<String, dynamic> map) {
    return Story(
      storyId: map["storyId"],
      userId: map["userId"],
      mediaUrl: map["mediaUrl"],
      mediaType: map["mediaType"],
      duration: map["duration"],
      timestamp: map["timestamp"],
      seen: List<String>.from(map["seen"] ?? []),
      caption: map["caption"], // Handle null values safely
    );
  }
}
