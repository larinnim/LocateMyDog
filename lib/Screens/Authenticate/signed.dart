// import 'dart:io' show Platform;

// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_maps/Screens/Profile/profile.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:local_auth/local_auth.dart';

// class Signed extends StatefulWidget {
//   final User user;
//   final bool wantsTouchID;
//   final String password;

//   Signed({@required this.user, @required this.wantsTouchID, this.password});

//   @override
//   _SignedPageState createState() => _SignedPageState();
// }

// class _SignedPageState extends State<Signed> {
//   final LocalAuthentication auth = LocalAuthentication();
//   final storage = FlutterSecureStorage();

//   @override
//   void initState() {
//     super.initState();
//     if (widget.wantsTouchID) {
//       authenticate();
//     }
//   }

//   void authenticate() async {
//     final canCheck = await auth.canCheckBiometrics;
//     if (canCheck) {
//       List<BiometricType> availableBiometrics =
//           await auth.getAvailableBiometrics();

//       if (Platform.isIOS) {
//         if (availableBiometrics.contains(BiometricType.face)) {
//           //Face ID
//           final authenticated = await auth.authenticateWithBiometrics(
//               localizedReason: 'Enable Face ID to sign in more easily');
//           if (authenticated) {
//             storage.write(key: 'email', value: widget.user.email);
//             storage.write(key: 'password', value: widget.password);
//             storage.write(key: 'usingBiometric', value: 'true');
//           }
//         } else if (availableBiometrics.contains(BiometricType.fingerprint)) {
//           //Touch ID
//         }
//       }
//     } else {
//       print('cant check');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (widget.wantsTouchID) {}
//     return ProfileScreen();
//   }
// }
