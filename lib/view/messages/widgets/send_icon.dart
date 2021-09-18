import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:chat/view/messages/bloc/messages_bloc.dart';
import 'package:chat/view/utils/constants.dart';
import 'package:chat/view/utils/device_config.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:intl/intl.dart';
import 'dart:async';

class SendIcon extends StatefulWidget {

  const SendIcon({
    Key key,
    @required this.controller,
    @required this.friendId,
    @required this.myName, this.getSuggestedReplies,
    @required this.friendName,
  }) : super(key: key);

  final Function  getSuggestedReplies;
  final TextEditingController controller;
  final String friendId;
  final String myName;
  final String friendName;

  @override
  _SendIconState createState() => _SendIconState();
}

class _SendIconState extends State<SendIcon>  with WidgetsBindingObserver {
  bool changeStatus = true;
  String uid;
  final FirebaseAuth auth = FirebaseAuth.instance;
  int _counter = 1;
  Timer _timer;
  String _timeString;
  String fcmToken;
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  int _start = 10;

  void startTimer() {
    int count = 30;
    const oneSec = const Duration(seconds: 1);
    _timer = new Timer.periodic(
      oneSec,
          (Timer timer) {
        if (count == 0) {
          setState(() {
            timer.cancel();
            smartNotif();
          });
        } else {
          setState(() {
            count--;
          });
        }
      },
    );
  }
  void conditonalMethod(bool check){
    if(check == true){
      startTimer();
    }
    else{
      FlutterRingtonePlayer.playRingtone();
    }
  }


  void messageNotifData(bool message , String senderName){
    DocumentReference documentReference = Firestore.instance.collection("messageStatus").document(widget.friendId);
    Map<String , dynamic> userStatus = {
      "message": message,
      "messageSender": senderName,
    };
    documentReference.setData(userStatus).whenComplete(()
    {
      print("Message Notif Created");
    });
  }

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
          DocumentReference documentReference =
          Firestore.instance.collection("userStatus").document(uid);
          Map<String, dynamic> userStatus = {
            "status": status,
            "token": fcmToken,
          };
          documentReference.setData(userStatus).whenComplete(() {
            print("Status Created");
            messageNotifData(false,"");
          });
        }
      });
    });
  }

  void smartNotif() async {
    FlutterRingtonePlayer.playNotification();
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 1,
        channelKey: "key1",
        title: "${widget.friendName}",
        body: "I Am Busy Right Now, Talk To You Later.",
      ),
    );
  }

  void getUserId() async {
    final FirebaseUser user = await auth.currentUser();
    uid = user.uid;
    print("User Id : " + uid.toString());
  }

  createData(String status) {
    print("Created");
    DocumentReference documentReference =
    Firestore.instance.collection("userStatus").document(uid);
    Map<String, dynamic> userStatus = {
      "status": status,
      "token": fcmToken,
    };
    documentReference.setData(userStatus).whenComplete(() {
      print("Status Created");
    });
  }
  @override
  void initState() {
    _firebaseMessaging.getToken().then((token) {
      fcmToken = token;
      print("My Token :" + fcmToken);
    });
    _timeString = _formatDateTime(DateTime.now());
    Timer.periodic(Duration(seconds: 1), (Timer t) => _getTime());
    WidgetsBinding.instance.addObserver(this);
    getUserId();
    WidgetsBinding.instance.addPostFrameCallback((_) => _startTimer("Online"));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final deviceData = DeviceData.init(context);
    return Expanded(
      child: Container(
        padding: EdgeInsets.only(
            top: deviceData.screenHeight * 0.01,
            bottom: deviceData.screenHeight * 0.01,
            right: deviceData.screenWidth * 0.04),
        child: InkResponse(
          child: Icon(
            Icons.send,
            color: kBackgroundButtonColor,
            size: deviceData.screenWidth * 0.07,
          ),
          onTap: () async {
            if (widget.controller.text.trim().isNotEmpty) {
              createData("Online");
              conditonalMethod(true);
              /*final firestoreInstance = Firestore.instance;
              firestoreInstance.collection("messageStatus").document(uid).get().then((value){
                if(value.data["message"] == true){
                  conditonalMethod(false);
                }
                else
                {
                  print(value.data);
                }
              });*/
              messageNotifData(true,widget.myName);
              DocumentReference documentReference = Firestore.instance.collection("messageStatus").document(widget.friendId);
              Map<String , dynamic> userStatus = {
                "message": false,
                "messageSender": widget.myName,
              };
              documentReference.setData(userStatus).whenComplete(()
              {
                print("Message Notif Created");
              });
              BlocProvider.of<MessagesBloc>(context).add(
                  MessageSent(message: widget.controller.text, friendId: widget.friendId));
          Timer(Duration(seconds: 1),(){
            widget.getSuggestedReplies();
          });
              /*Timer(Duration(seconds: 20),(){
                smartNotif();
              });*/
            }
          },
        ),
      ),
    );
  }
}