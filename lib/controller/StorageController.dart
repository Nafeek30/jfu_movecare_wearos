import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class StorageController {

  /// Upload the csv file to firebase storgae and then print the download link that lets you view the saved data.
  /// You can also check/download the csv file on firebase console at Firebase Storage section.
  Future<void> uploadToFirebaseStorage(File file, String filename) async {
    try {
      // Reference to the folder 'telemetry'
      var reference = FirebaseStorage.instance.ref().child(
          '${FirebaseAuth.instance.currentUser!.uid}/telemetry/$filename.csv');

      // Upload the file to Firebase Storage with metadata
      SettableMetadata metadata = SettableMetadata(
        contentType: 'text/csv',
      );

      // Upload the file to Firebase Storage
      await reference.putFile(file, metadata);

      // If upload task was successful, print the download link
      final String downloadUrl = await reference.getDownloadURL();
      print("Upload successful: $downloadUrl");
    } catch (e) {
      print("Upload failed: $e");
    }
  }
}
