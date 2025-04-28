import 'package:cloud_firestore/cloud_firestore.dart';

class Comment {
  final String username;
  final String userProfileImage;
  final String text;
  final DateTime timestamp;

  Comment({
    required this.username,
    required this.userProfileImage,
    required this.text,
    required this.timestamp,
  });

  factory Comment.fromMap(Map<String, dynamic> data) {
    return Comment(
      username: data['username'] ?? '',
      userProfileImage: data['userProfileImage'] ?? '',
      text: data['text'] ?? '',
      timestamp: (data['timestamp'] is Timestamp)
          ? (data['timestamp'] as Timestamp).toDate()
          : DateTime.tryParse(data['timestamp'] ?? '') ?? DateTime.now(),
    );
  }
}

class Post {
  final String username;
  final String userId;
  final String postId;
  final String location;
  final String userProfileImage;
  List<String> postImages;
  final String caption;
  final int likes;
  final List<String> likedBy;
  final DateTime timestamp;
  final List<Comment> comments;

  Post({
    required this.username,
    required this.userId,
    required this.postId,
    required this.location,
    required this.userProfileImage,
    required this.caption,
    required this.postImages,
    required this.likes,
    required this.likedBy,
    required this.timestamp,
    required this.comments,
  });

  factory Post.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return Post(
      username: data['username'] ?? '',
      userId: data['userId'] ?? '',
      postId: data['postId'] ?? '',
      location: data['location'] ?? '',
      userProfileImage: data['userProfileImage'] ?? '',
      postImages: (data['postImages'] is List)
          ? List<String>.from(data['postImages'])
          : (data['postImages'] is String)
              ? [data['postImages']]
              : [],
      caption: data['caption'] ?? '',
      likes: data['likes'] ?? 0,
      likedBy: List<String>.from(data['likedBy'] ?? []),
      timestamp: (data['timestamp'] is Timestamp)
          ? (data['timestamp'] as Timestamp).toDate()
          : DateTime.tryParse(data['timestamp'] ?? '') ?? DateTime.now(),
      comments: (data['comments'] as List<dynamic>?)
              ?.map((comment) => Comment.fromMap(comment))
              .toList() ??
          [],
    );
  }
}
