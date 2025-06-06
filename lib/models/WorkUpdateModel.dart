import 'package:cloud_firestore/cloud_firestore.dart';

class WorkUpdate {
  final String userId;
  final String date; // ISO format: yyyy-MM-dd
  final bool plan;
  final bool coding;
  final bool debugging;
  final bool testing;
  final bool waiting;
  final bool onLeave;
  final String description;
  final String submittedAt;
  final Timestamp? timestamp;

  WorkUpdate({
    required this.userId,
    required this.date,
    required this.plan,
    required this.coding,
    required this.debugging,
    required this.testing,
    required this.waiting,
    required this.onLeave,
    required this.description,
    required this.submittedAt,
    this.timestamp,
  });

  factory WorkUpdate.fromJson(Map<String, dynamic> json) {
    return WorkUpdate(
      userId: json['userId'] ?? '',
      date: json['date'] ?? '',
      plan: json['plan'] ?? false,
      coding: json['coding'] ?? false,
      debugging: json['debugging'] ?? false,
      testing: json['testing'] ?? false,
      waiting: json['waiting'] ?? false,
      onLeave: json['onLeave'] ?? false,
      description: json['description'] ?? '',
      submittedAt: json['submittedAt'] ?? '',
      timestamp: json['timestamp'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'date': date,
      'plan': plan,
      'coding': coding,
      'debugging': debugging,
      'testing': testing,
      'waiting': waiting,
      'onLeave': onLeave,
      'description': description,
      'submittedAt': submittedAt,
      'timestamp': timestamp ?? FieldValue.serverTimestamp(),
    };
  }
}
