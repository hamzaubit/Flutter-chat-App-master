import 'package:chat/view/utils/device_config.dart';
import 'package:flutter/material.dart';

class imagePreview extends StatelessWidget {

  imagePreview(this.imgUtl);
  String imgUtl;
  @override
  Widget build(BuildContext context) {
    DeviceData deviceData = DeviceData.init(context);
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Stack(
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              height: deviceData.screenHeight * 0.5,
              decoration: BoxDecoration(
                  borderRadius: new BorderRadius.only(
                    topLeft: Radius.circular(20.0),
                    topRight: Radius.circular(20.0),
                    bottomRight: Radius.circular(20.0),
                    bottomLeft: Radius.circular(20.0),
                  )),
              child: Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                  )),
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              height: deviceData.screenHeight * 0.5,
              decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(this.imgUtl),fit: BoxFit.contain,
                  )
              ),
            ),
          ],
        ),
      ),
    );
  }
}
