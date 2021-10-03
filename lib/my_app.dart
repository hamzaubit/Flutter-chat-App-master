import 'dart:convert';

import 'package:chat/AudioCall/audioIndex.dart';
import 'package:chat/service_locator.dart';
import 'package:chat/videoCall/index.dart';
import 'package:chat/view/chatBot/chatBot.dart';
import 'package:chat/view/friends/widgets/edit_form_view.dart';
import 'package:chat/view/notification/bloc/notification_bloc.dart';
import 'package:chat/view/register/bloc/account_bloc.dart';
import 'package:chat/view/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'notification/notification_service.dart';
import 'view/splash/widgets/splash_screen.dart';
import 'package:alan_voice/alan_voice.dart';

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  final sugg = [
    "Go to edit screen",
    "Edit screen",
    "go to setting",
    "Edit screen",
    "Setting",
    "Play 104 FM",
    "Pause",
    "Play previous",
    "Play pop music"
  ];

    /// Init Alan Button with project key from Alan Studio - log in to https://studio.alan.app, go to your project > Integrations > Alan SDK Key
    setupAlan(){
      AlanVoice.addButton(
          "9b711403b14eead8c7518f556402bd042e956eca572e1d8b807a3e2338fdd0dc/stage",
          buttonAlign: AlanVoice.BUTTON_ALIGN_RIGHT);
      AlanVoice.callbacks.add((command) => _handleCommand(command.data));

      AlanVoice.setLogLevel("none");

      /// Add button state handler
      AlanVoice.onButtonState.add((state) {
        debugPrint("got new button state ${state.name}");
      });

      /// Add command handler
      AlanVoice.onCommand.add((command) {
        debugPrint("got new command ${command.toString()}");
      });

      /// Add event handler
      AlanVoice.onEvent.add((event) {
        debugPrint("got new event ${event.data.toString()}");
      });

      /// Activate Alan Button
      // ignore: unused_element
      void _activate() {
        AlanVoice.activate();
      }

      /// Deactivate Alan Button
      // ignore: unused_element
      void _deactivate() {
        AlanVoice.deactivate();
      }

      /// Play any text via Alan Button
      // ignore: unused_element
      void _playText() {
        /// Provide text as string param
        AlanVoice.playText("Hello from Alan");
      }

      /// Execute any command locally (and handle it with onCommand callback)
      // ignore: unused_element
      void _playCommand() {
        /// Provide any params with json
        var command = jsonEncode({"command": "commandName"});
        AlanVoice.playCommand(command);
      }

      /// Call project API from Alan Studio script
      // ignore: unused_element
      void _callProjectApi() {
        /// Provide any params with json
        var params = jsonEncode({"apiParams": "paramsValue"});
        AlanVoice.callProjectApi("projectAPI", params);
      }

      /// Set visual state in Alan Studio script
      // ignore: unused_element
      void _setVisualState() {
        /// Provide any params with json
        var visualState = jsonEncode({"visualState": "stateValue"});
        AlanVoice.setVisualState(visualState);
      }
    }

    _handleCommand(Map<String , dynamic> response){
      switch (response["command"]){
        case "Setting":
          print("Meri Command Chal Rahi hai");
          break;
        default:
          print("Command was ${response["command"]} ");
          break;
      }
    }

  @override
  void initState() {
    super.initState();
    configOneSignel();
    setupAlan();
  }

  void configOneSignel()
  {
    OneSignal.shared.setAppId(NotificationService.APP_ID);
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    return MultiBlocProvider(
      providers: [
        BlocProvider<AccountBloc>(
            create: (_) =>
                serviceLocator<AccountBloc>()..add(IsSignedInEvent())),
        // BlocProvider<NotificationBloc>(
        //     create: (_) => serviceLocator<NotificationBloc>()
        //     ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        darkTheme: ThemeData(
          brightness: Brightness.light,
          accentColor: kBackgroundColor,
        ),
        home: SplashScreen(),
      ),
    );
  }
}
