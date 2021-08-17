import 'package:chat/main.dart';
import 'package:chat/models/user.dart';
import 'package:chat/models/user_presentation.dart';
import 'package:chat/utils/functions.dart';
import 'package:chat/view/friends/bloc/friends_bloc.dart';
import 'package:chat/view/messages/widgets/messages_screen.dart';
import 'package:chat/view/utils/constants.dart';
import 'package:chat/view/utils/device_config.dart';
import 'package:chat/view/widgets/avatar_icon.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:page_transition/page_transition.dart';

class FriendsListItem extends StatefulWidget {
  const FriendsListItem({
    Key key,
    @required this.user,
    @required this.friend,
  }) : super(key: key);
  final UserPresentation user;
  final User friend;

  @override
  _FriendsListItemState createState() => _FriendsListItemState();
}

class _FriendsListItemState extends State<FriendsListItem> {
  @override
  Widget build(BuildContext context) {
    DeviceData deviceData = DeviceData.init(context);

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Container(
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          color: Colors.deepPurple.withOpacity(0.25),
          borderRadius: BorderRadius.only(topRight: Radius.circular(25),bottomLeft: Radius.circular(25),topLeft: Radius.circular(25),bottomRight: Radius.circular(25)),
        ),
        child: InkResponse(
          onTap: () {
            if (!KeyboardVisibility.isVisible) {
              Navigator.push(
                      context,
                      PageTransition(
                          type: PageTransitionType.fade,
                          child: MessagesScreen(friend: widget.user)))
                  .then((value) {
                if (BlocProvider.of<FriendsBloc>(context).state is SearchSucceed) {
                  print(0);
                  BlocProvider.of<FriendsBloc>(context).add(ClearSearch());
                }
              });
            } else {
              FocusScope.of(context).unfocus();
            }
          },
          child: TweenAnimationBuilder(
            duration: Duration(milliseconds: 300),
            tween: Tween<double>(begin: -1, end: 1),
            builder: (BuildContext context, double value, Widget child) {
              return Transform.scale(
                scale: value,
                child: Padding(
                  padding: EdgeInsets.only(
                    bottom: deviceData.screenHeight * 0.03,
                    top: deviceData.screenHeight * 0.01,
                    left: deviceData.screenWidth * 0.05,
                    right: deviceData.screenWidth * 0.04,
                  ),
                  child: Column(
                    children: [
                      SizedBox(height: deviceData.screenHeight * 0.01,),
                      Row(
                        children: <Widget>[
                          AvatarIcon(
                            radius: 0.07,
                            user: widget.user,
                            errorWidgetColor: kBackgroundColor,
                            placeholderColor: kBackgroundColor,
                          ),
                          SizedBox(width: deviceData.screenWidth * 0.045),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      widget.user.name,
                                      style: kArialFontStyle.copyWith(
                                          fontSize: deviceData.screenHeight * 0.015),
                                    ),
                                    widget.user.lastMessage != null
                                        ? Text(
                                        Functions.convertDate(widget.user.lastMessageTime),
                                        style: TextStyle(
                                            fontWeight: FontWeight.w400,
                                            color: Colors.black.withOpacity(0.7),
                                            fontSize:
                                            deviceData.screenHeight * 0.015))
                                        : SizedBox.shrink(),
                                  ],
                                ),
                                SizedBox(height: deviceData.screenHeight * 0.01),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      widget.user.lastMessage == null
                                          ? "Let's keep in touch."
                                          : widget.user.userId == widget.user.lastMessageSenderId
                                          ? Functions.getFirstName(widget.user.name) +
                                          " : " +
                                          Functions.shortenMessage(
                                              widget.user.lastMessage, 20)
                                          : "You" +
                                          " : " +
                                          Functions.shortenMessage(
                                              widget.user.lastMessage, 20),
                                      style: TextStyle(
                                          fontWeight: widget.user.lastMessage != null
                                              ? widget.user.lastMessageSeen == true
                                              ? FontWeight.w400
                                              : FontWeight.bold
                                              : FontWeight.w400,
                                          color: Colors.black.withOpacity(0.8),
                                          fontSize: deviceData.screenHeight * 0.013),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  )
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
