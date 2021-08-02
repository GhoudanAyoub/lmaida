import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:lmaida/utils/file_utils.dart';
import 'package:lmaida/utils/firebase.dart';

abstract class Service {
  Future<String> uploadImage(StorageReference ref, File file) async {
    String ext = FileUtils.getFileExtension(file);
    StorageReference storageReference = ref.child("${uuid.v4()}.$ext");
    StorageUploadTask uploadTask = storageReference.putFile(file);
    await uploadTask.future.whenComplete(() => null);
    String fileUrl = await storageReference.getDownloadURL();
    return fileUrl;
  }
}
