import 'package:flutter/material.dart';
import 'package:gPhone/src/widgets/action_button.dart';

List<Widget> buildNumPad(handle) {
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
                        onPressed: () {
                          handle(label.keys.first);
                        },
                        number: true,
                      ))
                  .toList())))
      .toList();
}

bool showCallScreen(String status) {
  switch (status) {
    case "CALL_INCOMING":
    case "CALL_ESTABLISHED":
    case "CALL_RTPESTAB":
    case "CALL_RINGING":
      return true;
      break;
    case "CALL_CLOSED":
      return false;
    default:
      return false;
  }
}
