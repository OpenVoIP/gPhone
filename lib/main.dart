import 'package:gPhone/src/common/event.dart';

import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'src/register.dart';
import 'src/dialpad.dart';
import 'src/about.dart';

void main() {
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
