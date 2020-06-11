import 'dart:async';
import 'package:flutter/material.dart';
import 'package:gPhone/src/common/common.dart';
import 'package:gPhone/src/common/eventbus.dart';

import 'widgets/action_button.dart';
import 'package:sip_ua/sip_ua.dart';

class CallScreenWidget extends StatefulWidget {
  CallScreenWidget({Key key}) : super(key: key);
  @override
  _MyCallScreenWidget createState() => _MyCallScreenWidget();
}

class _MyCallScreenWidget extends State<CallScreenWidget> {
  bool _showNumPad = false;

  String _timeLabel = '00:00';
  Timer _timer;

  bool _audioMuted = false;
  bool _videoMuted = false;
  bool _speakerOn = false;
  bool _hold = false;
  String _holdOriginator;
  String _state = "CALL_INCOMING";
  String direction = "";

  @override
  initState() {
    super.initState();
    _startTimer();
    bus.on('call_data', (data) {
      if (mounted) {
        setState(() {
          _state = data['type'];
          direction = data['direction'];
        });
      } else {
        _state = data['type'];
        direction = data['direction'];
      }

      print('state value');
      print(_state);

      callStateChanged();
    });
  }

  @override
  deactivate() {
    super.deactivate();
  }

  @override
  void dispose() {
    bus.off("call_data");
    _timer.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (Timer timer) {
      Duration duration = Duration(seconds: timer.tick);
      if (mounted) {
        this.setState(() {
          _timeLabel = [duration.inMinutes, duration.inSeconds]
              .map((seg) => seg.remainder(60).toString().padLeft(2, '0'))
              .join(':');
        });
      } else {
        _timer.cancel();
      }
    });
  }

  void callStateChanged() {
    switch (_state) {
      case "CALL_CLOSED":
        _backToDialPad();
        break;
    }
  }

  void _backToDialPad() {
    _timer.cancel();
    Timer(Duration(seconds: 2), () {
      Navigator.of(context).pop();
    });
  }

  void _handleHangup() {
    MethodChannelIns.invokeMethod('hangup');
    _timer.cancel();
  }

  void _handleAccept() {
    MethodChannelIns.invokeMethod('answer');
  }

  void _muteAudio() {
    if (_audioMuted) {
      // helper.unmute(true, false);
    } else {
      // helper.mute(true, false);
    }
  }

  void _muteVideo() {
    if (_videoMuted) {
      // helper.unmute(false, true);
    } else {
      // helper.mute(false, true);
    }
  }

  void _handleHold() {
    if (_hold) {
      // helper.unhold();
    } else {
      // helper.hold();
    }
  }

  String _tansfer_target;
  void _handleTransfer() {
    showDialog<Null>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Enter target to transfer.'),
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

  void _handleDtmf(String tone) {
    print('Dtmf tone => $tone');
    // helper.sendDTMF(tone);
  }

  void _handleKeyPad() {
    this.setState(() {
      _showNumPad = !_showNumPad;
    });
  }

  void _toggleSpeaker() {
    // if (_localStream != null) {
    //   _speakerOn = !_speakerOn;
    //   _localStream.getAudioTracks()[0].enableSpeakerphone(_speakerOn);
    // }
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
            padding: const EdgeInsets.all(3),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: row
                    .map((label) => ActionButton(
                          title: '${label.keys.first}',
                          subTitle: '${label.values.first}',
                          onPressed: () => _handleDtmf(label.keys.first),
                          number: true,
                        ))
                    .toList())))
        .toList();
  }

  Widget _buildActionButtons() {
    var hangupBtn = ActionButton(
      title: "hangup",
      onPressed: () => _handleHangup(),
      icon: Icons.call_end,
      fillColor: Colors.red,
    );

    var hangupBtnInactive = ActionButton(
      title: "hangup",
      onPressed: () {},
      icon: Icons.call_end,
      fillColor: Colors.grey,
    );

    var basicActions = <Widget>[];
    var advanceActions = <Widget>[];

    switch (_state) {
      case "CALL_INCOMING":
        print('direction: $direction');
        if (direction == 'incoming') {
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
        basicActions.add(hangupBtn);
        break;
      default:
        print('Other state => $_state');
        break;
    }

    var actionWidgets = <Widget>[];

    if (_showNumPad) {
      actionWidgets.addAll(_buildNumPad());
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

  Widget _buildContent() {
    var stackWidgets = <Widget>[];

    stackWidgets.addAll([
      Positioned(
        top: 48,
        left: 0,
        right: 0,
        child: Center(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Center(
                child: Padding(
                    padding: const EdgeInsets.all(6),
                    child: Text(
                      ('VOICE CALL') +
                          (_hold
                              ? ' PAUSED BY ${this._holdOriginator.toUpperCase()}'
                              : ''),
                      style: TextStyle(fontSize: 24, color: Colors.black54),
                    ))),
            Center(
                child: Padding(
                    padding: const EdgeInsets.all(6),
                    child: Text(
                      '1000',
                      style: TextStyle(fontSize: 18, color: Colors.black54),
                    ))),
            Center(
                child: Padding(
                    padding: const EdgeInsets.all(6),
                    child: Text(_timeLabel,
                        style: TextStyle(fontSize: 14, color: Colors.black54))))
          ],
        )),
      ),
    ]);

    return Stack(
      children: stackWidgets,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            automaticallyImplyLeading: false,
            title: Text('[$direction] ${EnumHelper.getName(_state)}')),
        body: Container(
          child: _buildContent(),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: Padding(
            padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 24.0),
            child: Container(width: 320, child: _buildActionButtons())));
  }
}
