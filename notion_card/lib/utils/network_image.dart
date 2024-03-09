import 'package:flutter/material.dart' as ui;

class NetworkImageConstants {
  static const devEnv = true;

  static const String loginBackgroundUrl = 'loginbg.png';

  static const String loginBackgroundDinoUrl = "loginDino.png";

  static const String logoDinoUrl = "logoDino.png";

  static const String loading_1 = "loading_1.png";
  static const String loading_2 = "loading_2.png";
  static const String loading_3 = "loading_3.png";

  static ui.Image getImageByUrl(String url, {double? width, double? height}) {
    if (devEnv) {
      return ui.Image.asset(url, width: width, height: height);
    } else {
      return ui.Image.network(url, width: width, height: height);
    }
  }

  static ui.Image getLoginBackgroundImage({double? width, double? height}) {
    if (devEnv) {
      return ui.Image.asset(loginBackgroundUrl, width: width, height: height);
    } else {
      return ui.Image.network(loginBackgroundUrl, width: width, height: height);
    }
  }

  static ui.Image getLoginBackgroundDinoImage({double? width, double? height}) {
    if (devEnv) {
      return ui.Image.asset(loginBackgroundDinoUrl,
          width: width, height: height);
    } else {
      return ui.Image.network(loginBackgroundDinoUrl,
          width: width, height: height);
    }
  }

  static ui.Image getLogoDinoImage({double? width, double? height}) {
    if (devEnv) {
      return ui.Image.asset(logoDinoUrl, width: width, height: height);
    } else {
      return ui.Image.network(logoDinoUrl, width: width, height: height);
    }
  }

  static List<ui.Image> getLoadingIndicatorImages() {
    return [
      // Under Beta Testing - Waiting for design of frames
      // getImageByUrl(loading_1, height: 100, width: 100),
      // getImageByUrl(loading_2, height: 130, width: 100),
      // getImageByUrl(loading_3, height: 160, width: 100),
      // getImageByUrl(loading_2, height: 130, width: 100),
    ];
  }
}
