import 'dart:io';
import 'dart:convert' as convert;

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../data/universal_data.dart';

import '../models/attendance_model.dart';

import '../widget/bottom_navigation_bar_widget.dart';

class CourseAttendanceScreen extends StatefulWidget {
  const CourseAttendanceScreen({
    required this.courseName,
    required this.totalAvailableLecture,
    super.key,
  });
  final String courseName;
  final int totalAvailableLecture;

  @override
  State<CourseAttendanceScreen> createState() => _CourseAttendanceScreenState();
}

class _CourseAttendanceScreenState extends State<CourseAttendanceScreen> {
  bool isLoading = true;
  List<AttendanceModel> _attendancesList = [];
  @override
  void initState() {
    super.initState();
    http.get(
      Uri.parse(
        'https://timegapws.com/content-manager/collection-types/api::aaa-lecture.aaa-lecture'
        '?filters[\$and][0][aaa_course][coursename][\$eq]=${widget.courseName}'
        '&filters[\$and][1][aaa_users][useridentification][\$eq]=${userData.useridentification}'
        '&sort=id:ASC'
        '&pageSize=12',
      ),
      headers: {HttpHeaders.authorizationHeader: token},
    ).then(
      (res) {
        var responseJson = convert.jsonDecode(res.body);

        print('Response json body is $responseJson');

        setState(
          () {
            if ((responseJson['results'] != null) &&
                ((responseJson['results'] as List).isNotEmpty)) {
              for (var course in (responseJson['results'] as List)) {
                _attendancesList = [
                  ..._attendancesList,
                  AttendanceModel.fromJson(course),
                ];
              }
            }
            isLoading = false;
            print('Length of attendance is ${_attendancesList.length}');
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance'),
        titleTextStyle: const TextStyle(
          // color: Colors.black,
          fontSize: 24,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
        // backgroundColor: Colors.blue,
        // backgroundColor: Colors.blue[900],
        backgroundColor: Colors.lightBlueAccent[700],
        foregroundColor: Colors.white,
        shadowColor: Colors.redAccent,
        elevation: 5,
      ),
      // backgroundColor: Colors.blueGrey[900],
      backgroundColor: const Color(0xffF5F5F5),
      bottomNavigationBar: const CustomBottomNavigationBarWidget(),
      body: !isLoading
          ? SizedBox(
              height: MediaQuery.sizeOf(context).height,
              width: MediaQuery.sizeOf(context).width,
              child:
                  /*_attendancesList.isNotEmpty
                  ?*/
                  Padding(
                padding: const EdgeInsets.only(top: 20, left: 8, right: 8),
                child: SingleChildScrollView(
                  child: Table(
                    border: TableBorder.all(
                      color: Colors.black,
                      width: 2,
                    ),
                    defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                    children: [
                      TableRow(
                        decoration: const BoxDecoration(
                          color: Colors.grey,
                        ),
                        children: [
                          SizedBox(
                            height: 50,
                            child: Center(
                              child: Text(
                                'Lecture ${widget.courseName}',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 50,
                            child: Center(
                              child: Text(
                                'Attendance',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      for (int i = 0;
                          i <
                              (widget.totalAvailableLecture > 20
                                  ? 20
                                  : widget.totalAvailableLecture);
                          i++)
                        TableRow(
                          children: [
                            SizedBox(
                              height: 50,
                              child: Center(
                                child: Text(
                                  'Lecture ${i + 1}',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 50,
                              child: Center(
                                child: _attendancesList.indexWhere(
                                          (element) {
                                            return (element.lectureName ==
                                                    'lec${i + 1}') ==
                                                true;
                                          },
                                        ) !=
                                        -1
                                    ? const Icon(
                                        Icons.check_box,
                                        color: Colors.black,
                                        size: 25,
                                      )
                                    : Container(),
                              ),
                            ),
                          ],
                        ),
                      TableRow(
                        decoration: const BoxDecoration(
                          color: Colors.grey,
                        ),
                        children: [
                          const SizedBox(
                            height: 50,
                            child: Center(
                              child: Text(
                                'Total Attendance',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 50,
                            child: Center(
                              child: Text(
                                '${_attendancesList.length}/${(widget.totalAvailableLecture > 20 ? 20 : widget.totalAvailableLecture)}',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              )
              /* : const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 35),
                        child: Text(
                          'You haven\'t Attend any lecture',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 25,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),*/
              )
          : const Center(
              child: CircularProgressIndicator(
                color: Colors.black,
                strokeAlign: 3,
                strokeWidth: 25,
                // strokeAlign: 50,
              ),
            ),
    );
  }
}
