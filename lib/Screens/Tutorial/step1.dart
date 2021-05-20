import 'dart:async';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_maps/Services/permissionChangeBuilder.dart';
import 'package:flutter_maps/Screens/Tutorial/step2.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:permission_handler_platform_interface/permission_handler_platform_interface.dart';


class Step1 extends StatefulWidget {
  @override
  _Step1State createState() => _Step1State();
}

class _Step1State extends State<Step1> {
  @override
  void initState() {
    requestLocation();
    super.initState();
  }

  void requestLocation() async {
    await Permission.location.request();
  }

  // void checkNotificationPermission() async {
  //   var notificationStatus = await Permission.notification.status;

  //   print(notificationStatus);

  //   //cameraStatus.isGranted == has access to application
  //   //cameraStatus.isDenied == does not have access to application, you can request again for the permission.
  //   //cameraStatus.isPermanentlyDenied == does not have access to application, you cannot request again for the permission.
  //   //cameraStatus.isRestricted == because of security/parental control you cannot use this permission.
  //   //cameraStatus.isUndetermined == permission has not asked before.

  //   if (!notificationStatus.isGranted) await Permission.notification.request();

  //   if (await Permission.notification.isGranted) {
  //   } else {
  //       Get.dialog(SimpleDialog(
  //         title: Text(
  //           "The app will not be able to send notification",
  //           style: TextStyle(fontWeight: FontWeight.bold),
  //         ),
  //         shape: RoundedRectangleBorder(
  //             borderRadius: new BorderRadius.circular(10.0)),
  //         children: [ 
  //         ]
  //       ));
  //   }
  // }

  /// Dispose method to close out and cleanup objects.
  @override
  void dispose() {
    super.dispose();
  }

  /// Initialize platform state.
  Future<void> initPlatformState() async {
    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: PermisisonChangeBuilder(
      permission: Permission.location,
      builder: (context, status) {
        if (status != PermissionStatus.granted) {
          return new Center(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(
                height: 150.0,
              ),
              Image.asset(
                'assets/images/denied.png',
                fit: BoxFit.cover,
              ),
              SizedBox(
                height: 30.0,
              ),
              Text(
                'You need to allow location to continue to use this app',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20.0,
                ),
              ),
              SizedBox(
                height: 30.0,
              ),
              ElevatedButton(
                  child:
                      Text("OK".toUpperCase(), style: TextStyle(fontSize: 14)),
                  style: ButtonStyle(
                      foregroundColor:
                          MaterialStateProperty.all<Color>(Colors.white),
                      backgroundColor:
                          MaterialStateProperty.all<Color>(Colors.red),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                              borderRadius: BorderRadius.zero,
                              side: BorderSide(color: Colors.red)))),
                  onPressed: () => AppSettings.openAppSettings())
            ],
          ));
        } else {
          return Center(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(
                height: 50.0,
              ),
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(30.0),
                    child: Text(
                      'Step 1 of 5',
                      style: TextStyle(
                          color: Colors.grey,
                          fontSize: 20.0,
                          fontFamily: 'RobotoMono'),
                    ),
                  )
                ],
              ),
              AnimatedTextKit(
                  pause: Duration(milliseconds: 5000),
                  totalRepeatCount: 1,
                  animatedTexts: [
                    TyperAnimatedText('Welcome to IAT \n Let\'s Start',
                        textStyle: TextStyle(
                            fontSize: 20.0, fontWeight: FontWeight.bold),
                        speed: Duration(milliseconds: 200)),
                  ]),
              SizedBox(
                height: 20.0,
              ),
              Image.asset(
                'assets/images/power_on.png',
                fit: BoxFit.cover,
              ),
              SizedBox(
                height: 30.0,
              ),
              Text(
                "Turn on your Gateway IAT Device",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 30.0,
                ),
              ),
              SizedBox(
                height: 30.0,
              ),
              ElevatedButton(
                style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.black),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18.0),
                    ))),
                child: Text(
                  'Continue',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
                onPressed: () {
                  // checkNotificationPermission();
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => Step2(),
                  ));
                },
              ),
            ],
          ));
        }
      },
    ));
  }
}
