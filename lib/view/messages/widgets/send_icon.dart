import 'dart:convert';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:chat/notification/notification_service.dart';
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
import 'package:http/http.dart';

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
  String token;
  String notMsg;
  String name;
  
  /*void startTimer() {
    int count = 30;
    const oneSec = const Duration(seconds: 1);
    _timer = new Timer.periodic(
      oneSec,
          (Timer timer) {
        if (count == 0) {
          setState(() {
            timer.cancel();
            //smartNotif();
          });
        } else {
          setState(() {
            count--;
          });
        }
      },
    );
  }*/
  /*void conditonalMethod(bool check){
    if(check == true){
      startTimer();
    }
    else{
      FlutterRingtonePlayer.playRingtone();
    }
  }*/


  /*void messageNotifData(bool message , String senderName){
    DocumentReference documentReference = Firestore.instance.collection("messageStatus").document(widget.friendId);
    Map<String , dynamic> userStatus = {
      "message": message,
      "messageSender": senderName,
    };
    documentReference.setData(userStatus).whenComplete(()
    {
      print("Message Notif Created");
    });
  }*/

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
            //messageNotifData(false,"");
          });
        }
      });
    });
  }


  void getUserId() async {
    final FirebaseUser user = await auth.currentUser();
    uid = user.uid;
    print("User Id : " + uid.toString());
    final firestoreInstance = Firestore.instance;
    firestoreInstance.collection("users").document(uid.toString()).get().then((value){
      name = value.data["name"];
      print("My Name : ${name}");
    });
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

  /*getToken(){
    final firestoreInstance = Firestore.instance;
    firestoreInstance.collection("userStatus").document(widget.friendId).get().then((value){
      token = value.data["token"];
      print(token);
    });
  }*/

  @override
  void initState() {
    //getToken();
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
              notMsg = widget.controller.text;
              createData("Online");
              //conditonalMethod(true);
              Firestore.instance.collection('users').document(widget.friendId).get().then((value){
                NotificationService().sendNotification([value.data['tokenId']], notMsg, "${name}");
              });
              /*sendNotification(['ewq8cBks23k:APA91bFWLTaAGR-qb63R2GjweoqLLsynWagYJYX5jd7DCY0T52nsY2cg7iBs8Nxd04TYSBv3Q7o47JdnW3dpq0jHy3pddadWkq_MSXgWZTVEupSuTKT7h4OZCQe3ZGPBwCX7oocRyHAI'],
                  widget.controller.text,
                  widget.myName);*/
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
              //messageNotifData(true,widget.myName);
              /*DocumentReference documentReference = Firestore.instance.collection("messageStatus").document(widget.friendId);
              Map<String , dynamic> userStatus = {
                "message": false,
                "messageSender": widget.myName,
              };
              documentReference.setData(userStatus).whenComplete(()
              {
                print("Message Notif Created");
              });*/
              BlocProvider.of<MessagesBloc>(context).add(
                  MessageSent(message: widget.controller.text, friendId: widget.friendId));
          /*Timer(Duration(seconds: 1),(){
            widget.getSuggestedReplies();
          });*/
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