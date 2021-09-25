import 'dart:async';

import 'package:chat/models/user.dart';
import 'package:chat/view/utils/constants.dart';
import 'package:chat/view/utils/device_config.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smart_reply/smart_reply.dart';

class MessageInput extends StatefulWidget {
  final User friend;

  const MessageInput({
    Key key,
    @required this.controller,
    @required this.friend,
  }) : super(key: key);

  final TextEditingController controller;

  @override
  _MessageInputState createState() => _MessageInputState();
}

class _MessageInputState extends State<MessageInput>
    with WidgetsBindingObserver {

  bool changeStatus = true;
  String uid;
  final FirebaseAuth auth = FirebaseAuth.instance;
  int _counter = 1;
  Timer _timer;
  String _timeString;
  String fcmToken;
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

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
          final firestoreInstance = Firestore.instance;
          firestoreInstance
              .collection("userStatus").document(uid).updateData(
              {"status": status,}).then((_) {
            print("Status Updated");
          });
        }
      });
    });
  }

  void getUserId() async {
    final FirebaseUser user = await auth.currentUser();
    uid = user.uid;
    print("User Id : " + uid.toString());
  }

  createData(String status) {
    final firestoreInstance = Firestore.instance;
    firestoreInstance
        .collection("userStatus").document(uid).updateData(
        {"status": status,}).then((_) {
      print("Status Updated");
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
  /*void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      //createData("Online");
      print("Online");
    } else {
      createData(_timeString.toString());
    }
  }*/

  @override
  Widget build(BuildContext context) {
    final deviceData = DeviceData.init(context);
    return Material(
      elevation: 3.9,
      borderRadius: BorderRadius.all(
        Radius.circular(deviceData.screenWidth * 0.05),
      ),
      child: Container(
        width: deviceData.screenWidth * 0.70,
        child: TextField(
          textCapitalization: TextCapitalization.sentences,
          controller: widget.controller,
          keyboardType: TextInputType.multiline,
          maxLines: null,
          textInputAction: TextInputAction.newline,
          cursorColor: kBackgroundColor,
          onChanged: (value) {
            if (value.isNotEmpty) {
              print("I m typing...");
              createData("Typing...");
            } else if (value.isEmpty) {
              createData("Online");
            }
          },
          style: TextStyle(
            color: Colors.indigo[900],
            fontSize: deviceData.screenHeight * 0.018,
          ),
          decoration: InputDecoration(
            isDense: true,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.all(
                  Radius.circular(deviceData.screenWidth * 0.05)),
            ),
            hintText: "Type your message",
            hintStyle: TextStyle(color: Colors.indigo[900]),
          ),
        ),
      ),
    );
  }
}
