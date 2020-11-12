import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_test/flutter_test.dart';

class Step1 extends StatefulWidget {
   @override
  _Step1State createState() => new _Step1State();
}
class _Step1State extends State<Step1> {
  String _scanBarcode = 'Unknown';

  @override
  initState() {
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Material(
              type: MaterialType.transparency,
          child: new Container(
        decoration: BoxDecoration(color: Colors.white),
        child: 
        SafeArea(
          child: Padding(  padding:
                        EdgeInsets.symmetric(horizontal: 28.0, vertical: 40.0),
                    child: Column(
                      children: <Widget>[ 
                Row(
                children: [
                  Text('Step 1 of 3',
                style: TextStyle(color: Colors.grey, fontSize: 20.0, fontFamily: 'RobotoMono'),)
                ],
              ),
              SizedBox(height: 20.0,),
                Row(
                children: [
                  Text('Scan QR Code',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30.0, fontFamily: 'RobotoMono'),)
                ],
              ),
              Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: RaisedButton(
                    color: Colors.blue,
                    textColor: Colors.white,
                    splashColor: Colors.blueGrey,
                    onPressed: scanQR,
                    // onPressed: ,

                    child: const Text('START CAMERA SCAN')
                ),
              )
              ,
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Text(_scanBarcode, textAlign: TextAlign.center,),
              )
              ,
            ],
          ),
        ]),
        )
      ),
    ));
  }
  Future<void> scanQR() async {
    String barcodeScanRes;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          "#ff6666", "Cancel", true, ScanMode.QR);
      print(barcodeScanRes);
    } on PlatformException {
      barcodeScanRes = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _scanBarcode = barcodeScanRes;
    });
  }
}


 
