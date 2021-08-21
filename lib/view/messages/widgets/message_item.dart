import 'package:chat/models/user.dart';
import 'package:chat/view/utils/constants.dart';
import 'package:chat/view/utils/device_config.dart';
import 'package:chat/view/widgets/avatar_icon.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MessageItem extends StatefulWidget {
  const MessageItem({
    Key key,
    @required this.showFriendImage,
    @required this.friend,
    @required this.senderId,
    @required this.message,
    @required this.imagePic,
  }) : super(key: key);
  final bool showFriendImage;
  final User friend;
  final String message;
  final String senderId;
  final String imagePic;

  @override
  _MessageItemState createState() => _MessageItemState();
}

class _MessageItemState extends State<MessageItem> {
  @override
  Widget build(BuildContext context) {
    DeviceData deviceData = DeviceData.init(context);
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.only(
            bottom: deviceData.screenHeight * 0.01,
            left: deviceData.screenWidth * 0.07,
            right: deviceData.screenWidth * 0.08,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: widget.senderId == widget.friend.userId
                ? MainAxisAlignment.start
                : MainAxisAlignment.end,
            children: <Widget>[
              widget.senderId == widget.friend.userId
                  ? widget.showFriendImage == true
                      ? AvatarIcon(
                          user: widget.friend,
                          radius: 0.045,
                          errorWidgetColor: kBackgroundColor,
                          placeholderColor: kBackgroundColor,
                        )
                      : SizedBox(width: deviceData.screenHeight * 0.045)
                  : SizedBox.shrink(),
              widget.senderId == widget.friend.userId
                  ? SizedBox(width: deviceData.screenWidth * 0.02)
                  : SizedBox.shrink(),
              Flexible(
                child: Container(
                  decoration: BoxDecoration(
                      color: kBackgroundColor.withOpacity(
                          widget.senderId == widget.friend.userId ? 0.3 : 1.0),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(deviceData.screenWidth * 0.05),
                        topRight:
                            Radius.circular(deviceData.screenWidth * 0.05),
                        bottomRight: Radius.circular(
                            widget.senderId == widget.friend.userId
                                ? deviceData.screenWidth * 0.05
                                : 0),
                        bottomLeft: Radius.circular(
                            widget.senderId != widget.friend.userId
                                ? deviceData.screenWidth * 0.05
                                : 0),
                      )),
                  padding: EdgeInsets.symmetric(
                      vertical: deviceData.screenHeight * 0.015,
                      horizontal: deviceData.screenHeight * 0.015),
                  child: Column(
                    children: [
                      Text(
                        widget.message,
                        style: TextStyle(
                          fontSize: deviceData.screenHeight * 0.018,
                          color: widget.senderId == widget.friend.userId
                              ? Colors.black
                              : Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
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
                )),
                child: Center(
                    child: CircularProgressIndicator(
                  color: Colors.indigo[900],
                )),
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
                      image: NetworkImage("https://firebasestorage.googleapis.com/v0/b/chat-app-c302a.appspot.com/o/8VTtiZZ8cXM4mqLoycnSyWdHz5fv?alt=media&token=c0d28cd1-7eab-4f7c-b9ef-7d696c8a5b00"),
                      fit: BoxFit.cover,
                    )),
              ),
            ],
          ),
          SizedBox(
            height: deviceData.screenHeight * 0.01,
          ),
          Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Received by : Hunain Ali",
                style: TextStyle(color: Colors.indigo[900]),
              )),
        ],
      ),
    );
  }
}
