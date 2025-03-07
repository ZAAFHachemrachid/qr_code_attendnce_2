enum AttendanceStatus {
  present('present'),
  absent('absent'),
  late('late'),
  excused('excused');

  final String value;
  const AttendanceStatus(this.value);

  static AttendanceStatus fromString(String value) {
    return AttendanceStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => AttendanceStatus.absent,
    );
  }

  @override
  String toString() => value;
}

class Attendance {
  final String id;
  final String sessionId;
  final String studentId;
  final AttendanceStatus status;
  final DateTime? checkInTime;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Student profile info (from join)
  final String? studentFirstName;
  final String? studentLastName;
  final String? studentNumber;

  String get studentFullName =>
      (studentFirstName != null && studentLastName != null)
          ? '$studentFirstName $studentLastName'
          : 'Unknown Student';

  const Attendance({
    required this.id,
    required this.sessionId,
    required this.studentId,
    required this.status,
    this.checkInTime,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.studentFirstName,
    this.studentLastName,
    this.studentNumber,
  });

  factory Attendance.fromJson(Map<String, dynamic> json) {
    // Handle nested student profile data if present
    Map<String, dynamic>? studentProfile =
        json['student_profiles'] as Map<String, dynamic>?;

    return Attendance(
      id: json['id'] as String,
      sessionId: json['session_id'] as String,
      studentId: json['student_id'] as String,
      status: AttendanceStatus.fromString(json['status'] as String),
      checkInTime:
          json['check_in_time'] == null
              ? null
              : DateTime.parse(json['check_in_time'] as String),
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      studentFirstName: studentProfile?['first_name'] as String?,
      studentLastName: studentProfile?['last_name'] as String?,
      studentNumber: studentProfile?['student_number'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'session_id': sessionId,
      'student_id': studentId,
      'status': status.toString(),
      'check_in_time': checkInTime?.toIso8601String(),
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Attendance copyWith({
    String? sessionId,
    String? studentId,
    AttendanceStatus? status,
    DateTime? checkInTime,
    String? notes,
    DateTime? updatedAt,
    String? studentFirstName,
    String? studentLastName,
    String? studentNumber,
  }) {
    return Attendance(
      id: id,
      sessionId: sessionId ?? this.sessionId,
      studentId: studentId ?? this.studentId,
      status: status ?? this.status,
      checkInTime: checkInTime ?? this.checkInTime,
      notes: notes ?? this.notes,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      studentFirstName: studentFirstName ?? this.studentFirstName,
      studentLastName: studentLastName ?? this.studentLastName,
      studentNumber: studentNumber ?? this.studentNumber,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Attendance &&
        other.id == id &&
        other.sessionId == sessionId &&
        other.studentId == studentId &&
        other.status == status &&
        other.checkInTime == checkInTime &&
        other.notes == notes &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.studentFirstName == studentFirstName &&
        other.studentLastName == studentLastName &&
        other.studentNumber == studentNumber;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      sessionId,
      studentId,
      status,
      checkInTime,
      notes,
      createdAt,
      updatedAt,
      studentFirstName,
      studentLastName,
      studentNumber,
    );
  }
}
