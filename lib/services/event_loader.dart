import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:move_young/models/event_model.dart';

Future<List<Event>> loadEventsFromJson() async {
  final String jsonString = await rootBundle.loadString('assets/events/upcoming_events.json');
  final List<dynamic> jsonList = json.decode(jsonString);
  return jsonList.map((json) => Event.fromJson(json)).toList();
}
