import 'package:flutter/material.dart';
import 'package:gPhone/src/common/common.dart';
import 'package:gPhone/src/common/eventbus.dart';
import 'package:sip_ua/sip_ua.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'widgets/action_button.dart';

class DialPadWidget extends StatefulWidget {
  DialPadWidget({Key key}) : super(key: key);
  @override
  _MyDialPadWidget createState() => _MyDialPadWidget();
}

class _MyDialPadWidget extends State<DialPadWidget> {
  String _dest;
  String status = "";
  TextEditingController _textController;
  SharedPreferences _preferences;

  @override
  initState() {
    super.initState();
    _loadSettings();
    bus.on('call_data', (data) {
      print("dialpad bus on data");
      print(data);

      setState(() {
        status = data['type'];
      });
      if (status == 'CALL_INCOMING') {
        Navigator.pushNamed(context, '/callscreen');
      }
    });
  }

  @override
  deactivate() {
    super.deactivate();
  }

  @override
  void dispose() {
    bus.off("call_data");
    super.dispose();
  }

  void _loadSettings() async {
    _preferences = await SharedPreferences.getInstance();
    _dest = _preferences.getString('dest') ?? 'sip:xxx@www.com';
    _textController = TextEditingController(text: _dest);
    _textController.text = _dest;
    this.setState(() {});
  }

  Widget _handleCall(BuildContext context, [bool voiceonly = false]) {
    var dest = _textController.text;
    if (dest == null || dest.isEmpty) {
      showDialog<Null>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Target is empty.'),
            content: Text('Please enter a SIP URI or username!'),
            actions: <Widget>[
              FlatButton(
                child: Text('Ok'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
      return null;
    }

    MethodChannelIns.invokeMethod('dial', dest);
    _preferences.setString('dest', dest);
    return null;
  }

  void _handleBackSpace([bool deleteAll = false]) {
    var text = _textController.text;
    if (text.isNotEmpty) {
      this.setState(() {
        text = deleteAll ? '' : text.substring(0, text.length - 1);
        _textController.text = text;
      });
    }
  }

  void _handleNum(String number) {
    this.setState(() {
      _textController.text += number;
    });
  }

  List<Widget> _buildNumPad() {
    var lables = [
      [
        {'1': ''},
        {'2': 'abc'},
        {'3': 'def'}
      ],
      [
        {'4': 'ghi'},
        {'5': 'jkl'},
        {'6': 'mno'}
      ],
      [
        {'7': 'pqrs'},
        {'8': 'tuv'},
        {'9': 'wxyz'}
      ],
      [
        {'*': ''},
        {'0': '+'},
        {'#': ''}
      ],
    ];

    return lables
        .map((row) => Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: row
                    .map((label) => ActionButton(
                          title: '${label.keys.first}',
                          subTitle: '${label.values.first}',
                          onPressed: () => _handleNum(label.keys.first),
                          number: true,
                        ))
                    .toList())))
        .toList();
  }

  List<Widget> _buildDialPad() {
    return [
      Container(
          width: 360,
          child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                    width: 360,
                    child: TextField(
                      keyboardType: TextInputType.text,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 24, color: Colors.black54),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                      ),
                      controller: _textController,
                    )),
              ])),
      Container(
          width: 300,
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: _buildNumPad())),
      Container(
          width: 300,
          child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  ActionButton(
                    icon: Icons.videocam,
                    onPressed: () => _handleCall(context),
                  ),
                  ActionButton(
                    icon: Icons.dialer_sip,
                    fillColor: Colors.green,
                    onPressed: () => _handleCall(context, true),
                  ),
                  ActionButton(
                    icon: Icons.keyboard_arrow_left,
                    onPressed: () => _handleBackSpace(),
                    onLongPress: () => _handleBackSpace(true),
                  ),
                ],
              )))
    ];
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
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(6.0),
                    child: Center(
                        child: Text(
                      status,
                      style: TextStyle(fontSize: 14, color: Colors.black54),
                    )),
                  ),
                  Container(
                      child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: _buildDialPad(),
                  )),
                ])));
  }
}
