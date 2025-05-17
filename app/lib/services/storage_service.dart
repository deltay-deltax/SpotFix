import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class StorageService {
  final supabase = Supabase.instance.client;
  final uuid = const Uuid();

  // Upload image and get URL
  Future<String> uploadImage(File imageFile) async {
    try {
      print("STORAGE: Starting image upload");
      final String fileName = '${uuid.v4()}.jpg';
      final String path = 'issue_images/$fileName';

      print("STORAGE: Uploading to path: $path");
      await supabase.storage
          .from('issue_images')
          .upload(
            path,
            imageFile,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
          );

      final String imageUrl = supabase.storage
          .from('issue_images')
          .getPublicUrl(path);
      print("STORAGE: Image uploaded successfully. URL: $imageUrl");
      return imageUrl;
    } catch (e) {
      print("STORAGE ERROR: Failed to upload image: $e");
      rethrow;
    }
  }
}
