import 'dart:io';

import 'package:flutter_maps/Firebase_Repository/auth_repo.dart';
import 'package:flutter_maps/Firebase_Repository/storage_repo.dart';
import 'package:flutter_maps/Models/user.dart';
import 'package:flutter_maps/locator.dart';

class UserController {
  AppUser _currentUser;
  AuthRepo _authRepo = locator.get<AuthRepo>();
  StorageRepo _storageRepo = locator.get<StorageRepo>();
  Future init;

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
    _currentUser.avatarUrl = await getDownloadUrl();
  }
}
