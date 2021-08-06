import 'dart:math';

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
  TextEditingController _textController;
  List<Message> messages;
  ScrollController _scrollController = ScrollController();
  bool noMoreMessages = false;
  File smapleImage;
  var url;
  String uid;

  final FirebaseAuth auth = FirebaseAuth.instance;

  void getUserId() async {
    final FirebaseUser user = await auth.currentUser();
    uid = user.uid;
    print("User Id : " + uid.toString());
  }

  @override
  void initState() {
    _textController = TextEditingController();
    _scrollController = ScrollController();
    _scrollController.addListener(() => _scrollListener());
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
                        : ListView.builder(
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
            //messageImage(),
            Padding(
              padding: EdgeInsets.only(
                top: deviceData.screenHeight * 0.02,
                bottom: deviceData.screenHeight * 0.02,
                left: deviceData.screenWidth * 0.07,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
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

