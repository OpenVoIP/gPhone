import 'package:flutter/material.dart';
import 'package:gPhone/src/common/call.dart';
import 'package:gPhone/src/common/common.dart';
import 'package:gPhone/src/widgets/action_button.dart';
import 'package:ffi/ffi.dart';

class Pad extends StatefulWidget {
  Pad({Key key}) : super(key: key);

  @override
  _PadState createState() => _PadState();
}

class _PadState extends State<Pad> {
  TextEditingController textController = TextEditingController();

  void _handleBackSpace([bool deleteAll = false]) {
    var text = textController.text;
    if (text.isNotEmpty) {
      this.setState(() {
        text = deleteAll ? '' : text.substring(0, text.length - 1);
        textController.text = text;
      });
    }
  }

  void _handleNum(String number) {
    this.setState(() {
      textController.text = '${textController.text}$number';
      // textController =
      //     TextEditingController(text: '${textController.text}$number');
    });
  }

  Widget _handleCall(BuildContext context, [bool voiceonly = false]) {
    var dest = textController.text;
    if (dest == null || dest.isEmpty) {
      showDialog<Null>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('失败!!'),
            content: Text('请输入号码'),
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
    // 拨打
    // MethodChannelIns.invokeMethod('dial', dest);
    print("callApp");
    callApp(dest.toNativeUtf8());
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
            width: 300,
            child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                      width: 300,
                      child: TextField(
                        keyboardType: TextInputType.text,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 24, color: Colors.black54),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                        ),
                        controller: textController,
                      )),
                ])),
        Container(
            width: 300,
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: buildNumPad(_handleNum))),
        Container(
            width: 300,
            child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    // ActionButton(
                    //   icon: Icons.videocam,
                    //   onPressed: () => _handleCall(context),
                    // ),
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
      ],
    );
  }
}
