class CourseModel {
  final int id;
  final String name;
  final String courseId;
  final int availableCourses;

  const CourseModel({
    required this.id,
    required this.name,
    required this.courseId,
    required this.availableCourses,
  });

  factory CourseModel.fromJson(Map<String, dynamic> json) {
    return CourseModel(
      id: json['id'] ?? 'N/A',
      name: json['coursename'] ?? 'N/A',
      courseId: json['courseid'] ?? 'N/A',
      availableCourses:
          int.tryParse(json['aaa_lectures']['count'].toString()) ?? 0,
    );
  }
}
