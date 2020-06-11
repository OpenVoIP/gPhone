import 'package:flutter/foundation.dart'
    show debugDefaultTargetPlatformOverride;

import 'package:flutter/material.dart';
import 'package:gPhone/src/common/common.dart';
import 'package:flutter_webrtc/webrtc.dart';
import 'package:gPhone/src/common/eventbus.dart';
import 'src/register.dart';
import 'src/dialpad.dart';
import 'src/callscreen.dart';
import 'src/about.dart';

void main() {
  if (WebRTC.platformIsDesktop) {
    debugDefaultTargetPlatformOverride = TargetPlatform.fuchsia;
  }
  runApp(MyApp());
  EventStream.receiveBroadcastStream().listen((data) {
    print('EventStream get event');
    print(data);

    bus.emit("call_data", data);
  });
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
        '/callscreen': (context) => CallScreenWidget(),
        '/about': (context) => AboutWidget(),
      },
    );
  }
}
