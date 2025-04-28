import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String senderId;
  final String receiverId;
  final String text;
  final Timestamp timestamp;

  Message({
    required this.senderId,
    required this.receiverId,
    required this.text,
    required this.timestamp,
  });

  // Convert Message to Map (for Firestore)
  Map<String, dynamic> toMap() {
    return {
      "senderId": senderId,
      "receiverId": receiverId,
      "text": text,
      "timestamp": timestamp,
    };
  }

  // Create Message from Firestore snapshot
  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      senderId: map["senderId"],
      receiverId: map["receiverId"],
      text: map["text"],
      timestamp: map["timestamp"],
    );
  }
}
