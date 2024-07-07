// class AttendanceModel {
class LectureModel {
  final int lectureId;
  final String lectureDate;
  final String lectureName;
  final String courseId;

  const LectureModel({
    required this.lectureId,
    required this.lectureDate,
    required this.lectureName,
    required this.courseId,
  });

  factory LectureModel.fromJson(Map<String, dynamic> json) {
    return LectureModel(
      lectureId: json['id'] ?? 0,
      lectureDate: json['date'] ?? 'N/A',
      lectureName: json['lecturename'] ?? 'N/A',
      courseId: json['aaa_course']?['courseid'] ?? '0',
    );
  }
}
