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
            ? CircleAvatar(
                radius: kSpacingUnit.w * 5,
                child: Icon(Icons.photo_camera),
              )
            : CircleAvatar(
                radius: kSpacingUnit.w * 5,
                backgroundImage: NetworkImage(avatarUrl),
              ),
      ),
    );
  }
}
