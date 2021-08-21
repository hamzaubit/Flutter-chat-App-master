import 'dart:async';

import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:chat/models/user.dart';
import 'package:chat/view/utils/device_config.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import 'call.dart';

class IndexPage extends StatefulWidget {
  const IndexPage({@required this.friendId});
  final String friendId;
  @override
  State<StatefulWidget> createState() => IndexState();
}

class IndexState extends State<IndexPage> {
  /// create a channelController to retrieve text value
  final _channelController = TextEditingController(text: "SmartChat");

  /// if channel textField is validated to have error
  bool _validateError = false;
  String FriendName;

  ClientRole _role = ClientRole.Broadcaster;
  @override
  void dispose() {
    // dispose input controller
    _channelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final deviceData = DeviceData.init(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF4B0082),
        title: Text('Video Calling'),
        centerTitle: true,
      ),
      body: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          height: 400,
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  /*Expanded(
                      child: TextField(
                        controller: _channelController,
                        decoration: InputDecoration(
                          errorText:
                          _validateError ? 'Channel name is mandatory' : null,
                          border: UnderlineInputBorder(
                            borderSide: BorderSide(width: 1),
                          ),
                          hintText: 'Channel name',
                        ),
                      ))*/
                ],
              ),
              Column(
                children: [
                  ListTile(
                    title: Text(ClientRole.Broadcaster.toString(),style: TextStyle(color: Colors.white),),
                    leading: Radio(
                      value: ClientRole.Broadcaster,
                      groupValue: _role,
                      activeColor: Colors.white,
                      onChanged: (ClientRole value) {
                        setState(() {
                          _role = value;
                        });
                      },
                    ),
                  ),
                  /*ListTile(
                    title: Text(ClientRole.Audience.toString()),
                    leading: Radio(
                      value: ClientRole.Audience,
                      groupValue: _role,
                      onChanged: (ClientRole value) {
                        setState(() {
                          _role = value;
                        });
                      },
                    ),
                  )*/
                ],
              ),
              StreamBuilder(
                  stream: Firestore.instance.collection('callingNotif').document(widget.friendId).snapshots(),
                  builder: (context, snapshot){
                    if(!snapshot.hasData){
                      var userDocument = snapshot.data;
                      FriendName = userDocument['callerName'];
                      return Text(userDocument['callerName'].toString(),style: TextStyle(fontSize: deviceData.screenWidth * 0.05,color: Color(0xFF4B0082)),);
                    }
                    var userDocument = snapshot.data;
                    FriendName = userDocument['callerName'];
                    return Text(userDocument['callerName'].toString(),style: TextStyle(fontSize: deviceData.screenWidth * 0.05,color: Color(0xFF4B0082)),);
                  }
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 80),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: ElevatedButton(
                        onPressed: (){
                          DocumentReference documentReference = Firestore.instance.collection("callingNotif").document(widget.friendId);
                          Map<String , dynamic> userStatus = {
                            "videoCall": true,
                            "callerName": FriendName,
                            "audioCall": false,
                          };
                          documentReference.setData(userStatus).whenComplete(()
                          {
                            print("Call Status Created");
                          });
                          onJoin();
                        },
                        child: Text('Start Video Calling'),
                        style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(Color(0xFF4B0082)),
                            foregroundColor: MaterialStateProperty.all(Colors.white)
                        ),
                      ),
                    ),
                    // Expanded(
                    //   child: RaisedButton(
                    //     onPressed: onJoin,
                    //     child: Text('Join'),
                    //     color: Colors.blueAccent,
                    //     textColor: Colors.white,
                    //   ),
                    // )
                  ],
                ),
              ),
              GestureDetector(
                onTap: (){
                  Navigator.pop(context);
                },
                child: Container(
                  height: deviceData.screenHeight * 0.07,
                  width: deviceData.screenWidth * 0.15,
                  decoration: BoxDecoration(
                      color: Color(0xFF4B0082),
                      borderRadius: BorderRadius.only(bottomRight: Radius.circular(25),topLeft: Radius.circular(25),bottomLeft: Radius.circular(25),topRight: Radius.circular(25))
                  ),
                  child: Icon(Icons.cancel,color: Colors.white,size: deviceData.screenWidth * 0.1,),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  Future<void> onJoin() async {
    // update input validation
    setState(() {
      _channelController.text.isEmpty
          ? _validateError = true
          : _validateError = false;
    });
    if (_channelController.text.isNotEmpty) {
      // await for camera and mic permissions before pushing video page
      await _handleCameraAndMic(Permission.camera);
      await _handleCameraAndMic(Permission.microphone);
      // push video page with given channel name
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CallPage(
            channelName: _channelController.text,
            role: _role,
          ),
        ),
      );
    }
  }

  Future<void> _handleCameraAndMic(Permission permission) async {
    final status = await permission.request();
    print(status);
  }
}