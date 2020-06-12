import 'package:flutter/material.dart';

class EventInfo with ChangeNotifier {
  String type;
  String direction;

  // static EventInfo fromEvent(dynamic input) {
  //   var data = new Map<String, dynamic>.from(input);
  //   return new EventInfo()
  //     ..type = data['name']
  //     ..direction = data['direction'];
  // }

  update(dynamic data) {
    this.direction = data['direction'];
    this.type = data['type'];
    notifyListeners();
  }
}
