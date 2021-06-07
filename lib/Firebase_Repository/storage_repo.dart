import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter_maps/Models/user.dart';
import '../locator.dart';
import 'auth_repo.dart';

class StorageRepo {
  firebase_storage.FirebaseStorage storage =
      firebase_storage.FirebaseStorage.instanceFor(
          bucket: 'gs://locatemydog-17a7b.appspot.com');

  // FirebaseStorage _storage =
  //     FirebaseStorage(storageBucket: "gs://locatemydog-17a7b.appspot.com");
  AuthRepo _authRepo = locator.get<AuthRepo>();

  Future<String> uploadFile(File file) async {
    AppUser user = await _authRepo.getUser();
    var userId = user.uid;
    try {
      firebase_storage.Reference ref =
          storage.ref().child("user/profile_pic/$userId");
      firebase_storage.UploadTask uploadTask = ref.putFile(file);
      var imageUrl = await (await uploadTask).ref.getDownloadURL();
      String downloadUrl = imageUrl.toString();
      print("The download URL: $downloadUrl");
      await FirebaseAuth.instance.currentUser!
          .updateProfile(photoURL: downloadUrl);
      return downloadUrl;
    } catch (e) {
      print(e.toString());
      return "";
    }
  }

  Future<String> uploadSenderPic(File file, String senderID) async {
    AppUser user = await _authRepo.getUser();
    var userId = user.uid;
    try {
      firebase_storage.Reference ref =
          storage.ref().child("user/profile_pic/$userId/senders_pic/$senderID");
      firebase_storage.UploadTask uploadTask = ref.putFile(file);
      var imageUrl = await (await uploadTask).ref.getDownloadURL();
      String downloadUrl = imageUrl.toString();
      print("The download URL: $downloadUrl");
      await FirebaseAuth.instance.currentUser!
          .updateProfile(photoURL: downloadUrl);
      return downloadUrl;
    } catch (e) {
      print(e.toString());
      return "";
    }
  }

  Future<String> getUserProfileImage(String? uid) async {
    AppUser user = await _authRepo.getUser();
    var userId = user.uid;
    return await storage
        .ref()
        .child("user/profile_pic/$userId")
        .getDownloadURL();
  }
}
