import 'package:bubble/bubble.dart';
import 'package:chat/view/utils/constants.dart';
import 'package:chat/view/utils/device_config.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dialogflow/dialogflow_v2.dart';
import 'package:intl/intl.dart';

class chatBot extends StatefulWidget {
  @override
  _chatBotState createState() => _chatBotState();
}

class _chatBotState extends State<chatBot> {

  final messageTextController = TextEditingController();
  List<Map> messages = new List();

  void response(query) async {
    AuthGoogle authGoogle = await AuthGoogle(
      fileJson: "assets/cedar-amulet-325409-44bdbd2f6ecc.json"
    ).build();
    Dialogflow dialogflow = await Dialogflow(authGoogle: authGoogle , language: Language.english);
    AIResponse aiResponse = await dialogflow.detectIntent(query);
    setState(() {
      print(aiResponse.getListMessage());
      messages.insert(0, {
        "data": 0,
        "messages": aiResponse.getListMessage()[0]["text"]["text"][0].toString(),
      });

    });
  }


  @override
  Widget build(BuildContext context) {
    final deviceData = DeviceData.init(context);
    return Scaffold(
      body: Container(
        child: Column(
          children: [
            Center(
              child: Container(
                padding: EdgeInsets.only(top: 30,bottom: 10),
                child: Text("Today : ${DateFormat("Hm").format(DateTime.now())}",
                    style: kTitleTextStyle.copyWith(
                      fontSize: deviceData.screenHeight * 0.028,
                      color: Colors.indigo[900],
                    ),
                  ),
              ),
            ),
            Flexible(
                child: ListView.builder(
                  reverse: true,
                    itemCount: 0,
                    itemBuilder: (context , index){
                    return chat(messages[index]["messages"].toString(),messages[index]["data"]);
                    }
                ),
            ),
            Divider(
              height: 5,
              color: Colors.greenAccent,
            ),
            Container(
              child: ListTile(
                leading: IconButton(
                  icon: Icon(Icons.camera_alt,color: Colors.greenAccent,size: deviceData.screenHeight * 0.04,),
                ),
                title: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(15)),
                    color: Color.fromARGB(220, 220, 2220, 1)
                  ),
                  padding: EdgeInsets.only(left: 15),
                  child: TextFormField(
                    cursorColor: Colors.black,
                    controller: messageTextController,
                    decoration: InputDecoration(
                      hintText: "Enter a message",
                      hintStyle: kTitleTextStyle.copyWith(
                        fontSize: deviceData.screenHeight * 0.018,
                        color: Colors.indigo[900],
                      ),
                      border: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                    ),
                  ),
                ),
                trailing: IconButton(
                  onPressed: (){
                    if(messageTextController.text.isEmpty){
                      print("Empty message");
                    }
                    else{
                      setState(() {
                        messages.insert(0, {
                          "data": 1,
                          "messages":messageTextController.text,
                        });
                        response(messageTextController.text);
                        messageTextController.clear();
                      });
                      FocusScopeNode currenctFocus = FocusScope.of(context);
                      if(!currenctFocus.hasPrimaryFocus){
                        currenctFocus.unfocus();
                      }
                    }
                  },
                    icon: Icon(Icons.send,color: Colors.greenAccent,size: deviceData.screenHeight * 0.04,)),
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget chat(String message , int data ){
    return Container(
      padding: EdgeInsets.only(left: 20,right: 20),
      child: Row(
        mainAxisAlignment: data == 1 ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          data == 0 ? Container(
            height: 60,
            width: 60,
            child: CircleAvatar(
              backgroundImage: AssetImage("assets/images/appLogo.png"),
            ),
          ) : Container(),

          Padding(padding: EdgeInsets.all(10),
            child: Bubble(
              radius: Radius.circular(15),
              color: data == 0 ? Color.fromARGB(23, 157, 139, 1) : Colors.orangeAccent,
              elevation: 0,
              child: Padding(
                padding: EdgeInsets.all(2),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(width: 10,),
                    Flexible(
                        child: Container(
                          constraints: BoxConstraints(maxWidth: 200),
                          child: Text(message,style: TextStyle(color: Colors.indigo[900],fontWeight: FontWeight.bold),),
                        )
                    ),
                  ],
                ),
              ),
            ),
          ),
          data == 1 ? Container(
            height: 60,
            width: 60,
            child: CircleAvatar(
              backgroundColor: Colors.indigo[900],
              //backgroundImage: AssetImage("assets/images/appLogo.png"),
            ),
          ) : Container()
        ],
      ),
    );
  }
}
