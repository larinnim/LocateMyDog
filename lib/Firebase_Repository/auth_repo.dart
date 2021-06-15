// import 'dart:html';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_maps/Models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthRepo {
  // final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  AuthRepo();

  // Future<AppUser> signInWithGoogle() async {
  //   final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
  //   // final User user;
  //   if (googleUser == null) {
  //     return null;
  //   } else {
  //     final GoogleSignInAuthentication googleAuth =
  //         await googleUser.authentication;

  //     final AuthCredential credential = GoogleAuthProvider.credential(
  //       accessToken: googleAuth.accessToken,
  //       idToken: googleAuth.idToken,
  //     );

  //     // final UserCredential userCredential =
  //     await _auth.signInWithCredential(credential).then((credential) {
  //       // user = credential.user;
  //       return AppUser(credential.user.uid,
  //           displayName: credential.user.displayName);
  //     }).catchError((error) {
  //       return error;
  //       // throw (error);
  //     });
  //     return null;

  //     // final UserCredential userCredential =
  //     //     await _auth.signInWithCredential(credential).catchError((error) {});
  //     // final User user = userCredential.user;
  //     // print("signed in " + user.displayName);
  //     // return AppUser(user.uid, displayName: user.displayName);
  //   }
  // }

  Future<AppUser?> signInWithFacebook() async {
    // final facebookLogin = FacebookLogin();
    // final result = await facebookLogin.logIn([
    //   'email',
    // ]);
    // if (result.errorMessage == null) {
    try {
      // final token = result.accessToken.token;
      LoginResult result = await FacebookAuth.instance.login();

      // final graphResponse = await http.get(
      //     'https://graph.facebook.com/v2.12/me?fields=name,first_name,last_name,email&access_token=$token');
      // print(graphResponse.body);
      if (result.status == LoginStatus.success) {
        final facebookCredential =
            FacebookAuthProvider.credential(result.accessToken.toString());
        final UserCredential userCredential =
            await _auth.signInWithCredential(facebookCredential);
        return AppUser(userCredential.user!.uid,
            displayName: userCredential.user!.displayName);
      } else {
        return null;
      }
    } catch (error) {
      return null;
    }
  }

  Future<AppUser?> signInWithEmailAndPassword(
      {required String email, required String password}) async {
    String errorMessage;
    var authResult;

    try {
      authResult = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      return AppUser(authResult.user.uid,
          displayName: authResult.user.displayName);
    } catch (error) {
      switch (error) {
        case "invalid-email":
          errorMessage = "Your email address appears to be malformed.";
          break;
        case "wrong-password":
          errorMessage = "Your password is wrong.";
          break;
        case "user-not-found":
          errorMessage = "User with this email doesn't exist.";
          break;
        case "user-disabled":
          errorMessage = "User with this email has been disabled.";
          break;
        case "too-many-requests":
          errorMessage = "Too many requests. Try again later.";
          break;
        case "operation-not-allowed":
          errorMessage = "Signing in with Email and Password is not enabled.";
          break;
        default:
          errorMessage =
              "An unexpected error occurred. Please check your internet connection.";
      }
      // obtain shared preferences
      final prefs = await SharedPreferences.getInstance();
      // set value
      prefs.setString('siginError', errorMessage);
      return null;
    }
  }

  Future<AppUser> getUser() async {
    var firebaseUser = _auth.currentUser;
    // return AppUser(firebaseUser.uid, displayName: firebaseUser.displayName);
    if (firebaseUser != null) {
      return AppUser(firebaseUser.uid,
          displayName: firebaseUser.displayName,
          avatarUrl: firebaseUser.photoURL);
    } else {
      return AppUser("",displayName:"",avatarUrl:"");
    }
  }

  // Future<void> updateDisplayName(String displayName) async {
  //   var user = await _auth.currentUser;

  //   // user.updateProfile(
  //   //   UserUpdateInfo()..displayName = displayName,
  //   // );
  // }
}
