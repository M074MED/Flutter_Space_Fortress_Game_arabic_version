import 'package:backendless_sdk/backendless_sdk.dart';
import 'package:flutter/cupertino.dart';

class InitApp {
  static final String apiKeyAndroid = '';
  static final String apiKeyiOS = '';
  static final String apiKeyJS = '';
  static final String appID = '';

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
