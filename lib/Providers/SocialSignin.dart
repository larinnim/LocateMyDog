
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_maps/Screens/Authenticate/Authenticate.dart';
import 'package:flutter_maps/Screens/Authenticate/sign_in.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

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
  bool? _isSignedIn;
  String? _facebookToken;
  SocialSignInSingleton socialSiginSingleton = SocialSignInSingleton();
  final box = GetStorage();

  SocialSignInProvider() {
    _isSigningIn = false;
    _isCancelledByUser = false;
    _isError = false;
    _isSignedIn = false;
    _facebookToken = "";
  }

  bool? get isSigningIn => _isSigningIn;
  bool? get isCancelledByUser => _isCancelledByUser;
  bool? get isError => _isError;
  bool? get isSignedIn => _isSignedIn;
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

  set isSignedIn(bool? isSignedIn) {
    _isSignedIn = isSignedIn;
    notifyListeners();
  }

  Future loginGoogle() async {
    isSigningIn = true;

    final user = await googleSignIn.signIn();
    if (user == null) {
      isSigningIn = false;
      return;
    } else {
      final googleAuth = await user.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);
      isSigningIn = false;
      isSignedIn = true;
      socialSiginSingleton.isSocialLogin = true;
    }
  }

  Future loginFacebook() async {
    isSigningIn = true;

    try {
      // final token = result.accessToken.token;
      LoginResult result = await FacebookAuth.instance.login();
      // final userData = await FacebookAuth.instance.getUserData();

      // final graphResponse = await http.get(
      //     'https://graph.facebook.com/v2.12/me?fields=name,first_name,last_name,email&access_token=$token');
      // print(graphResponse.body);

      if (result.status == LoginStatus.success) {
        final facebookCredential =
            FacebookAuthProvider.credential(result.accessToken.toString());

        await FirebaseAuth.instance.signInWithCredential(facebookCredential);

        isSigningIn = false;
        isSignedIn = true;
        socialSiginSingleton.isSocialLogin = true;
      } else {
        isCancelledByUser = true;
        Get.to(Authenticate());
      } 
      // else if (result.status == LoginStatus.failed) {
      //   isError = true;
      // }
    } catch (error) {
      return null;
    }

    // final result = await facebookSignIn.logIn([
    //   'email',
    // ]);
    // if (result.errorMessage == null) {

    // final token = result.accessToken.token;
    // final graphResponse = await http.get(
    //     'https://graph.facebook.com/v2.12/me?fields=name,first_name,last_name,email&access_token=$token');

    // facebookToken = token;
    // final profile = jsonDecode(graphResponse.body);

// box.write("token", token);

    // print(graphResponse.body);
    // if (result.status == FacebookLoginStatus.loggedIn) {
    //   final facebookCredential = FacebookAuthProvider.credential(token);

    //   await FirebaseAuth.instance.signInWithCredential(facebookCredential);

    //   isSigningIn = false;
    //   isSignedIn = true;
    //   socialSiginSingleton.isSocialLogin = true;
    // } else if (result.status == FacebookLoginStatus.cancelledByUser) {
    //   isCancelledByUser = true;
    // } else if (result.status == FacebookLoginStatus.error) {
    //   isError = true;
    // }
  }

  void logout() async {
    // await googleSignIn.disconnect();
    // FirebaseAuth.instance.signOut();

    bool isGoogleSignedIn = await GoogleSignIn().isSignedIn();
    bool isFacebookSignedIn = await _checkIfIsLogged();
    if (isGoogleSignedIn == true) {
      GoogleSignIn().disconnect();
    } else if (isFacebookSignedIn == true) {
      await FacebookAuth.instance.logOut();
    }
    FirebaseAuth.instance.signOut().then((value) {
      isSignedIn = false;
      Get.offAll(Authenticate());
    });
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
