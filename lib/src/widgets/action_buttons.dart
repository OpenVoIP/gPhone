import 'package:flutter/material.dart';
import 'package:gPhone/src/common/common.dart';
import 'package:gPhone/src/common/event.dart';
import 'package:gPhone/src/widgets/action_button.dart';
import 'package:provider/provider.dart';

class ActionButtons extends StatefulWidget {
  ActionButtons({Key key, @required this.timerCancel}) : super(key: key);

  @override
  _ActionButtonsState createState() => _ActionButtonsState();

  final void Function() timerCancel;
}

class _ActionButtonsState extends State<ActionButtons> {
  bool _showNumPad = false;
  bool _audioMuted = false;
  bool _videoMuted = false;
  bool _speakerOn = false;
  bool _hold = false;

  String _tansfer_target;

  void _handleAccept() {
    MethodChannelIns.invokeMethod('answer');
  }

  void _handleKeyPad() {
    this.setState(() {
      _showNumPad = !_showNumPad;
    });
  }

  void _toggleSpeaker() {
    setState(() {
      _speakerOn = !_speakerOn;
    });
  }

  void _muteAudio() {
    setState(() {
      _audioMuted = !_audioMuted;
    });
  }

  void _muteVideo() {
    setState(() {
      _videoMuted = !_videoMuted;
    });
  }

  void _handleHold() {
    setState(() {
      _hold = !_hold;
    });
  }

  void _handleDtmf(String tone) {
    print('Dtmf tone => $tone');
    // helper.sendDTMF(tone);
  }

  void _handleTransfer() {
    showDialog<Null>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('输入转接号码'),
          content: TextField(
            onChanged: (String text) {
              setState(() {
                _tansfer_target = text;
              });
            },
            decoration: InputDecoration(
              hintText: 'URI or Username',
            ),
            textAlign: TextAlign.center,
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('Ok'),
              onPressed: () {
                // helper.refer(_tansfer_target);
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  var hangupBtnInactive = ActionButton(
    title: "hangup",
    onPressed: () {},
    icon: Icons.call_end,
    fillColor: Colors.grey,
  );

  @override
  Widget build(BuildContext context) {
    var actionWidgets = <Widget>[];
    var basicActions = <Widget>[];
    var advanceActions = <Widget>[];
    var hangupBtn = ActionButton(
      title: "hangup",
      onPressed: () {
        MethodChannelIns.invokeMethod('hangup');
        widget.timerCancel();
      },
      icon: Icons.call_end,
      fillColor: Colors.red,
    );

    // 查询事件
    final event = Provider.of<EventInfo>(context);
    switch (event.type) {
      case "CALL_INCOMING":
        if (event.direction == 'incoming') {
          basicActions.add(ActionButton(
            title: "Accept",
            fillColor: Colors.green,
            icon: Icons.phone,
            onPressed: () => _handleAccept(),
          ));
          basicActions.add(hangupBtn);
        } else {
          basicActions.add(hangupBtn);
        }
        break;
      case "CALL_ESTABLISHED":
        {
          advanceActions.add(ActionButton(
            title: _audioMuted ? 'unmute' : 'mute',
            icon: _audioMuted ? Icons.mic_off : Icons.mic,
            checked: _audioMuted,
            onPressed: () => _muteAudio(),
          ));

          advanceActions.add(ActionButton(
            title: "keypad",
            icon: Icons.dialpad,
            onPressed: () => _handleKeyPad(),
          ));

          advanceActions.add(ActionButton(
            title: _speakerOn ? 'speaker off' : 'speaker on',
            icon: _speakerOn ? Icons.volume_off : Icons.volume_up,
            checked: _speakerOn,
            onPressed: () => _toggleSpeaker(),
          ));

          basicActions.add(ActionButton(
            title: _hold ? 'unhold' : 'hold',
            icon: _hold ? Icons.play_arrow : Icons.pause,
            checked: _hold,
            onPressed: () => _handleHold(),
          ));

          basicActions.add(hangupBtn);

          if (_showNumPad) {
            basicActions.add(ActionButton(
              title: "back",
              icon: Icons.keyboard_arrow_down,
              onPressed: () => _handleKeyPad(),
            ));
          } else {
            basicActions.add(ActionButton(
              title: "transfer",
              icon: Icons.phone_forwarded,
              onPressed: () => _handleTransfer(),
            ));
          }
        }
        break;
      case "CALL_TRANSFER":
      case "CALL_TRANSFER_FAILED":
        basicActions.add(hangupBtnInactive);
        break;
      case "CALL_PROGRESS":
      case "CALL_RINGING":
        basicActions.add(hangupBtn);
        break;
      default:
        print('Other state => ${event.type}');
        break;
    }

    if (_showNumPad) {
      actionWidgets.addAll(buildNumPad(_handleDtmf));
    } else {
      if (advanceActions.isNotEmpty) {
        actionWidgets.add(Padding(
            padding: const EdgeInsets.all(3),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: advanceActions)));
      }
    }

    actionWidgets.add(Padding(
        padding: const EdgeInsets.all(3),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: basicActions)));

    return Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.end,
        children: actionWidgets);
  }
}
