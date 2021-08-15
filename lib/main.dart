import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:chat/bloc_observer.dart';
import 'package:chat/services/notifications.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'my_app.dart';
import 'package:flutter/material.dart';
import 'package:chat/service_locator.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  AwesomeNotifications().initialize(
      'assets/images/appLogo.png',
      [
        NotificationChannel(
          channelKey: "key1",
          channelName: "SmartChat Notification",
          channelDescription: "Notification Description"
        )
      ]
  );
  serviceLoctorSetup();
  Bloc.observer = SimpleBlocObserver();
  runApp(PushMessagingExample());
}
