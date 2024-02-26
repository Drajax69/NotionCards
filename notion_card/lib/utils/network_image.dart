import 'package:flutter/material.dart' as ui;

class NetworkImageConstants {
  static const testEnv = true;

  static const String loginBackgroundUrl = 'loginbg.png';

  static const String loginBackgroundDinoUrl = "loginDino.png";

  static const String logoDinoUrl = "logoDino.png";

  static ui.Image getLoginBackgroundImage({double? width, double? height}) {
    if (testEnv) {
      return ui.Image.asset(loginBackgroundUrl, width: width, height: height);
    } else {
      return ui.Image.network(loginBackgroundUrl, width: width, height: height);
    }
  }

  static ui.Image getLoginBackgroundDinoImage({double? width, double? height}) {
    if (testEnv) {
      return ui.Image.asset(loginBackgroundDinoUrl,
          width: width, height: height);
    } else {
      return ui.Image.network(loginBackgroundDinoUrl,
          width: width, height: height);
    }
  }

  static ui.Image getLogoDinoImage({double? width, double? height}) {
    if (testEnv) {
      return ui.Image.asset(logoDinoUrl, width: width, height: height);
    } else {
      return ui.Image.network(logoDinoUrl, width: width, height: height);
    }
  }
}
