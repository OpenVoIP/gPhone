import 'dart:async';
import 'package:flutter/material.dart';
import 'package:gPhone/src/common/eventbus.dart';
import 'package:gPhone/src/widgets/action_buttons.dart';

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
  String _state = "";
  String direction = "";

  @override
  initState() {
    super.initState();
    _startTimer();
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
        _timer.cancel();
        break;
    }
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

    stackWidgets.add(ActionButtons(
      timerCancel: () {
        this._timer.cancel();
      },
    ));

    return Column(
      children: stackWidgets,
    );
  }

  @override
  Widget build(BuildContext context) {
    // final eventInfo = Provider.of<EventInfo>(context);
    return Container(
      child: _buildContent(),
    );
  }
}
