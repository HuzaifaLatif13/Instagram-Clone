import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:crypto/crypto.dart';

class CloudinaryService {
  static const String uploadPreset = "YOUR-FOLDER-ON-CLOUDINARY";
  static const String cloudName = "YOUR-CLOUD-NAME";
  static const String apiKey = "YOUR-CLOUDINARY-APIKEY";
  static const String apiSecret =
      "YOUR-CLOUDINARY-API-SECRET-KEY"; // Replace with your secret key

  /// **Generate Cloudinary Signature**
  static String generateSignature(String publicId, int timestamp) {
    String data = "public_id=$publicId&timestamp=$timestamp$apiSecret";
    return sha1.convert(utf8.encode(data)).toString();
  }

  /// Uploads an image file to Cloudinary and returns the URL.
  static Future<String?> uploadImage(File imageFile) async {
    try {
      var uri =
          Uri.parse("https://api.cloudinary.com/v1_1/$cloudName/image/upload");

      var request = http.MultipartRequest("POST", uri)
        ..fields['upload_preset'] = uploadPreset
        ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));

      var response = await request.send();
      var responseData = await response.stream.bytesToString();
      var jsonResponse = json.decode(responseData);

      if (response.statusCode == 200) {
        return jsonResponse["secure_url"];
      } else {
        print("Cloudinary Upload Error: ${jsonResponse['error']}");
        return null;
      }
    } catch (e) {
      print("Exception during upload: $e");
      return null;
    }
  }

  /// **Delete Image from Cloudinary**
  static Future<void> deleteImage(String imageUrl) async {
    try {
      final String publicId = imageUrl.split('/').last.split('.').first;
      int timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      String signature = generateSignature(publicId, timestamp);

      var uri =
          Uri.parse("https://api.cloudinary.com/v1_1/$cloudName/image/destroy");

      var response = await http.post(
        uri,
        body: {
          'public_id': publicId,
          'api_key': apiKey,
          'timestamp': timestamp.toString(),
          'signature': signature,
        },
      );

      var jsonResponse = json.decode(response.body);
      if (response.statusCode == 200 && jsonResponse['result'] == 'ok') {
        print("✅ Image deleted from Cloudinary: $publicId");
      } else {
        print("❌ Cloudinary Deletion Error: ${jsonResponse['error']}");
      }
    } catch (e) {
      print("❌ Exception during deletion: $e");
    }
  }
}

//
// class CloudinaryService {
//   static const String cloudName = "dhgorpjkd";
//   static const String uploadPreset = "flutter_uploads";
//
//   /// Uploads an image file to Cloudinary and returns the URL.
//   static Future<String?> uploadImage(File imageFile) async {
//     try {
//       var uri =
//           Uri.parse("https://api.cloudinary.com/v1_1/$cloudName/image/upload");
//
//       var request = http.MultipartRequest("POST", uri)
//         ..fields['upload_preset'] = uploadPreset
//         ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));
//
//       var response = await request.send();
//       var responseData = await response.stream.bytesToString();
//       var jsonResponse = json.decode(responseData);
//
//       if (response.statusCode == 200) {
//         return jsonResponse["secure_url"];
//       } else {
//         print("Cloudinary Upload Error: ${jsonResponse['error']}");
//         return null;
//       }
//     } catch (e) {
//       print("Exception during upload: $e");
//       return null;
//     }
//   }
//
//   /// **Delete Image from Cloudinary**
//   static Future<void> deleteImage(String imageUrl) async {
//     try {
//       final String publicId = imageUrl
//           .split('/')
//           .last
//           .split('.')
//           .first; // Extract public ID from URL
//
//       var uri =
//           Uri.parse("https://api.cloudinary.com/v1_1/$cloudName/image/destroy");
//
//       var response = await http.post(
//         uri,
//         body: {
//           'public_id': publicId,
//           'api_key': '424961123555225',
//         },
//       );
//
//       var jsonResponse = json.decode(response.body);
//       if (response.statusCode == 200 && jsonResponse['result'] == 'ok') {
//         print("✅ Image deleted from Cloudinary: $publicId");
//       } else {
//         print("❌ Cloudinary Deletion Error: ${jsonResponse['error']}");
//       }
//     } catch (e) {
//       print("❌ Exception during deletion: $e");
//     }
//   }
// }
