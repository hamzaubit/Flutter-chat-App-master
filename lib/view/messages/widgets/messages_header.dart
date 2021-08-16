import 'package:chat/AudioCall/audioIndex.dart';
import 'package:chat/utils/functions.dart';
import 'package:chat/videoCall/index.dart';
import 'package:chat/view/widgets/popup_menu.dart';
import 'package:chat/view/utils/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:chat/models/user.dart';
import 'package:chat/view/messages/widgets/back_icon.dart';
import 'package:chat/view/utils/device_config.dart';
import 'package:chat/view/widgets/avatar_icon.dart';

class MessagesHeader extends StatefulWidget {
  final User friend;
  const MessagesHeader({Key key, @required this.friend,}) : super(key: key);

  @override
  _MessagesHeaderState createState() => _MessagesHeaderState();
}

class _MessagesHeaderState extends State<MessagesHeader> {
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
                user: widget.friend,
                radius: 0.05,
              ),
              SizedBox(width: deviceData.screenWidth * 0.015),
              Column(
                children: [
                  Text(
                    Functions.getFirstName(widget.friend.name),
                    style: kArialFontStyle.copyWith(
                      fontSize: deviceData.screenHeight * 0.022,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: deviceData.screenHeight * 0.003),
                  StreamBuilder(
                      stream: Firestore.instance.collection('userStatus').document(widget.friend.userId).snapshots(),
                      builder: (context, snapshot){
                        if(!snapshot.hasData){
                          var userDocument = snapshot.data;
                          Text(userDocument['status'], style: kArialFontStyle.copyWith( fontSize: deviceData.screenHeight * 0.014, color: Colors.white, ), );
                        }
                        var userDocument = snapshot.data;
                        return Text(userDocument['status'], style: kArialFontStyle.copyWith( fontSize: deviceData.screenHeight * 0.014, color: Colors.white, ), );
                      }
                  ),
                ],
              ),
            ],
          ),
          SizedBox(width: deviceData.screenWidth * 0.12),
          GestureDetector(
            onTap: (){
              Navigator.push(context, MaterialPageRoute(builder: (context) => audioIndexPage()));
            },
            child: Container(
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
          ),
          SizedBox(width: deviceData.screenWidth * 0.020),
          GestureDetector(
            onTap: (){
              Navigator.push(context, MaterialPageRoute(builder: (context) => IndexPage()));
            },
            child: Container(
              width: deviceData.screenHeight * 0.05,
              height: deviceData.screenHeight * 0.05,
              decoration: ShapeDecoration(
                shape: CircleBorder(),
                color: Colors.white,
              ),
              child: Icon(
                Icons.video_call,
                color: Color(0xFF4B0082),
                size: deviceData.screenWidth * 0.058,
              ),
            ),
          ),
          //PopUpMenu(),
        ],
      ),
    );
  }
}
