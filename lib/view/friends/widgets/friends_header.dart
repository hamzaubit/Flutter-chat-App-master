import 'dart:async';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:chat/AudioCall/audioIndex.dart';
import 'package:chat/models/user.dart';
import 'package:chat/videoCall/index.dart';
import 'package:chat/videoCall/settings.dart';
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
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:intl/intl.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

class FriendsHeader extends StatefulWidget {
  const FriendsHeader({
    Key key,
    @required this.editForm,
    @required this.onBackPressed,
    @required this.onAvatarPressed,
    @required this.friend,
  }) : super(key: key);
  final User friend;
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
  String MyName;

  void _getTime() {
    final DateTime now = DateTime.now();
    final String formattedDateTime = _formatDateTime(now);
    setState(() {
      _timeString = formattedDateTime;
    });
  }

  /*void hearRain() async {
    DocumentReference documentReference = Firestore.instance.collection("heartStatus").document(uid);
    Map<String , dynamic> userStatus = {
      "heartValue": "",
    };
    documentReference.setData(userStatus).whenComplete(()
    {
      print("Heart Created");
    });
  }*/

  /*callingNotif(String callerName) async {
    DocumentReference documentReference = Firestore.instance.collection("callingNotif").document(uid);
    Map<String , dynamic> userStatus = {
      "videoCall": false,
      "callerName": callerName,
      "audioCall": false,
    };
    documentReference.setData(userStatus).whenComplete(()
    {
      print("Call Status Created");
    });
  }*/

  String _formatDateTime(DateTime dateTime) {
    return DateFormat('h:mm a | d MMM').format(dateTime);
  }

  void _startTimer(String status) async {

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
          //hearRain();
          DocumentReference documentReference = Firestore.instance.collection("userStatus").document(uid);
          Map<String , dynamic> userStatus = {
            "status": status,
            "token": fcmToken,
          };
          documentReference.setData(userStatus).whenComplete(()
          {
            print("Status Created");
          });
          //messageStatusCollection();
        }
      });
    });
  }

  void getUserId() async {
    final FirebaseUser user = await auth.currentUser();
    uid = user.uid;
    print("User Id : "+uid.toString());
  }

  updateData(String status){
    final firestoreInstance = Firestore.instance;
    firestoreInstance
    .collection("userStatus").document(uid).updateData(
        {"status": status,}).then((_) {
          print("Status Updated");
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
  /*void notifyMessage(String senderName) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 1,
        channelKey: "key1",
        title: "Smart Chat",
        body: "Message From $senderName",
        displayOnBackground: true,
      ),
    );
  }*/
  /*void messageStatusCollection() async {
    DocumentReference documentReference = Firestore.instance.collection("messageStatus").document(uid);
    Map<String , dynamic> userStatus = {
      "message": false,
      "messageSender": "",
    };
    documentReference.setData(userStatus).whenComplete(()
    {
      print("Status Created");
    });
  }*/

  void callingToken(){

    final firestoreInstance = Firestore.instance;
    var firebaseUser =  FirebaseAuth.instance.currentUser;
    firestoreInstance.collection("callingToken").document("R0XURwLutS9c3dRQd5Jr").get().then((value){
      CallToken.APP_ID = "${value.data['appID']}";
      CallToken.Token = "${value.data['token']}";
      print("${value.data['token']}");
      print(value.data);
    });
  }
  void initState(){
    callingToken();
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
      updateData("Online");
    }
    else{
      updateData(_timeString.toString());
    }
  }

  @override
  void dispose(){
    updateData("Offline");
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
          /*uid == null ? Container() :
          StreamBuilder(
              stream: Firestore.instance.collection('messageStatus').document(uid).snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Container();
                }
                var userDocument = snapshot.data;
                if(userDocument['message'] == true){
                  notifyMessage(userDocument['messageSender']);
                  FlutterRingtonePlayer.playNotification();
                  DocumentReference documentReference = Firestore.instance.collection("messageStatus").document(uid);
                  Map<String , dynamic> userStatus = {
                    "message": false,
                    "messageSender": userDocument['messageSender'],
                  };
                  documentReference.setData(userStatus).whenComplete(()
                  {
                    print("Status Created");
                  });
                  return Container();
                }
                return Container();
              }),*/
          /* uid == null ? Container() : StreamBuilder(
              stream: Firestore.instance.collection('users').document(uid).snapshots(),
              builder: (context, snapshot){
                if (!snapshot.hasData) {
                  return Container();
                }
                var userDocument = snapshot.data;
                MyName = userDocument['name'];
                print(MyName);
                callingNotif(MyName);
                return Container();
              }
          ),*/
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              GestureDetector(
                onTap: (){
                  FlutterRingtonePlayer.stop();
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
