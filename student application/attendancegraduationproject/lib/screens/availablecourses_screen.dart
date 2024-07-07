import 'dart:io';
import 'dart:convert' as convert;

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../data/universal_data.dart';

import '../models/course_model.dart';

import '../widget/bottom_navigation_bar_widget.dart';

import './courseattendance_screen.dart';

class AvailableCoursesScreen extends StatefulWidget {
  const AvailableCoursesScreen({super.key});

  @override
  State<AvailableCoursesScreen> createState() => _AvailableCoursesScreenState();
}

class _AvailableCoursesScreenState extends State<AvailableCoursesScreen> {
  bool isLoading = true;
  List<CourseModel> availableCourses = [];
  @override
  void initState() {
    super.initState();
    http.get(
      Uri.parse(
        'https://timegapws.com/content-manager/collection-types/api::aaa-course.aaa-course'
        '?filters[\$and][0][aaa_users][useridentification][\$eq]=${userData.useridentification}'
        '&sort=coursename:ASC'
        '&pageSize=6',
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
                availableCourses = [
                  ...availableCourses,
                  CourseModel.fromJson(course),
                ];
              }
            }
            isLoading = false;
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Courses'),
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
              // color: HexColor('##FC804B'),
              child: availableCourses.isNotEmpty
                  ? SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 35),
                      child: Column(
                        children: [
                          const SizedBox(height: 150),
                          for (var course in availableCourses) ...[
                            InkWell(
                              onTap: () {
                                // Get.to(CourseAttendanceScreen(courseName: course.name,));
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        CourseAttendanceScreen(
                                      courseName: course.name,
                                      totalAvailableLecture:
                                          course.availableLectures,
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                height: 100,
                                width: MediaQuery.sizeOf(context).width,
                                decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(25)),
                                  // color: Colors.black,
                                  color: Colors.lightBlueAccent[400],
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black,
                                      offset: Offset(0, 2),
                                      blurRadius: 2,
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Text(
                                    course.name,
                                    style: TextStyle(
                                      fontSize: 25,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                      fontFamily: 'Cairo',
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 50),
                          ],
                        ],
                      ),
                    )
                  : const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 35),
                        child: Text(
                          'You haven\'t registered in any course',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 25,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
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
