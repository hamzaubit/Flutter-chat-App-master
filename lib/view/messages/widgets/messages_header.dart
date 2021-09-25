import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:chat/AudioCall/audioIndex.dart';
import 'package:chat/utils/functions.dart';
import 'package:chat/videoCall/index.dart';
import 'package:chat/view/messages/widgets/profileScreen.dart';
import 'package:chat/view/widgets/popup_menu.dart';
import 'package:chat/view/utils/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:chat/models/user.dart';
import 'package:chat/view/messages/widgets/back_icon.dart';
import 'package:chat/view/utils/device_config.dart';
import 'package:chat/view/widgets/avatar_icon.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';

class MessagesHeader extends StatefulWidget {
  final User friend;
  const MessagesHeader({Key key, @required this.friend}) : super(key: key);

  @override
  _MessagesHeaderState createState() => _MessagesHeaderState();
}

class _MessagesHeaderState extends State<MessagesHeader> {
  String MyName;

  String uid;
  final FirebaseAuth auth = FirebaseAuth.instance;

  void getUserId() async {
    final FirebaseUser user = await auth.currentUser();
    uid = user.uid;
    print("User Id is : "+uid.toString());
  }
  @override
  void initState() {
    getUserId();
    super.initState();
  }
  /*void smartNotif(String smartMsg) async {
    FlutterRingtonePlayer.playNotification();
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 1,
        channelKey: "key1",
        title: widget.friend.name,
        body: "I am ${smartMsg} talk to you later",
      ),
    );
  }*/

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
              GestureDetector(
                onTap: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context) => profileScreen(
                    name: widget.friend.name,
                    img: widget.friend.imgUrl,
                    email: widget.friend.email,
                  )));
                },
                child: AvatarIcon(
                  user: widget.friend,
                  radius: 0.05,
                ),
              ),
              SizedBox(width: deviceData.screenWidth * 0.015),
              Column(
                children: [
                  /*uid == null
                      ? Container()
                      : StreamBuilder(
                      stream: Firestore.instance
                          .collection('users')
                          .document(uid)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return Container();
                        }
                        var userDocument = snapshot.data;
                        MyName = userDocument['name'];
                        print("Mera Naam Yeh Hai : ${MyName}");
                        return Container();
                      }),*/
                  GestureDetector(
                    onTap: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context) => profileScreen(
                        name: widget.friend.name,
                        img: widget.friend.imgUrl,
                        email: widget.friend.email,
                      )));
                    },
                    child: Text(
                      Functions.getFirstName(widget.friend.name),
                      style: kArialFontStyle.copyWith(
                        fontSize: deviceData.screenHeight * 0.022,
                        color: Colors.white,
                      ),
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
                        /*if(userDocument['status'] != "Online" && userDocument['status'] != "Typing..."){
                          smartNotif("Busy Right Now");
                        }*/
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
              Navigator.push(context, MaterialPageRoute(builder: (context) => audioIndexPage(
                friendId: widget.friend.userId,
              )));
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
              Navigator.push(context, MaterialPageRoute(builder: (context) => IndexPage(friendId: widget.friend.userId,)));
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