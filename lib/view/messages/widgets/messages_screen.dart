import 'package:chat/models/message.dart';
import 'package:chat/models/user.dart';
import 'package:chat/service_locator.dart';
import 'package:chat/utils/failure.dart';
import 'package:chat/view/messages/bloc/messages_bloc.dart';
import 'package:chat/view/messages/widgets/messages_header.dart';
import 'package:chat/view/utils/constants.dart';
import 'package:chat/view/utils/device_config.dart';
import 'package:chat/view/widgets/footer.dart';
import 'package:chat/view/messages/widgets/messages_list.dart';
import 'package:chat/view/widgets/progress_indicator.dart';
import 'package:chat/view/widgets/try_again_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'dart:async';

class MessagesScreen extends StatefulWidget {
  final User friend;
  MessagesScreen({@required this.friend});
  static String routeID = "MESSAGE_SCREEN";

  @override
  _MessageScreenState createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessagesScreen> with WidgetsBindingObserver {
  Future<List<Message>> messagesFuture;
  TextEditingController controller;
  DeviceData deviceData;
  bool showMessages = false;
  MessagesBloc messagesBloc;
  bool changeStatus = true;
  String uid;
  final FirebaseAuth auth = FirebaseAuth.instance;
  void getUserId() async {
    final FirebaseUser user = await auth.currentUser();
    uid = user.uid;
    print("User Id : " + uid.toString());
  }

  @override
  void initState() {
    getUserId();
    messagesBloc = serviceLocator<MessagesBloc>();
    controller = TextEditingController();
    super.initState();
  }


  @override
  void dispose() {
    messagesBloc.close();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    deviceData = DeviceData.init(context);
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Container(
          color: kBackgroundColor,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              MessagesHeader(friend: widget.friend),
              Expanded(
                child: BlocProvider<MessagesBloc>(
                  create: (context) =>
                      messagesBloc..add(MessagesStartFetching(widget.friend)),
                  child: Stack(
                    children: <Widget>[
                      const WhiteFooter(),
                      MessagesList(friend: widget.friend),
                      BlocBuilder<MessagesBloc, MessagesState>(
                        builder: (context, state) {
                          return state is MessagesLoading
                              ? const Center(child: CircleProgress())
                              : state is MessagesLoadFailed &&
                                      state.failure is NetworkException
                                  ? TryAgain(
                                      doAction: () => context
                                          .bloc<MessagesBloc>()
                                          .add(MessagesStartFetching(
                                              widget.friend)))
                                  : SizedBox.shrink();
                        },
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
