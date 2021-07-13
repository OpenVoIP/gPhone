import 'dart:io';
import 'dart:isolate';

import 'package:desktop_window/desktop_window.dart';
import 'package:gPhone/src/common/call.dart';
import 'package:gPhone/src/common/event.dart';

import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'src/register.dart';
import 'src/dialpad.dart';
import 'src/about.dart';

void newThread(String value) {
  startApp();
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    DesktopWindow.setWindowSize(Size(380, 600));
  }

  print("dart start_app");
  Isolate.spawn(
    newThread,
    "",
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [ChangeNotifierProvider(create: (_) => EventInfo())],
        child: Consumer<EventInfo>(builder: (context, eventinfo, _) {
          return MaterialApp(
              title: 'SoftPhone',
              debugShowCheckedModeBanner: false,
              theme: ThemeData(
                primarySwatch: Colors.blue,
                fontFamily: 'Roboto',
              ),
              initialRoute: '/',
              routes: {
                '/': (context) => DialPadWidget(),
                '/register': (context) => RegisterWidget(),
                '/about': (context) => AboutWidget(),
              });
        }));
  }
}
