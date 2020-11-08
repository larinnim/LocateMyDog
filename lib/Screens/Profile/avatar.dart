import 'package:flutter/material.dart';
import 'package:flutter_maps/Services/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
            ?
            // ClipRRect(
            //     borderRadius: BorderRadius.circular(kSpacingUnit.w * 5,),
            //     child:Icon(Icons.photo_camera)
            // ) :
            // ClipRRect(
            //   borderRadius: BorderRadius.circular(kSpacingUnit.w * 5,),
            //   child:  Image.network(avatarUrl, loadingBuilder:
            //               (BuildContext context, Widget child,
            //                   ImageChunkEvent loadingProgress) {
            //             if (loadingProgress == null) return child;
            //             return Center(
            //               child: CircularProgressIndicator(
            //                 value: loadingProgress.expectedTotalBytes != null
            //                     ? loadingProgress.cumulativeBytesLoaded /
            //                         loadingProgress.expectedTotalBytes
            //                     : null,
            //               ),
            //             );
            //           }),
            // )
            // CircleAvatar(
            //     radius: kSpacingUnit.w * 5,
            //     child: Icon(Icons.photo_camera),
            //   )
            // : CircleAvatar(
            //     radius: kSpacingUnit.w * 5,
            //     backgroundImage:
            //      NetworkImage(avatarUrl),
            //   ),
             CircleAvatar(
                radius: kSpacingUnit.w * 5,
                child: Icon(Icons.photo_camera),
              )
            : CircleAvatar(
              backgroundColor: Colors.transparent,
                radius: kSpacingUnit.w * 5,
                child: ClipOval(
                    child: Image.network(
                      avatarUrl, width: 100,
                height: 100,
                fit: BoxFit.cover,loadingBuilder:
                (BuildContext context, Widget child,
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
              //   backgroundImage:
              //    NetworkImage(avatarUrl),
              // ),
      ),
    );
  }
}
