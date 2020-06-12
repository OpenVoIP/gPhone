import 'package:flutter/material.dart';
import 'package:gPhone/src/widgets/callscreen.dart';
import 'package:gPhone/src/common/common.dart';
import 'package:gPhone/src/common/event.dart';
import 'package:gPhone/src/widgets/pad.dart';
import 'package:provider/provider.dart';

class DialPadWidget extends StatefulWidget {
  DialPadWidget({Key key}) : super(key: key);
  @override
  _MyDialPadWidget createState() => _MyDialPadWidget();
}

class _MyDialPadWidget extends State<DialPadWidget> {
  String status = "";

  @override
  initState() {
    super.initState();
    EventStream.receiveBroadcastStream().listen((data) {
      print(data);
      switch (data['type']) {
        case 'CALL_REMOTE_SDP':
        case 'CALL_LOCAL_SDP':
        case 'CALL_RTPESTAB':
        case 'CALL_RTCP':
          return;
        default:
      }
      setState(() {
        status = data['type'];
      });

      Provider.of<EventInfo>(context, listen: false).update(data);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        bottomNavigationBar: BottomNavigationBar(
          // 底部导航
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
                icon: Icon(Icons.account_box), title: Text('帐号')),
            BottomNavigationBarItem(
                icon: Icon(Icons.dialpad), title: Text('拨号')),
            BottomNavigationBarItem(icon: Icon(Icons.info), title: Text('关于')),
          ],
          currentIndex: 1,
          fixedColor: Colors.blue,
          onTap: (value) {
            switch (value) {
              case 0:
                Navigator.pushNamed(context, '/register');
                break;
              case 2:
                Navigator.pushNamed(context, '/about');
                break;
              default:
            }
          },
        ),
        body: Align(
            alignment: Alignment(0, 0),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  if (showCallScreen(status))
                    Container(child: CallScreenWidget()),
                  if (!showCallScreen(status)) Container(child: Pad()),
                ])));
  }
}
