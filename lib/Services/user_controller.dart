import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_maps/Firebase_Repository/auth_repo.dart';
import 'package:flutter_maps/Firebase_Repository/storage_repo.dart';
import 'package:flutter_maps/Models/user.dart';
import 'package:flutter_maps/locator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';

class UserController {
  AppUser _currentUser;
  AuthRepo _authRepo = locator.get<AuthRepo>();
  StorageRepo _storageRepo = locator.get<StorageRepo>();
  Future init;
  final navigatorKey = GlobalKey<NavigatorState>();

  UserController() {
    init = initUser();
  }

  Future<AppUser> initUser() async {
    _currentUser = await _authRepo.getUser();
    return _currentUser;
  }

  AppUser get currentUser => _currentUser;

  void uploadProfilePicture(File image) async {
    print("In uploadProfile pic");
    _currentUser.avatarUrl = await _storageRepo.uploadFile(image);
  }

  Future<String> getDownloadUrl() async {
    return await _storageRepo.getUserProfileImage(currentUser.uid);
  }

  void updateDisplayName(String displayName) {
    _currentUser.displayName = displayName;
    updateDisplayName(displayName);
    // _authRepo.updateDisplayName(displayName);
  }

  Future<void> signInWithEmailAndPassword(
      {String email, String password}) async {
    _currentUser = await _authRepo.signInWithEmailAndPassword(
        email: email, password: password);

    if (_currentUser != null) {
      _currentUser.avatarUrl = await getDownloadUrl();
    }
  }

  Future<void> signInWithFacebook() async {
    _currentUser = await _authRepo.signInWithFacebook();

    if (_currentUser == null) {
      Get.dialog(SimpleDialog(title: Text("Facebook Sign In Error", style: TextStyle(fontWeight: FontWeight.bold),),shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(10.0)), children: [Text("    Please verify your credentials and network connection.", style: TextStyle(fontSize: 20.0))],));
    }
  }
}
