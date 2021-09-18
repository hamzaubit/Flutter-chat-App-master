import 'dart:ffi';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:chat/bloc_observer.dart';
import 'package:chat/services/notifications.dart';
import 'package:chat/smart_reply_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'my_app.dart';
import 'package:flutter/material.dart';
import 'package:chat/service_locator.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  AwesomeNotifications().initialize(
    null,
      [
        NotificationChannel(
          channelKey: "key1",
          channelName: "SmartChat Notification",
          channelDescription: "Notification Description",
          defaultColor: Colors.deepPurple,
          playSound: true,

        )
      ]
  );
  serviceLoctorSetup();
  Bloc.observer = SimpleBlocObserver();
  runApp(MyApp());
}
