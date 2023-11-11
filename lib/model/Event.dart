import 'package:flutter/material.dart';

class Event {
  String activityName;
  String description;
  DateTime startDate;
  DateTime endDate;
  TimeOfDay time;
  String venue;
  String urgency;
  String activityType;
  int numVolunteers;
  String approvalLetter;
  String? posterUrl;
  String? organizerEmail;

  Event(
      {required this.activityName,
      required this.description,
      required this.startDate,
      required this.endDate,
      required this.time,
      required this.venue,
      required this.urgency,
      required this.activityType,
      required this.numVolunteers,
      required this.approvalLetter,
      this.posterUrl,
      this.organizerEmail});

  Map<String, dynamic> toJson() => {
        'activityName': activityName,
        'description': description,
        'startDate':
            startDate.toIso8601String(), // ISO8601 string format for date
        'endDate': endDate.toIso8601String(), // ISO8601 string format for date
        'time': "${time.hour}:${time.minute}", // String format for time
        'venue': venue,
        'urgency': urgency,
        'activityType': activityType,
        'numVolunteers': numVolunteers,
        'approvalLetter': approvalLetter,
        'posterUrl': posterUrl,
        'organizerEmail': organizerEmail,
      };
}
