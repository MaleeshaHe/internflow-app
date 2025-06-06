class WorkUpdate {
  final String userId;
  final String date;
  final bool plan;
  final bool coding;
  final bool debugging;
  final bool testing;
  final bool waiting;
  final bool onLeave;
  final String description;
  final String submittedAt;

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
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'description': description,
      'plan': plan,
      'coding': coding,
      'debugging': debugging,
      'testing': testing,
      'waiting': waiting,
      'onLeave': onLeave,
      'submittedAt': submittedAt,
    };
  }

  factory WorkUpdate.fromMap(Map<String, dynamic> map) {
    return WorkUpdate(
      plan: map['plan'] ?? false,
      coding: map['coding'] ?? false,
      debugging: map['debugging'] ?? false,
      testing: map['testing'] ?? false,
      waiting: map['waiting'] ?? false,
      onLeave: map['onLeave'] ?? false,
      userId: '',
      date: '',
      description: '',
      submittedAt: '',
    );
  }
}
