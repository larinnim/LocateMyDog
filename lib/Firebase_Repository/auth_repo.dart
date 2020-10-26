import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_maps/Models/user.dart';
import 'package:google_sign_in/google_sign_in.dart';

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
    } catch (error) {
      switch (error.code) {
        case "ERROR_INVALID_EMAIL":
          errorMessage = "Your email address appears to be malformed.";
          break;
        case "ERROR_WRONG_PASSWORD":
          errorMessage = "Your password is wrong.";
          break;
        case "ERROR_USER_NOT_FOUND":
          errorMessage = "User with this email doesn't exist.";
          break;
        case "ERROR_USER_DISABLED":
          errorMessage = "User with this email has been disabled.";
          break;
        case "ERROR_TOO_MANY_REQUESTS":
          errorMessage = "Too many requests. Try again later.";
          break;
        case "ERROR_OPERATION_NOT_ALLOWED":
          errorMessage = "Signing in with Email and Password is not enabled.";
          break;
        default:
          errorMessage = "An undefined Error happened.";
      }
    }

    return AppUser(authResult.user.uid,
        displayName: authResult.user.displayName);
  }

  Future<AppUser> getUser() async {
    var firebaseUser = _auth.currentUser;
    return AppUser(firebaseUser.uid, displayName: firebaseUser.displayName);
  }

  // Future<void> updateDisplayName(String displayName) async {
  //   var user = await _auth.currentUser;

  //   // user.updateProfile(
  //   //   UserUpdateInfo()..displayName = displayName,
  //   // );
  // }
}
