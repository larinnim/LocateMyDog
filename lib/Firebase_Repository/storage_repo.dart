import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_maps/Models/user.dart';
import '../locator.dart';
import 'auth_repo.dart';

class StorageRepo {
  FirebaseStorage _storage =
      FirebaseStorage(storageBucket: "gs://locatemydog-17a7b.appspot.com");
  AuthRepo _authRepo = locator.get<AuthRepo>();

  Future<String> uploadFile(File file) async {
    AppUser user = await _authRepo.getUser();
    var userId = user.uid;

    var storageRef = _storage.ref().child("user/profile_pic/$userId");
    var uploadTask = storageRef.putFile(file);
    var completedTask = await uploadTask.onComplete;
    String downloadUrl = await completedTask.ref.getDownloadURL();
    print("The download URL: $downloadUrl");
    return downloadUrl;
  }

  Future<String> getUserProfileImage(String uid) async {
    AppUser user = await _authRepo.getUser();
    var userId = user.uid;
    return await _storage
        .ref()
        .child("user/profile_pic/$userId")
        .getDownloadURL();
  }

}
