import 'package:chat/utils/functions.dart';
import 'package:chat/view/widgets/popup_menu.dart';
import 'package:chat/view/utils/constants.dart';
import 'package:flutter/material.dart';

import 'package:chat/models/user.dart';
import 'package:chat/view/messages/widgets/back_icon.dart';
import 'package:chat/view/utils/device_config.dart';
import 'package:chat/view/widgets/avatar_icon.dart';

class MessagesHeader extends StatelessWidget {
  final User friend;
  const MessagesHeader({Key key, @required this.friend}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final deviceData = DeviceData.init(context);

    return Padding(
      padding: EdgeInsets.only(
        top: deviceData.screenHeight * 0.06,
        bottom: deviceData.screenHeight * 0.005,
        left: deviceData.screenWidth * 0.05,
        right: deviceData.screenWidth * 0.05,
      ),
      child: Row(
        //mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          BackIcon(),
          Row(
            children: [
              AvatarIcon(
                user: friend,
                radius: 0.05,
              ),
              SizedBox(width: deviceData.screenWidth * 0.025),
              Column(
                children: [
                  Text(
                    Functions.getFirstName(friend.name),
                    style: kArialFontStyle.copyWith(
                      fontSize: deviceData.screenHeight * 0.022,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: deviceData.screenHeight * 0.001),
                  Text(
                    "Online",
                    style: kArialFontStyle.copyWith(
                      fontSize: deviceData.screenHeight * 0.014,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),

          SizedBox(width: deviceData.screenWidth * 0.22),
          Container(
            width: deviceData.screenHeight * 0.05,
            height: deviceData.screenHeight * 0.05,
            decoration: ShapeDecoration(
              shape: CircleBorder(),
              color: Colors.white,
            ),
            child: Icon(
            Icons.phone,
            color: Color(0xFF4B0082),
            size: deviceData.screenWidth * 0.058,
          ),
          ),
          SizedBox(width: deviceData.screenWidth * 0.020),
          PopUpMenu(),
        ],
      ),
    );
  }
}
