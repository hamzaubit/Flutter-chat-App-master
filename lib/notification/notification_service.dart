import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;

class NotificationService{
  static const APP_ID = 'de5784d2-80ad-4d4f-8b74-993982680762';

   sendNotification(List<String> tokenIdList, String contents, String heading) async{

    return await http.post(
      Uri.parse('https://onesignal.com/api/v1/notifications'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>
      {
        "app_id": APP_ID,//kAppId is the App Id that one get from the OneSignal When the application is registered.

        "include_player_ids": tokenIdList,//tokenIdList Is the List of All the Token Id to to Whom notification must be sent.

        // android_accent_color reprsent the color of the heading text in the notifiction
        "android_accent_color":"FF9976D2",

//        "small_icon":"ic_stat_onesignal_default",
//
//        "large_icon":"https://www.filepicker.io/api/file/zPloHSmnQsix82nlj9Aj?filename=name.jpg",

        "headings": {"en": heading},

        "contents": {"en": contents},


      }),
    );
  }
  
  getToken(userId){
     Firestore.instance.collection('users').document(userId).get().then((value){
       print(value.data['tokenId']);
     });
  }
}