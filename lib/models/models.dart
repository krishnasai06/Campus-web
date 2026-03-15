class UserModel {
  final String netID;
  final String? name;
  final String? regNo;

  UserModel({
    required this.netID,
    this.name,
    this.regNo,
  });

  Map<String, dynamic> toJson() => {
    'netID': netID,
    'name': name,
    'regNo': regNo,
  };

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    netID: json['netID'],
    name: json['name'],
    regNo: json['regNo'],
  );

  UserModel copyWith({
    String? netID,
    String? name,
    String? regNo,
  }) => UserModel(
    netID: netID ?? this.netID,
    name: name ?? this.name,
    regNo: regNo ?? this.regNo,
  );
}

class AttendanceModel {
  final String subjectCode;
  final String subjectName;
  final int attended;
  final int total;
  final double percentage;

  AttendanceModel({
    required this.subjectCode,
    required this.subjectName,
    required this.attended,
    required this.total,
    required this.percentage,
  });

  Map<String, dynamic> toJson() => {
    'subjectCode': subjectCode,
    'subjectName': subjectName,
    'attended': attended,
    'total': total,
    'percentage': percentage,
  };

  factory AttendanceModel.fromJson(Map<String, dynamic> json) => AttendanceModel(
    subjectCode: json['subjectCode'],
    subjectName: json['subjectName'],
    attended: json['attended'],
    total: json['total'],
    percentage: json['percentage'].toDouble(),
  );
}

class MarksModel {
  final String subjectCode;
  final String subjectName;
  final String? internal;
  final String? external;
  final String? total;
  final String? grade;

  MarksModel({
    required this.subjectCode,
    required this.subjectName,
    this.internal,
    this.external,
    this.total,
    this.grade,
  });

  Map<String, dynamic> toJson() => {
    'subjectCode': subjectCode,
    'subjectName': subjectName,
    'internal': internal,
    'external': external,
    'total': total,
    'grade': grade,
  };

  factory MarksModel.fromJson(Map<String, dynamic> json) => MarksModel(
    subjectCode: json['subjectCode'],
    subjectName: json['subjectName'],
    internal: json['internal'],
    external: json['external'],
    total: json['total'],
    grade: json['grade'],
  );
}

class TimetableModel {
  final String day;
  final String slot;
  final String time;
  final String subject;
  final String? room;
  final String? faculty;

  TimetableModel({
    required this.day,
    required this.slot,
    required this.time,
    required this.subject,
    this.room,
    this.faculty,
  });

  Map<String, dynamic> toJson() => {
    'day': day,
    'slot': slot,
    'time': time,
    'subject': subject,
    'room': room,
    'faculty': faculty,
  };

  factory TimetableModel.fromJson(Map<String, dynamic> json) => TimetableModel(
    day: json['day'],
    slot: json['slot'],
    time: json['time'],
    subject: json['subject'],
    room: json['room'],
    faculty: json['faculty'],
  );
}
