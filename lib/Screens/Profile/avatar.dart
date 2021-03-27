import 'package:flutter/material.dart';
import 'package:flutter_maps/Services/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';

class Avatar extends StatelessWidget {
  final String avatarUrl;
  final Function onTap;

  const Avatar({this.avatarUrl, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: onTap,
        child: Center(
          child: avatarUrl == null
              ? CircleAvatar(
                  radius: kSpacingUnit.w * 5,
                  backgroundColor: Colors.lightGreen[100],
                  child: Icon(
                    Icons.photo_camera,
                    color: Colors.black,
                  ),
                )
              : Stack(children: <Widget>[
                  CircleAvatar(
                    backgroundColor: Colors.transparent,
                    radius: kSpacingUnit.w * 5,
                    child: ClipOval(
                      child: Image.network(
                        avatarUrl,
                        width: 200,
                        height: 200,
                        fit: BoxFit.cover,
                        loadingBuilder: (BuildContext context, Widget child,
                            ImageChunkEvent loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes
                                  : null,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  // Align(
                      // alignment: Alignment.center,
                      // child: Container(
                      //     height: kSpacingUnit.w * 2.5,
                      //     width: kSpacingUnit.w * 2.5,
                      //     decoration: BoxDecoration(
                      //       color: Colors.yellow,
                      //       shape: BoxShape.circle,
                      //     ),
                      //     child: Center(
                      //       heightFactor: kSpacingUnit.w * 1.5,
                      //       widthFactor: kSpacingUnit.w * 1.5,
                      //       child: Icon(
                      //         Icons.photo_camera,
                      //         color: kDarkPrimaryColor,
                      //         size: ScreenUtil().setSp(kSpacingUnit.w * 1.5),
                      //       ),
                      //     )))
                ]),
        ));
  }
}
