import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_maps/Models/user.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthRepo {
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  AuthRepo();

  Future<void> signInWithGoogle() async {
    final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final User user = (await _auth.signInWithCredential(credential)).user;
    print("signed in " + user.displayName);
    return user;
  }

  Future<AppUser> signInWithEmailAndPassword(
      {String email, String password}) async {
    String errorMessage;
    var authResult;

    try {
      authResult = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      return AppUser(authResult.user.uid,
          displayName: authResult.user.displayName);
    } catch (error) {
      switch (error.code) {
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
          errorMessage = "An unexpected error happened. Please check your internet connectivity.";
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
    return AppUser(firebaseUser.uid, displayName: firebaseUser.displayName, avatarUrl: firebaseUser.photoURL);
  }

  // Future<void> updateDisplayName(String displayName) async {
  //   var user = await _auth.currentUser;

  //   // user.updateProfile(
  //   //   UserUpdateInfo()..displayName = displayName,
  //   // );
  // }
}
