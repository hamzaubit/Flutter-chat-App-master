import 'dart:async';
import 'dart:math';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:chat/models/message.dart';
import 'package:chat/models/user.dart';
import 'package:chat/utils/functions.dart';
import 'package:chat/view/messages/bloc/messages_bloc.dart';
import 'package:chat/view/messages/widgets/message_input.dart';
import 'package:chat/view/messages/widgets/message_item.dart';
import 'package:chat/view/messages/widgets/send_icon.dart';
import 'package:chat/view/utils/constants.dart';
import 'package:chat/view/utils/device_config.dart';
import 'package:chat/view/widgets/progress_indicator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:image_picker/image_picker.dart';
import "dart:io";

import 'package:smart_reply/smart_reply.dart';

import 'mediaScreen.dart';

class MessagesList extends StatefulWidget {
  final User friend;

  MessagesList({
    @required this.friend,
  });

  @override
  _MessagesListState createState() => _MessagesListState();
}

class _MessagesListState extends State<MessagesList> {
  User user;
  TextEditingController _textController;
  List<Message> messages;
  ScrollController _scrollController = ScrollController();
  bool noMoreMessages = false;
  File smapleImage;
  var url;
  String uid;
  int _counter = 1;
  Timer _timer;
  String _timeString;
  String fcmToken;
  bool heartRain = false;
  String MyName;
  List<String> _suggestedReplies = [];
  List<String> getLastMsg = [];
  String token;
  bool isSpeaking = false;

  // Platform messages are asynchronous, so we initialize in an async method.

  List<TextMessage> textMessageLists = [];

  Future<void> getSuggestedReplies() async {
    textMessageLists = [];
    for (int i = 0; i < messages.length; i++) {
      textMessageLists.add(TextMessage(
          text: messages[i].message,
          isLocalUser: false,
          timestamp: DateTime.now(),
          userId: uid));
    }

    for (int i = 0; i < textMessageLists.length; i++) {
      print(textMessageLists[i].text);
    }

    print('Message',);

    textMessageLists = [textMessageLists[0]];

    print(textMessageLists[0].text);

    SmartReply.suggestReplies(textMessageLists).then((replies) {
      print(replies);
      setState(() {
        _suggestedReplies = replies;
      });
    });
    print(_suggestedReplies);
  }

  final FirebaseAuth auth = FirebaseAuth.instance;

  void getUserId() async {
    final FirebaseUser user = await auth.currentUser();
    uid = user.uid;
    print("User Id : " + uid.toString());
    print("Friend Id : " + widget.friend.userId);
  }

  /*void hearRain(bool heartRain) async {
    DocumentReference documentReference =
    Firestore.instance.collection("heartStatus").document(uid);
    Map<String, dynamic> userStatus = {
      "heartValue": heartRain,
    };
    documentReference.setData(userStatus).whenComplete(() {
      print("Heart Created");
    });
  }*/

  @override
  void initState() {
    getUserId();
    _textController = TextEditingController();
    _scrollController = ScrollController();
    _scrollController.addListener(() => _scrollListener());
    WidgetsBinding.instance.addPostFrameCallback((_) => _startTimer());
    super.initState();
  }

  void _scrollListener() {
    if (_scrollController.offset >=
        _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange &&
        !noMoreMessages) {
      context.bloc<MessagesBloc>().add(MoreMessagesFetched(
          _scrollController.position.pixels, messages.length));
    }
  }

  /*void notifyCalling(String senderName, String callingType) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 1,
        channelKey: "key1",
        title: "Smart Chat",
        body: "$callingType $senderName",
        displayOnBackground: true,
      ),
    );
  }*/

  void _startTimer() {
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
          //messageNotifData(false, "");
          //fcmTokenForNotification(fcmToken);
        }
      });
    });
  }

  /*void messageNotifData(bool message, String senderName) {
    DocumentReference documentReference = Firestore.instance
        .collection("messageStatus")
        .document(widget.friend.userId);
    Map<String, dynamic> userStatus = {
      "message": message,
      "messageSender": senderName,
    };
    documentReference.setData(userStatus).whenComplete(() {
      print("Message Notif Created");
    });
  }*/

  /*void notify() async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 1,
        channelKey: "key1",
        title: "Smart Chat",
        body: "${widget.friend.name} \n is typing...",
      ),
    );
  }*/
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
  void dispose() {
    _scrollController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    DeviceData deviceData = DeviceData.init(context);
    return BlocConsumer<MessagesBloc, MessagesState>(
        listener: (context, state) {
          _mapStateToActions(state);
        }, builder: (_, state) {
      if (messages != null) {
        return Column(
          children: [
            /*uid == null
                ? Container()
                : StreamBuilder(
                stream: Firestore.instance
                    .collection('callingNotif')
                    .document(uid)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Container();
                  }
                  var userDocument = snapshot.data;
                  if (userDocument['audioCall'] == true) {
                    notifyCalling(
                        "Audio Calling", userDocument['callerName']);
                    *//*DocumentReference documentReference = Firestore.instance.collection("callingNotif").document(uid);
               Map<String , dynamic> userStatus = {
                 "videoCall": false,
                 "callerName": "",
                 "audioCall": false,
               };
               documentReference.setData(userStatus).whenComplete(()
               {
                 print("Call Status Created");
               });*//*
                    FlutterRingtonePlayer.playRingtone();
                    *//*AwesomeNotifications().actionStream.listen((receivedNotifiction){
                 //Navigator.push(context, MaterialPageRoute(builder: (context) => audioIndexPage()));
                 Navigator.pushNamed(context, '/audioCallingPage' );
               });*//*
                    return Container();
                  } else if (userDocument['videoCall'] == true) {
                    notifyCalling(
                        "Video Calling", userDocument['callerName']);
                    *//*DocumentReference documentReference = Firestore.instance.collection("callingNotif").document(uid);
               Map<String , dynamic> userStatus = {
                 "videoCall": false,
                 "callerName": "",
                 "audioCall": false,
               };
               documentReference.setData(userStatus).whenComplete(()
               {
                 print("Call Status Created");
               });*//*
                    FlutterRingtonePlayer.playRingtone();
                    *//*AwesomeNotifications().actionStream.listen((receivedNotifiction){
                 Navigator.pushNamed(context, '/videoCallingPage' );
                 *//* *//*Navigator.of(context).pushNamed(
                   '/videoCallingPage',
                 );*//* *//*
               });*//*
                    return Container();
                  } else {
                    return Container();
                  }
                }),*/
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
                  DocumentReference documentReference = Firestore.instance
                      .collection("callingNotif")
                      .document(widget.friend.userId);
                  Map<String, dynamic> userStatus = {
                    "videoCall": false,
                    "callerName": MyName,
                    "audioCall": false,
                  };
                  documentReference.setData(userStatus).whenComplete(() {
                    print("Call Status Created");
                  });
                  print(MyName);
                  return Container();
                }),*/
            Expanded(
              child: Stack(
                children: [
                  Padding(
                    padding:
                    EdgeInsets.only(bottom: deviceData.screenHeight * 0.01),
                    child: messages.length < 1
                        ? Container(
                      child: Center(
                          child: Text("No messages yet ",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: deviceData.screenHeight * 0.019,
                                color: kBackgroundButtonColor,
                              ))),
                    )
                        : Stack(
                      children: [
                        ListView.builder(
                            controller: _scrollController,
                            reverse: true,
                            itemCount: messages.length,
                            itemBuilder:
                                (BuildContext context, int index) {

                              final message = messages[index];
                              if(index == 0)
                                getSuggestedReplies();
                              return MessageItem(
                                showFriendImage:
                                _showFriendImage(message, index),
                                friend: widget.friend,
                                message: message.message,
                                senderId: message.senderId,
                                imagePic: url,
                                //yahn time or date show krwana hai database ki mada se
                              );
                            }),
                        /*heartRain
                            ? Container(
                          height: deviceData.screenHeight * 0.8,
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                              color: Colors.transparent,
                              image: DecorationImage(
                                image: AssetImage(
                                    'assets/images/heart.gif'),
                              )),
                        )
                            : Container(),
                        StreamBuilder(
                            stream: Firestore.instance
                                .collection('heartStatus')
                                .document(widget.friend.userId)
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return Container();
                              }
                              var userDocument = snapshot.data;
                              if (userDocument['heartValue'] == true) {
                                return Container(
                                  height: deviceData.screenHeight * 0.8,
                                  width:
                                  MediaQuery.of(context).size.width,
                                  decoration: BoxDecoration(
                                      color: Colors.transparent,
                                      image: DecorationImage(
                                        image: AssetImage(
                                            'assets/images/heart.gif'),
                                      )),
                                );
                              } else {
                                return Container();
                              }
                            }),*/
                      ],
                    ),
                  ),
                  state is MoreMessagesLoading
                      ? Padding(
                    padding: EdgeInsets.only(
                        top: deviceData.screenHeight * 0.01),
                    child: Align(
                        alignment: Alignment.topCenter,
                        child: const CircleProgress(
                          radius: 0.035,
                        )),
                  )
                      : SizedBox.shrink()
                ],
              ),
            ),
            Row(
              children: [
                SizedBox(
                  width: deviceData.screenWidth * 0.06,
                ),
                /*StreamBuilder(
                    stream: Firestore.instance
                        .collection('userStatus')
                        .document(widget.friend.userId)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return Container();
                      }
                      var userDocument = snapshot.data;
                      if (userDocument['status'] == "Typing...") {
                        //notify();
                        final firestoreInstance = Firestore.instance;
                        firestoreInstance.collection('users')
                            .document(widget.friend.userId)
                            .collection('contacts')
                            .document(uid)
                            .collection('messages')
                            .document(
                            "${DateTime.now().toUtc().millisecondsSinceEpoch}").get().then((value) => {
                          //print("Mera Last Message Yeh Hai : ${value.data.values.last}"),
                          getLastMsg = value.data.values.last,
                          print("Mera Last Message Yeh Hai : ${getLastMsg}"),
                        });
                        FlutterRingtonePlayer.playNotification();
                        return Container(
                          height: deviceData.screenHeight * 0.06,
                          width: deviceData.screenWidth * 0.15,
                          decoration: BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage('assets/images/typing.gif'),
                                fit: BoxFit.cover,
                              )),
                        );
                      }
                      return Container(
                        width: deviceData.screenWidth * 0.15,
                      );
                    }),*/
                SizedBox(
                  width: deviceData.screenWidth * 0.40,
                ),
                StreamBuilder(
                    stream: Firestore.instance
                        .collection('users')
                        .document(uid.toString())
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return Container();
                      }
                      var userDocument = snapshot.data;
                      String lstMsg = "_lastMessageSeen";
                      if (userDocument[widget.friend.userId + lstMsg] == true) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 20),
                          child: Container(
                            height: deviceData.screenHeight * 0.05,
                            width: deviceData.screenWidth * 0.1,
                            decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: AssetImage('assets/images/seenPic.gif'),
                                  fit: BoxFit.cover,
                                )),
                          ),
                        );
                      }
                      return Align(
                        alignment: Alignment.center,
                        child: Container(
                          height: deviceData.screenHeight * 0.045,
                          width: deviceData.screenWidth * 0.095,
                          decoration: BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage('assets/images/unseen.png'),
                                fit: BoxFit.cover,
                              )),
                        ),
                      );
                    }),
              ],
            ),
            Padding(
              padding: EdgeInsets.only(
                top: deviceData.screenHeight * 0.02,
                bottom: deviceData.screenHeight * 0.02,
                left: deviceData.screenWidth * 0.04,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  /*GestureDetector(
                    onTap: () {
                      setState(() {
                        heartRain = !heartRain;
                        hearRain(heartRain);
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.only(
                          top: deviceData.screenHeight * 0.01,
                          bottom: deviceData.screenHeight * 0.01,
                          right: deviceData.screenWidth * 0.02),
                      child: InkResponse(
                        child: heartRain
                            ? Icon(
                          Icons.favorite_outlined,
                          color: kBackgroundButtonColor,
                          size: deviceData.screenWidth * 0.065,
                        )
                            : GestureDetector(
                          onTap: () {
                            setState(() {
                              heartRain = !heartRain;
                              hearRain(heartRain);
                            });
                          },
                          child: Icon(
                            Icons.favorite_outline,
                            color: kBackgroundButtonColor,
                            size: deviceData.screenWidth * 0.065,
                          ),
                        ),
                      ),
                    ),
                  ),*/
                  MessageInput(controller: _textController),
                  SizedBox(
                    width: deviceData.screenHeight * 0.010,
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => mediaMessageScreen(
                                userName: widget.friend.name,
                                userId: widget.friend.userId,
                                myId: uid,
                              )));
                    },
                    child: Container(
                      padding: EdgeInsets.only(
                          top: deviceData.screenHeight * 0.01,
                          bottom: deviceData.screenHeight * 0.01,
                          right: deviceData.screenWidth * 0.02),
                      child: InkResponse(
                        child: Icon(
                          Icons.image,
                          color: kBackgroundButtonColor,
                          size: deviceData.screenWidth * 0.065,
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: (){
                      /*StreamBuilder(
                          stream: Firestore.instance
                              .collection('userStatus')
                              .document(widget.friend.userId)
                              .snapshots(),
// ignore: missing_return
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              var userDocument = snapshot.data;
                              if (userDocument['status'] == "Online" ||
                                  userDocument['status'] == "Typing...") {
                                return Container(height: 10,width: 10,);
                              }
                            } else {
                              smartNotif("Busy Right Now");
                              return Container(height: 10,width: 10,);
                            }
                          });*/
                    },
                    child: Container(
                      child: SendIcon(
                        controller: _textController,
                        friendId: widget.friend.userId,
                        myName: MyName,
                        getSuggestedReplies: getSuggestedReplies,
                        friendName: widget.friend.name,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            //Smart Reply Widget
            Container(
              margin: EdgeInsets.only(top: 24),
              child: Wrap(
                runAlignment: WrapAlignment.center,
                alignment: WrapAlignment.spaceEvenly,
                children: [
                  for (var s in _suggestedReplies)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: OutlineButton(
                        child: Text(s),
                        onPressed: () {
                          print(s);
                          Firestore.instance
                              .collection('users')
                              .document(uid)
                              .collection('contacts')
                              .document(widget.friend.userId)
                              .collection('messages')
                              .document(
                              "${DateTime.now().toUtc().millisecondsSinceEpoch}")
                              .setData({
                            'message': s,
                            'senderId': uid,
                            'time': "${DateTime.now().toUtc().millisecondsSinceEpoch}",
                          }).whenComplete(() {
                            getSuggestedReplies();
                          });
                          //smartNotif("Busy Right Now");
                          Firestore.instance
                              .collection('users')
                              .document(widget.friend.userId)
                              .collection('contacts')
                              .document(uid)
                              .collection('messages')
                              .document(
                              "${DateTime.now().toUtc().millisecondsSinceEpoch}")
                              .setData({
                            'message': s,
                            'senderId': uid,
                            'time':
                            "${DateTime.now().toUtc().millisecondsSinceEpoch}",
                          }).whenComplete(() {
                            getSuggestedReplies();
                          });



                        },
//                        onPressed: () {},
                      ),
                    )
                ],
              ),
            ),
            SizedBox(
              height: 20.0,
            ),
            /*FlatButton(onPressed: (){
              dynamic conversationObject = {
                'appId': '1ef7a8d336d1527c77a03d7190821dc67',// The [APP_ID](https://dashboard.kommunicate.io/settings/install) obtained from kommunicate dashboard.
              };
              KommunicateFlutterPlugin.buildConversation(conversationObject)
                  .then((clientConversationId) {
                print("Conversation builder success : " + clientConversationId.toString());
              }).catchError((error) {
                print("Conversation builder error : " + error.toString());
              });
            }, child: Text("ChatBot")),*/
          ],
        );
      } else {
        return SizedBox.shrink();
      }
    });
  }

  bool _showFriendImage(Message message, int index) {
    if (message.senderId == widget.friend.userId) {
      if (index == 0) {
        return true;
      } else if (index > 0) {
        String nextSender = messages[index - 1].senderId;
        if (nextSender == widget.friend.userId) {
          return false;
        } else {
          return true;
        }
      }
    }
    return true;
  }

  void _mapStateToActions(MessagesState state) {
    if (Functions.modalIsShown) {
      Navigator.pop(context);
      Functions.modalIsShown = false;
    }

    if (state is MessageSentFailure) {
      Functions.showBottomMessage(context, state.failure.code);
    } else if (state is MessagesLoadFailed) {
      Functions.showBottomMessage(context, state.failure.code);
    } else if (state is MessagesLoadSucceed) {
      if (_scrollController.hasClients) {
        _scrollController?.jumpTo(state.scrollposition);
      }
      if (state.noMoreMessages != null) {
        noMoreMessages = state.noMoreMessages;
      }
      messages = state.messages;
      _textController.clear();
    } else if (state is MoreMessagesFailed) {
      Functions.showBottomMessage(context, state.failure.code);
    }
  }
}