import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_maps/Screens/Authenticate/Authenticate.dart';
import 'package:flutter_maps/Services/database.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';

class SocialSignInSingleton {
  SocialSignInSingleton._privateConstructor();

  static final SocialSignInSingleton _instance =
      SocialSignInSingleton._privateConstructor();

  String? facebookToken = "";
  bool isSocialLogin = false;

  factory SocialSignInSingleton() {
    return _instance;
  }
}

class SocialSignInProvider extends ChangeNotifier {
  final googleSignIn = GoogleSignIn();
  // final facebookSignIn = FacebookLogin();

  bool? _isSigningIn;
  bool? _isCancelledByUser;
  bool? _isError;
  bool? _isLogged;
  String? _facebookToken;
  bool? _fetching = false;

  SocialSignInSingleton socialSiginSingleton = SocialSignInSingleton();
  final box = GetStorage();

  SocialSignInProvider() {
    _isSigningIn = false;
    _isCancelledByUser = false;
    _isError = false;
    _isLogged = false;
    _facebookToken = "";
  }

  bool? get fetching => _fetching;
  bool? get isSigningIn => _isSigningIn;
  bool? get isCancelledByUser => _isCancelledByUser;
  bool? get isError => _isError;
  bool? get isLogged => _isLogged;
  String? get facebookToken => _facebookToken;

  set facebookToken(String? facebookToken) {
    _facebookToken = facebookToken;
    socialSiginSingleton.facebookToken = _facebookToken;
    notifyListeners();
  }

  set isSigningIn(bool? isSigningIn) {
    _isSigningIn = isSigningIn;
    notifyListeners();
  }

  set isCancelledByUser(bool? isCancelledByUser) {
    _isCancelledByUser = isCancelledByUser;
    notifyListeners();
  }

  set isError(bool? isError) {
    _isError = isError;
    notifyListeners();
  }

  set isLogged(bool? _isLogged) {
    _isLogged = _isLogged;
    notifyListeners();
  }

  Future<bool> loginGoogle() async {
    isSigningIn = true;

    final user = await googleSignIn.signIn();
    if (user == null) {
      isSigningIn = false;
      _isLogged = false;
    } else {
      final googleAuth = await user.authentication;
      _isLogged = true;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);
      isSigningIn = false;
      _isLogged = true;
      socialSiginSingleton.isSocialLogin = true;

      await DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid)
          .updateUserData(user.displayName);
    }
    return _isLogged!;
  }

  Future<bool> loginFacebook() async {
    isSigningIn = true;
    _fetching = true;
    notifyListeners();
    LoginResult result = await FacebookAuth.instance.login();

    if (result.status == LoginStatus.success) {
      _isLogged = true;
      final facebookCredential =
          FacebookAuthProvider.credential(result.accessToken!.token);
      final userData = await FacebookAuth.instance.getUserData();

      await FirebaseAuth.instance.signInWithCredential(facebookCredential);
      box.write("token", result.accessToken!.token);

      isSigningIn = false;
      _isLogged = true;
      socialSiginSingleton.isSocialLogin = true;
      await DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid)
          .updateUserData(userData['name']);
    } else {
      isCancelledByUser = true;
      _isLogged = false;
      isSigningIn = false;
      // Get.off(() => Wrapper());
    }
    _fetching = false;
    notifyListeners();
    return _isLogged!;
  }

  void logout() async {
    _fetching = true;
    notifyListeners();
    bool isGoogleSignedIn = await GoogleSignIn().isSignedIn();
    bool isFacebookSignedIn = await _checkIfIsLogged();
    if (isGoogleSignedIn == true) {
      GoogleSignIn().disconnect();
    } else if (isFacebookSignedIn == true) {
      await FacebookAuth.instance.logOut();
    }
    FirebaseAuth.instance.signOut().then((value) {
      _isLogged = false;
      Get.offAll(Authenticate());
    });
    _fetching = false;
    notifyListeners();
  }

  Future<bool> _checkIfIsLogged() async {
    final AccessToken? accessToken = await FacebookAuth.instance.accessToken;
    if (accessToken != null) {
      // now you can call to  FacebookAuth.instance.getUserData();
      return true;
      // final userData = await FacebookAuth.instance.getUserData(fields: "email,birthday,friends,gender,link");
    } else {
      return false;
    }
  }
}
