import 'package:backendless_sdk/backendless_sdk.dart';
import 'package:flutter/cupertino.dart';

class InitApp {
  static final String apiKeyAndroid = '19DEC320-FE90-4D61-80EB-3CFD5DE41342';
  static final String apiKeyiOS = '1A4A8C7F-273F-4D56-9C07-9A88D4915596';
  static final String apiKeyJS = '0D2522AF-38D9-429E-917E-101F15DA749D';
  static final String appID = '12DC9C38-DDCA-BDCC-FF5F-3BA98F251B00';

  static void initializeApp(BuildContext context) async {
    String result = "OK";
    Backendless.setUrl('https://api.backendless.com');
    await Backendless.initApp(
            applicationId: appID,
            iosApiKey: apiKeyiOS,
            androidApiKey: apiKeyAndroid,
            jsApiKey: apiKeyJS,
            )
        .onError((error, stackTrace) {
      result = error.toString();
    });
    if (result == 'OK') {
      print(result);
    } else {
      print(result);
    }
  }
}
