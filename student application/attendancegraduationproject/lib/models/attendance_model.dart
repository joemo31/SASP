class AttendanceModel {
  final int lectureId;
  final String lectureDate;
  final String lectureName;
  final String courseId;

  const AttendanceModel({
    required this.lectureId,
    required this.lectureDate,
    required this.lectureName,
    required this.courseId,
  });

  factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    return AttendanceModel(
      lectureId: json['id'] ?? 0,
      lectureDate: json['date'] ?? 'N/A',
      lectureName: json['lecturename'] ?? 'N/A',
      courseId: json['aaa_course']?['courseid'] ?? '0',
    );
  }
}
