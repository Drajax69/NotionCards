
import 'package:flutter/material.dart' as ui;

class NetworkImageConstants {
  static const testEnv = 1;
  // static const String loginBackgroundUrl =
  //     'https://firebasestorage.googleapis.com/v0/b/notioncards-23b9e.appspot.com/o/loginbg.png?alt=media&token=b5c9605e-8f3e-4793-9356-7762f91f43c2';

  // static const String loginBackgroundDinoUrl =
  //     "https://firebasestorage.googleapis.com/v0/b/notioncards-23b9e.appspot.com/o/loginDino.png?alt=media&token=85d7b73f-c500-4f34-8fd5-135f8ac9a5d2";

  // static const String logoDino =
  //     "https://firebasestorage.googleapis.com/v0/b/notioncards-23b9e.appspot.com/o/logoDino.png?alt=media&token=70af7e1c-915b-40f3-9dac-185b55f7399c";

  static const String loginBackgroundUrl = 'loginbg.png';

  static const String loginBackgroundDinoUrl = "loginDino.png";

  static const String logoDinoUrl = "logoDino.png";

 static ui.Image getLoginBackgroundImage({double? width, double? height}) {
    if (testEnv == 1) {
      return ui.Image.asset(loginBackgroundUrl, width: width, height: height);
    } else {
      return ui.Image.network(loginBackgroundUrl, width: width, height: height);
    }
  }

  static ui.Image getLoginBackgroundDinoImage({double? width, double? height}) {
    if (testEnv == 1) {
      return ui.Image.asset(loginBackgroundDinoUrl, width: width, height: height);
    } else {
      return ui.Image.network(loginBackgroundDinoUrl, width: width, height: height);
    }
  }

  static ui.Image getLogoDinoImage({double? width, double? height}) {
    if (testEnv == 1) {
      return ui.Image.asset(logoDinoUrl, width: width, height: height);
    } else {
      return ui.Image.network(logoDinoUrl, width: width, height: height);
    }
  }
}
