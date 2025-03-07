import 'package:flutter/foundation.dart';

enum SessionType {
  course,
  td,
  tp;

  String get display {
    switch (this) {
      case SessionType.course:
        return 'COURSE';
      case SessionType.td:
        return 'TD';
      case SessionType.tp:
        return 'TP';
    }
  }
}

@immutable
class SessionModel {
  final String id;
  final String title;
  final String courseId;
  final String teacherId;
  final String groupId;
  final DateTime sessionDate;
  final String startTime;
  final String endTime;
  final String room;
  final SessionType type;
  final String? qrCode;
  final DateTime? qrExpiry;
  final DateTime createdAt;
  final DateTime updatedAt;

  const SessionModel({
    required this.id,
    required this.title,
    required this.courseId,
    required this.teacherId,
    required this.groupId,
    required this.sessionDate,
    required this.startTime,
    required this.endTime,
    required this.room,
    required this.type,
    this.qrCode,
    this.qrExpiry,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SessionModel.fromJson(Map<String, dynamic> json) {
    return SessionModel(
      id: json['id'] as String,
      title: json['title'] as String,
      courseId: json['course_id'] as String,
      teacherId: json['teacher_id'] as String,
      groupId: json['group_id'] as String,
      sessionDate: DateTime.parse(json['session_date'] as String),
      startTime: json['start_time'] as String,
      endTime: json['end_time'] as String,
      room: json['room'] as String,
      type: SessionType.values.firstWhere(
        (t) => t.name == json['type_c'],
        orElse: () => SessionType.course,
      ),
      qrCode: json['qr_code'] as String?,
      qrExpiry:
          json['qr_expiry'] != null
              ? DateTime.parse(json['qr_expiry'] as String)
              : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'course_id': courseId,
    'teacher_id': teacherId,
    'group_id': groupId,
    'session_date': sessionDate.toIso8601String(),
    'start_time': startTime,
    'end_time': endTime,
    'room': room,
    'type_c': type.name,
    'qr_code': qrCode,
    'qr_expiry': qrExpiry?.toIso8601String(),
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };

  SessionModel copyWith({
    String? id,
    String? title,
    String? courseId,
    String? teacherId,
    String? groupId,
    DateTime? sessionDate,
    String? startTime,
    String? endTime,
    String? room,
    SessionType? type,
    String? qrCode,
    DateTime? qrExpiry,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SessionModel(
      id: id ?? this.id,
      title: title ?? this.title,
      courseId: courseId ?? this.courseId,
      teacherId: teacherId ?? this.teacherId,
      groupId: groupId ?? this.groupId,
      sessionDate: sessionDate ?? this.sessionDate,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      room: room ?? this.room,
      type: type ?? this.type,
      qrCode: qrCode ?? this.qrCode,
      qrExpiry: qrExpiry ?? this.qrExpiry,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SessionModel &&
        other.id == id &&
        other.title == title &&
        other.courseId == courseId &&
        other.teacherId == teacherId &&
        other.groupId == groupId &&
        other.sessionDate == sessionDate &&
        other.startTime == startTime &&
        other.endTime == endTime &&
        other.room == room &&
        other.type == type &&
        other.qrCode == qrCode &&
        other.qrExpiry == qrExpiry &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      title,
      courseId,
      teacherId,
      groupId,
      sessionDate,
      startTime,
      endTime,
      room,
      type,
      qrCode,
      qrExpiry,
      createdAt,
      updatedAt,
    );
  }
}
