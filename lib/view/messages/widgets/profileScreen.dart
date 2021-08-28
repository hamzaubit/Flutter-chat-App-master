import 'package:chat/view/utils/constants.dart';
import 'package:chat/view/utils/device_config.dart';
import 'package:flutter/material.dart';

class profileScreen extends StatefulWidget {

  String name;
  String img;
  String email;
  profileScreen({Key key, @required this.name,@required this.img,@required this.email}) : super(key: key);

  @override
  _profileScreenState createState() => _profileScreenState();
}

class _profileScreenState extends State<profileScreen> {
  @override
  Widget build(BuildContext context) {
    final deviceData = DeviceData.init(context);
    return Scaffold(
      body: Column(
        children: [
          SizedBox(height:  deviceData.screenHeight * 0.2,),
          Center(
            child: Container(
              height: deviceData.screenHeight * 0.2,
              width: deviceData.screenWidth * 0.4,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(80)),
                border: Border.all(color: Colors.indigo,width: 3),
                image: DecorationImage(
                  image: NetworkImage(widget.img),fit: BoxFit.fill
                )
              ),
            ),
          ),
          SizedBox(height:  deviceData.screenHeight * 0.05,),
          Text(widget.name,style: kArialFontStyle.copyWith(
          fontSize: deviceData.screenHeight * 0.025,
            color: Colors.indigo,
          ),),
          SizedBox(height:  deviceData.screenHeight * 0.05,),
          Text(widget.email,style: kArialFontStyle.copyWith(
            fontSize: deviceData.screenHeight * 0.025,
            color: Colors.indigo,
          ),)
        ],
      ),
    );
  }
}
