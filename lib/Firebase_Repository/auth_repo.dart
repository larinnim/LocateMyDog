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
    var authResult = await _auth.signInWithEmailAndPassword(
        email: email, password: password);
    return AppUser(authResult.user.uid,
        displayName: authResult.user.displayName);
  }

  Future<AppUser> getUser() async {
    var firebaseUser = await _auth.currentUser;
    return AppUser(firebaseUser.uid, displayName: firebaseUser.displayName);
  }

  Future<void> updateDisplayName(String displayName) async {
    var user = await _auth.currentUser;

    // user.updateProfile(
    //   UserUpdateInfo()..displayName = displayName,
    // );
  }
}
