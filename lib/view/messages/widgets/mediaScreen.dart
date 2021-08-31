import 'dart:math';
import 'dart:async';
import 'package:chat/view/utils/constants.dart';
import 'package:chat/view/utils/device_config.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import "dart:io";

import 'imagePreview.dart';

class mediaMessageScreen extends StatefulWidget {

  mediaMessageScreen({
    @required this.userName,
    @required this.userId,
    @required this.myId,
  });
  String userName;
  String userId;
  String myId;
  @override
  _mediaMessageScreenState createState() => _mediaMessageScreenState();
}

class _mediaMessageScreenState extends State<mediaMessageScreen> {

  File smapleImage;
  var url;



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
  Future getImageByCamera() async {
    var imagePicker = await ImagePicker.pickImage(source: ImageSource.camera);
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
        .collection("mediaMessage")
        .document(widget.userId)
        .collection("contacts")
        .document(widget.myId)
        .collection("messages")
        .document("${DateTime.now().toUtc().millisecondsSinceEpoch}");
    Map<String, dynamic> students = {
      "image": url,
      "senderId": widget.myId,
      "receivedBy": widget.userName,
    };
    documentReference.setData(students).whenComplete(() {
      print("Media MessageCreated");
    });
    DocumentReference documentReference1 = Firestore.instance
        .collection("mediaMessage")
        .document(widget.myId)
        .collection("contacts")
        .document(widget.userId)
        .collection("messages")
        .document("${DateTime.now().toUtc().millisecondsSinceEpoch}");
    Map<String, dynamic> students1 = {
      "image": url,
      "senderId": widget.myId,
      "receivedBy": widget.userName,
    };
    documentReference1.setData(students1).whenComplete(() {
      print("Media MessageCreated");
    });
  }

  @override
  Widget build(BuildContext context) {
    DeviceData deviceData = DeviceData.init(context);
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: deviceData.screenHeight * 0.05,),
            Center(
              child: Text("Media Chat with",style: kArialFontStyle.copyWith(
                fontSize: deviceData.screenHeight * 0.03,
                color: Colors.indigo,
              ),),
            ),
            SizedBox(height: deviceData.screenHeight * 0.02,),
            Center(
              child: Text("You & ${widget.userName}",style: kArialFontStyle.copyWith(
                fontSize: deviceData.screenHeight * 0.03,
                color: Colors.indigo,
              ),),
            ),
            SizedBox(height: deviceData.screenHeight * 0.01,),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: deviceData.screenHeight * 0.09,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.indigo[900],width: 2)
                ),
                child: Column(
                  children: [
                    SizedBox(height: deviceData.screenHeight * 0.02,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        GestureDetector(
                          onTap: (){
                            getImage();
                          },
                          child: Column(
                            children: [
                              Icon(Icons.image,color: Colors.indigo[900],),
                              Text("Upload",style: TextStyle(color: Colors.indigo[900],),)
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: (){
                            getImageByCamera();
                          },
                          child: Column(
                            children: [
                              Icon(Icons.camera,color: Colors.indigo[900],),
                              Text("Camera",style: TextStyle(color: Colors.indigo[900],),)
                            ],
                          ),
                        )
                      ],
                    ),
                  ],
                )
              ),
            ),
            SizedBox(height: deviceData.screenHeight * 0.01,),
            StreamBuilder(
              stream: Firestore.instance.collection('mediaMessage').document(widget.userId).collection('contacts').document(widget.myId)
                  .collection('messages').snapshots(),
                builder: (context , snapshot){
                if(!snapshot.hasData){
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: deviceData.screenHeight * 0.3,),
                      CircularProgressIndicator(color: Colors.indigo[900],)
                    ],
                  );
                }
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    height: deviceData.screenHeight * 0.7,
                    decoration: BoxDecoration(
                        border: Border.all(width: 2,color: Colors.indigo[900])
                    ),
                    child: ListView.builder(
                        scrollDirection: Axis.vertical,
                        reverse: true,
                        itemCount: snapshot.data.documents.length,
                        itemBuilder: (context , index){
                          return GestureDetector(
                            onTap: (){
                              Navigator.push(context, MaterialPageRoute(builder: (context) => imagePreview(snapshot.data.documents[index]["image"],)));
                            },
                            child: messageImage(
                              receivedBy: snapshot.data.documents[index]["receivedBy"],
                              imgUrl: snapshot.data.documents[index]["image"],
                            ),
                          );
                        }),
                  ),
                );
                }),
          ],
        ),
      ),
     /* bottomNavigationBar: BottomNavigationBar(
        unselectedLabelStyle: TextStyle(color: Colors.white),
        backgroundColor: Colors.indigo[900],
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.image,color: Colors.white,),
            title: Text("Media",style: TextStyle(color: Colors.white),),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.camera,color: Colors.white),
            title: Text("Media",style: TextStyle(color: Colors.white),),
          ),
        ],
      ),*/
    );
  }
}

class messageImage extends StatefulWidget {
  String imgUrl;
  String receivedBy;

  messageImage({this.imgUrl, this.receivedBy});

  @override
  _messageImageState createState() => _messageImageState();
}

class _messageImageState extends State<messageImage> {
  @override
  Widget build(BuildContext context) {
    DeviceData deviceData = DeviceData.init(context);
    return Container(
      height: deviceData.screenHeight * 0.30,
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
                    border: Border.all(color: Colors.indigo,width: 2),
                    image: DecorationImage(
                      image: NetworkImage(
                          widget.imgUrl),
                      fit: BoxFit.cover,
                    )),
              ),
            ],
          ),
          SizedBox(
            height: deviceData.screenHeight * 0.01,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 15),
            child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Received by : ${widget.receivedBy}",
                  style: TextStyle(color: Colors.indigo[900]),
                )),
          ),
        ],
      ),
    );
  }
}

//receivedBy: snapshot.data.userDocument[index].data["receivedBy"],
