import 'package:flame/flame.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:space_fortress/screens/main_menu.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Flame.device.fullScreen();
  SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
  runApp(MaterialApp(
    title: "Space Fortress (Arabic Version)",
    debugShowCheckedModeBanner: false,
    themeMode: ThemeMode.dark,
    darkTheme: ThemeData(
      brightness: Brightness.dark,
      fontFamily: "BungeeInline",
      scaffoldBackgroundColor: Colors.black,
    ),
    home: const MainMenu(),
  ));
}
