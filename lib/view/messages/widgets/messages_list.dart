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
import 'package:image_picker/image_picker.dart';
import "dart:io";

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

  final FirebaseAuth auth = FirebaseAuth.instance;

  void getUserId() async {
    final FirebaseUser user = await auth.currentUser();
    uid = user.uid;
    print("User Id : " + uid.toString());
    print("Friend Id : " +widget.friend.userId);
  }

  void hearRain(bool heartRain) async {
    DocumentReference documentReference = Firestore.instance.collection("heartStatus").document(uid);
    Map<String , dynamic> userStatus = {
      "heartValue": heartRain,
    };
    documentReference.setData(userStatus).whenComplete(()
    {
      print("Heart Created");
    });
  }
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
          messageNotifData(false,"");

          //fcmTokenForNotification(fcmToken);
        }
      });
    });
  }

  String _chars =
      'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  Random _rnd = Random();

  String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
      length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));

  Future getImage() async {
    var imagePicker = await ImagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      smapleImage = imagePicker;
      uploadImage();
      //forDisableButton = true;
    });
  }
  void messageNotifData(bool message , String senderName){
    DocumentReference documentReference = Firestore.instance.collection("messageStatus").document(widget.friend.userId);
    Map<String , dynamic> userStatus = {
      "message": message,
      "messageSender": senderName,
    };
    documentReference.setData(userStatus).whenComplete(()
    {
      print("Message Notif Created");
    });
  }

  Future uploadImage() async {
    //SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() async {
      final StorageReference firebaseStorageRef =
      FirebaseStorage.instance.ref().child(getRandomString(28));
      final StorageUploadTask task = firebaseStorageRef.putFile(smapleImage);
      url = await (await task.onComplete).ref.getDownloadURL();
      print(url);
      print("Image uploaded on Firebase Storage");
      mediaMessage();
    });
  }
  void notify() async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 1,
        channelKey: "key1",
        title: "Smart Chat",
        body: "${widget.friend.name} \n is typing...",
      ),
    );
  }

  mediaMessage() {
    DocumentReference documentReference = Firestore.instance
        .collection("users")
        .document(widget.friend.userId)
        .collection("contacts")
        .document(uid)
        .collection("messages")
        .document("${DateTime.now().toUtc().millisecondsSinceEpoch}");
    Map<String, dynamic> students = {
      "image": url,
      "senderId": uid,
      "receivedBy": widget.friend.name,
    };
    documentReference.setData(students).whenComplete(() {
      print("Media MessageCreated");
    });
  }

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
            uid == null ? Container() : StreamBuilder(
                stream: Firestore.instance.collection('users').document(uid).snapshots(),
                builder: (context, snapshot){
                  if (!snapshot.hasData) {
                    return Container();
                  }
                  var userDocument = snapshot.data;
                  MyName = userDocument['name'];
                  print(MyName);
                  return Container();
                }
            ),
            Expanded(
              child: Stack(
                children: [
                  Padding(
                    padding:
                    EdgeInsets.only(bottom: deviceData.screenHeight * 0.01),
                    child: messages.length < 1
                        ? Center(
                        child: Text("No messages yet ",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: deviceData.screenHeight * 0.019,
                              color: kBackgroundButtonColor,
                            )))
                        : Stack(
                      children: [
                        ListView.builder(
                            controller: _scrollController,
                            reverse: true,
                            itemCount: messages.length,
                            itemBuilder: (BuildContext context, int index) {
                              final message = messages[index];
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
                        heartRain ? Container(
                          height: deviceData.screenHeight * 0.8,
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            image: DecorationImage(
                              image: AssetImage('assets/images/heart.gif'),
                            )
                          ),
                        ) : Container(),
                        StreamBuilder(
                            stream: Firestore.instance.collection('heartStatus').document(widget.friend.userId).snapshots(),
                            builder: (context, snapshot){
                              if(!snapshot.hasData){
                                return Container();
                              }
                              var userDocument = snapshot.data;
                              if(userDocument['heartValue'] == true){
                                return Container(
                                  height: deviceData.screenHeight * 0.8,
                                  width: MediaQuery.of(context).size.width,
                                  decoration: BoxDecoration(
                                      color: Colors.transparent,
                                      image: DecorationImage(
                                        image: AssetImage('assets/images/heart.gif'),
                                      )
                                  ),
                                );
                              }
                              else{
                                return Container();
                              }
                            }
                        ),
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
                SizedBox(width: deviceData.screenWidth * 0.06,),
                StreamBuilder(
                    stream: Firestore.instance.collection('userStatus').document(widget.friend.userId).snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return Container();
                      }
                      var userDocument = snapshot.data;
                      if(userDocument['status'] == "Typing..."){
                        notify();
                        return Container(
                          height: deviceData.screenHeight * 0.06,
                          width: deviceData.screenWidth * 0.15,
                          decoration: BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage('assets/images/typing.gif'),fit: BoxFit.cover,
                              )
                          ),
                        );
                      }
                      return Container(width: deviceData.screenWidth * 0.15,);
                    }),
                SizedBox(width: deviceData.screenWidth * 0.23,),
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
                      if(userDocument[widget.friend.userId+lstMsg] == true){
                        return Padding(
                          padding: const EdgeInsets.only(right: 20),
                          child: Container(
                            height: deviceData.screenHeight * 0.05,
                            width: deviceData.screenWidth * 0.1,
                            decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: AssetImage('assets/images/seenPic.gif'),fit: BoxFit.cover,
                                )
                            ),
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
                                image: AssetImage('assets/images/unseen.png'),fit: BoxFit.cover,
                              )
                          ),
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
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        heartRain =! heartRain;
                        hearRain(heartRain);
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.only(
                          top: deviceData.screenHeight * 0.01,
                          bottom: deviceData.screenHeight * 0.01,
                          right: deviceData.screenWidth * 0.02),
                      child: InkResponse(
                        child: heartRain ? Icon(
                          Icons.favorite_outlined,
                          color: kBackgroundButtonColor,
                          size: deviceData.screenWidth * 0.065,
                        ) : GestureDetector(
                          onTap: () {
                            setState(() {
                              heartRain =! heartRain;
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
                  ),
                  MessageInput(controller: _textController),
                  SizedBox(
                    width: deviceData.screenHeight * 0.020,
                  ),
                  GestureDetector(
                    onTap: () {
                      getUserId();
                      getImage();
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
                  SendIcon(
                    controller: _textController,
                    friendId: widget.friend.userId,
                    myName: MyName,
                  ),
                ],
              ),
            ),
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

class messageImage extends StatefulWidget {

  String imgUrl;
  String receivedBy;
  messageImage({this.imgUrl,this.receivedBy});

  @override
  _messageImageState createState() => _messageImageState();
}

class _messageImageState extends State<messageImage> {
  @override
  Widget build(BuildContext context) {
    DeviceData deviceData = DeviceData.init(context);
    return Container(
      height: deviceData.screenHeight * 0.28,
      width: MediaQuery.of(context).size.width - 80,
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                height: deviceData.screenHeight * 0.25,
                width: MediaQuery.of(context).size.width - 80,
                decoration: BoxDecoration(
                    borderRadius: new BorderRadius.only(
                      topLeft: Radius.circular(20.0),
                      topRight: Radius.circular(20.0),
                      bottomRight: Radius.circular(20.0),
                      bottomLeft: Radius.circular(20.0),
                    )
                ),
                child: Center(child: CircularProgressIndicator(color: Colors.indigo[900],)),
              ),
              Container(
                height: deviceData.screenHeight * 0.25,
                width: MediaQuery.of(context).size.width - 80,
                decoration: BoxDecoration(
                    borderRadius: new BorderRadius.only(
                      topLeft: Radius.circular(20.0),
                      topRight: Radius.circular(20.0),
                      bottomRight: Radius.circular(20.0),
                      bottomLeft: Radius.circular(20.0),
                    ),
                    image: DecorationImage(
                      image: NetworkImage("https://firebasestorage.googleapis.com/v0/b/chat-app-c302a.appspot.com/o/zhg7DYL1NLiw2CHCQ2EmTBZ8h6HM?alt=media&token=4f9558ea-95ab-41a8-b043-0cf2d893778e"),
                      fit: BoxFit.cover,
                    )
                ),
              ),
            ],
          ),
          SizedBox(height: deviceData.screenHeight * 0.01,),
          Align(
              alignment: Alignment.centerLeft,
              child: Text("Received by : Hunain Ali",style: TextStyle(color: Colors.indigo[900]),)),
        ],
      ),
    );
  }
}

