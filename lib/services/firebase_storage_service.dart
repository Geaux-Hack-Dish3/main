import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'dart:typed_data';

class FirebaseStorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  
  /// Upload a photo to Firebase Storage and return the download URL
  /// Supports both mobile (File) and web (Uint8List) uploads
  Future<String> uploadPhoto({
    required String userId,
    required String questId,
    File? photoFile,
    Uint8List? webImageBytes,
  }) async {
    try {
      // Create unique filename with timestamp
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final path = 'quest_photos/$userId/${questId}_$timestamp.jpg';
      print('📤 Uploading to path: $path');
      final ref = _storage.ref().child(path);
      
      // Upload based on platform
      if (webImageBytes != null) {
        // Web platform
        print('   Platform: WEB (using Uint8List)');
        print('   Image size: ${webImageBytes.length} bytes');
        await ref.putData(
          webImageBytes,
          SettableMetadata(contentType: 'image/jpeg'),
        );
        print('   Upload complete!');
      } else if (photoFile != null) {
        // Mobile platform
        print('   Platform: MOBILE (using File)');
        await ref.putFile(
          photoFile,
          SettableMetadata(contentType: 'image/jpeg'),
        );
        print('   Upload complete!');
      } else {
        throw Exception('No photo data provided');
      }
      
      // Get and return download URL
      print('   Getting download URL...');
      final downloadUrl = await ref.getDownloadURL();
      print('   Download URL obtained: $downloadUrl');
      return downloadUrl;
    } on FirebaseException catch (e) {
      print('❌ Firebase Storage Exception: ${e.code} - ${e.message}');
      if (e.code == 'unauthorized' || e.code == 'permission-denied') {
        print('   ⚠️  Storage rules not configured! Please publish rules in Firebase Console.');
      }
      rethrow;
    } catch (e) {
      print('❌ Firebase Storage Error: $e');
      print('   Error type: ${e.runtimeType}');
      rethrow;
    }
  }
  
  /// Delete a photo from Firebase Storage
  Future<void> deletePhoto(String photoUrl) async {
    try {
      final ref = _storage.refFromURL(photoUrl);
      await ref.delete();
    } catch (e) {
      print('Error deleting photo from Firebase Storage: $e');
      rethrow;
    }
  }
}
