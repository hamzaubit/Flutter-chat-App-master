import 'package:chat/bloc_observer.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'my_app.dart';
import 'package:flutter/material.dart';
import 'package:chat/service_locator.dart';
import 'package:awesome_notifications/awesome_notifications.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  AwesomeNotifications().initialize(
      null,
    [
      NotificationChannel(
        channelKey: "key1",
        channelName: "SmartChat",
        channelDescription: "Notification",
        defaultColor: Colors.deepPurple,
        playSound: true,
      )
    ]
      );
  serviceLoctorSetup();
  Bloc.observer = SimpleBlocObserver();
  runApp(MyApp());
}
