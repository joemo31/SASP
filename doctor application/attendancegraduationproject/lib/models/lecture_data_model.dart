class LectureDataModel {
  final int id;
  final String lectureName;
  final String lectureDate;
  // final CourseModel courseData;

  const LectureDataModel({
    required this.id,
    required this.lectureName,
    required this.lectureDate,
    // required this.courseData,
  });

  factory LectureDataModel.fromJson(Map<String, dynamic> json) {
    return LectureDataModel(
      id: json['id'] ?? 0,
      lectureName: json['lecturename'] ?? 'N/A',
      lectureDate: json['date'] ?? 'N/A',
      // courseData: CourseModel.fromJson(json['aaa_course'] ?? {}),
    );
  }

  @override
  String toString() =>
      'LectureDataModel(id: $id, lectureName: $lectureName, lectureDate: $lectureDate)';
}
