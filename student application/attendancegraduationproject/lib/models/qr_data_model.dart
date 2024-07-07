import 'dart:convert';

class QrDataModel {
  final int lectureId;
  final String doctorName;
  final int courseId;
  final String lectureName;
  final String lectureDate;
  final DateTime expiredTime;
  final String createdTime;

  const QrDataModel({
    required this.lectureId,
    required this.doctorName,
    required this.courseId,
    required this.lectureName,
    required this.lectureDate,
    required this.expiredTime,
    required this.createdTime,
  });

  Map<String, dynamic> toMap() {
    return {
      'lectureId': lectureId,
      'doctorName': doctorName,
      'courseId': courseId,
      'lectureName': lectureName,
      'lectureDate': lectureDate,
      'expiredTime': expiredTime.millisecondsSinceEpoch,
      'createdTime': createdTime,
    };
  }

  factory QrDataModel.fromMap(Map<String, dynamic> map) {
    return QrDataModel(
      lectureId: map['lectureId']?.toInt() ?? 0,
      doctorName: map['doctorName'] ?? '',
      courseId: map['courseId'] ?? '',
      lectureName: map['lectureName'] ?? '',
      lectureDate: map['lectureDate'] ?? '',
      expiredTime: DateTime.fromMillisecondsSinceEpoch(map['expiredTime']),
      createdTime: map['createdTime'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory QrDataModel.fromJson(String source) =>
      QrDataModel.fromMap(json.decode(source));

  @override
  String toString() {
    return 'QrDataModel(lectureId: $lectureId, doctorName: $doctorName, courseId: $courseId, lectureName: $lectureName, lectureDate: $lectureDate, expiredTime: $expiredTime, createdTime: $createdTime)';
  }
}
