import 'dart:async';
import 'package:chat/view/friends/widgets/avatar_button.dart';
import 'package:chat/view/friends/widgets/back_icon.dart';
import 'package:chat/view/messages/widgets/message_input.dart';
import 'package:chat/view/widgets/popup_menu.dart';
import 'package:chat/view/friends/widgets/search_widget.dart';
import 'package:chat/view/utils/constants.dart';
import 'package:chat/view/utils/device_config.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class FriendsHeader extends StatefulWidget {
  const FriendsHeader({
    Key key,
    @required this.editForm,
    @required this.onBackPressed,
    @required this.onAvatarPressed,
  }) : super(key: key);

  final bool editForm;
  final Function onBackPressed;
  final Function onAvatarPressed;

  @override
  _FriendsHeaderState createState() => _FriendsHeaderState();
}

class _FriendsHeaderState extends State<FriendsHeader> with WidgetsBindingObserver {

  bool changeStatus = true;
  String uid;
  final FirebaseAuth auth = FirebaseAuth.instance;
  int _counter = 1;
  Timer _timer;
  String _timeString;
  String fcmToken;
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  String oneSignalAppId = "36ea0ab1-4b23-4a4a-b5f0-c78ef4dc76b5";

  void _getTime() {
    final DateTime now = DateTime.now();
    final String formattedDateTime = _formatDateTime(now);
    setState(() {
      _timeString = formattedDateTime;
    });
  }
  String _formatDateTime(DateTime dateTime) {
    return DateFormat('h:mm a | d MMM').format(dateTime);
  }

  void _startTimer(String status) {
    _counter = 1;
    if (_timer != null) {
      _timer.cancel();
    }
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_counter > 0) {
          _counter--;
        } else {
          _timer.cancel();
          print("Created");
          //fcmTokenForNotification(fcmToken);
          DocumentReference documentReference = Firestore.instance.collection("userStatus").document(uid);
          Map<String , dynamic> userStatus = {
            "status": status,
            "token": fcmToken,
          };
          documentReference.setData(userStatus).whenComplete(()
          {
            print("Status Created");
          });
        }
      });
    });
  }

  void getUserId() async {
    final FirebaseUser user = await auth.currentUser();
    uid = user.uid;
    print("User Id : "+uid.toString());
  }

  createData(String status){
    DocumentReference documentReference = Firestore.instance.collection("userStatus").document(uid);
    Map<String , dynamic> userStatus = {
      "status": status,
      "token": fcmToken,
    };
    documentReference.setData(userStatus).whenComplete(()
    {
      print("Status Created");
    });
  }
  /*fcmTokenForNotification(String status){
    DocumentReference documentReference = Firestore.instance.collection("userStatus").document(uid);
    Map<String , dynamic> userStatus = {
      "token": fcmToken,
    };
    documentReference.setData(userStatus).whenComplete(()
    {
      print("Token Created");
    });
  }*/
  /*void configOneSignel()
  {
    OneSignal.shared
        .setAppId(oneSignalAppId);
  }*/

  void initState(){
    //configOneSignel();
    _firebaseMessaging.getToken().then((token){
      fcmToken = token;
      print("My Token :" +fcmToken);
    });
    _timeString = _formatDateTime(DateTime.now());
    Timer.periodic(Duration(seconds: 1), (Timer t) => _getTime());
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    getUserId();
    WidgetsBinding.instance.addPostFrameCallback((_) => _startTimer("Online"));
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if(state == AppLifecycleState.resumed){
      createData("Online");
    }
    else{
      createData(_timeString.toString());
    }
  }

  @override
  void dispose(){
    createData("Offline");
  }

  @override
  Widget build(BuildContext context) {
    final deviceData = DeviceData.init(context);
    return Padding(
      padding: EdgeInsets.only(
        top: deviceData.screenHeight * 0.07,
        left: deviceData.screenWidth * 0.08,
        right: deviceData.screenWidth * 0.08,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              GestureDetector(
                onTap: (){
                },
                child: Text(
                  "Let's Chat \nwith SmartChat",
                  style: kTitleTextStyle.copyWith(
                    fontSize: deviceData.screenHeight * 0.028,
                  ),
                ),
              ),
              PopUpMenu(),
            ],
          ),
          SizedBox(height: deviceData.screenHeight * 0.02),
          Container(
            height: deviceData.screenHeight * 0.06,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                AnimatedSwitcher(
                  duration: Duration(milliseconds: 300),
                  child: widget.editForm
                      ? BackIcon(
                          onPressed: () =>
                              widget.onBackPressed != null ? widget.onBackPressed() : null)
                      : SearchWidget(),
                ),
                AvatarButton(
                  onPressed: () =>
                      widget.onAvatarPressed != null ? widget.onAvatarPressed() : null,
                ),
              ],
            ),
          ),
          SizedBox(height: deviceData.screenHeight * 0.015),
        ],
      ),
    );
  }
}
