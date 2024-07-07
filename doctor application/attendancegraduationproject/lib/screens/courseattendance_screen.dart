import 'dart:io';
import 'dart:convert' as convert;

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;

import '../data/universal_data.dart';

import '../models/attendance_model.dart';

import '../models/user_model.dart';
import 'login_screen.dart';

class CourseAttendanceScreen extends StatefulWidget {
  const CourseAttendanceScreen({super.key});

  @override
  State<CourseAttendanceScreen> createState() => _CourseAttendanceScreenState();
}

class _CourseAttendanceScreenState extends State<CourseAttendanceScreen> {
  bool _isLoading = true;
  List<LectureModel> _lectureList = [];
  List<UserModel> _courseUsers = [];
  Map<String, List<bool>> _userAttendance = {};
  List<int> _totalUserLecture = [];

  final ScrollController _verticalScrollController = ScrollController();
  final ScrollController _horizontalScrollController = ScrollController();

  final TextEditingController _searchController = TextEditingController();

  final String _maxRequestSize = '&pageSize=20';

  Future<void> _readStudentWhoAttendedEachLecture() async {
    for (int i = 0; i < _lectureList.length; i++) {
      var mainResponse = await http.get(
        Uri.parse(
          'https://timegapws.com/content-manager/collection-types/api::aaa-doctor.aaa-doctor'
          '?filters[\$and][0][isDoctor][\$eq]=false'
          '&filters[\$and][1][aaa_courses][coursename][\$eq]=${selectedCourse.name}'
          '&filters[\$and][2][aaa_lectures][id][\$eq]=${_lectureList[i].lectureId}'
          // '&filters[\$and][2][aaa_lectures][lecturename][\$eq]=${lectureList[i].lectureName}'
          '&sort=id:ASC'
          '$_maxRequestSize',
        ),
        headers: {HttpHeaders.authorizationHeader: token},
      );
      var responseJson = convert.jsonDecode(mainResponse.body);

      print('Response json body is $responseJson');

      if ((responseJson['results'] != null) &&
          ((responseJson['results'] as List).isNotEmpty)) {
        List<UserModel> attendedStudent = [];
        for (var course in (responseJson['results'] as List)) {
          attendedStudent = [
            ..._courseUsers,
            UserModel.fromJson(course),
          ];
          if (_userAttendance[attendedStudent.last.userIdentification]?[i] !=
              null) {
            _userAttendance[attendedStudent.last.userIdentification]![i] = true;
            _totalUserLecture[i] = _totalUserLecture[i] + 1;
          } else {
            _userAttendance[attendedStudent.last.userIdentification]![i] =
                false;
          }
        }
      }
    }
  }

  Future<void> _readAllStudentRegisteredCourse() async {
    var mainResponse = await http.get(
      Uri.parse(
        'https://timegapws.com/content-manager/collection-types/api::aaa-doctor.aaa-doctor'
        '?filters[\$and][0][isDoctor][\$eq]=false'
        '&filters[\$and][1][aaa_courses][coursename][\$eq]=${selectedCourse.name}'
        // '&sort=id:asc'
        '&sort=username:ASC'
        '&pageSize=20',
      ),
      headers: {HttpHeaders.authorizationHeader: token},
    );
    var responseJson = convert.jsonDecode(mainResponse.body);

    print('Response json body is $responseJson');

    if ((responseJson['results'] != null) &&
        ((responseJson['results'] as List).isNotEmpty)) {
      for (var course in (responseJson['results'] as List)) {
        _courseUsers = [
          ..._courseUsers,
          UserModel.fromJson(course),
        ];
        _userAttendance = {
          ..._userAttendance,
          _courseUsers.last.userIdentification:
              List.generate(_lectureList.length, (index) => false),
        };
      }
      _totalUserLecture = List.generate(_lectureList.length, (index) => 0);
    }
  }

  Future<void> _readCourseLectures() async {
    http.get(
      Uri.parse(
        'https://timegapws.com/content-manager/collection-types/api::aaa-lecture.aaa-lecture'
        '?filters[\$and][0][aaa_course][coursename][\$eq]=${selectedCourse.name}'
        '&filters[\$and][1][aaa_users][username][\$eq]=${userData.userName}'
        '&sort=id:ASC'
        '$_maxRequestSize',
      ),
      headers: {HttpHeaders.authorizationHeader: token},
    ).then(
      (res) async {
        var responseJson = convert.jsonDecode(res.body);

        print('Response json body is $responseJson');

        if ((responseJson['results'] != null) &&
            ((responseJson['results'] as List).isNotEmpty)) {
          for (var lecture in (responseJson['results'] as List)) {
            _lectureList = [
              ..._lectureList,
              LectureModel.fromJson(lecture),
            ];
          }

          await _readAllStudentRegisteredCourse();
          await _readStudentWhoAttendedEachLecture();
        }

        setState(
          () {
            _isLoading = false;
          },
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _readCourseLectures();
  }

  void _sortSearchedStudent(String inputData) {
    Map<String, List<bool>> tmpMap = {};

    var tmpUsers = _courseUsers
        .where(
          (element) =>
              (element.userName.contains(inputData)) ||
              (element.userIdentification.contains(inputData)),
        )
        .toList();
    tmpMap = {
      for (int i = 0; i < tmpUsers.length; i++)
        // tmpUsers[i].userName: userAttendance[tmpUsers[i].userName] ??
        tmpUsers[i].userIdentification:
            _userAttendance[tmpUsers[i].userIdentification] ??
                List.generate(_lectureList.length, (index) => false),
    };

    for (var user in tmpMap.keys) {
      _userAttendance.remove(user);
    }
    _userAttendance = {
      ...tmpMap,
      ..._userAttendance,
    };

    print('Temp Map Length ${tmpMap.length}');
    print('Temp User attendance length ${_userAttendance.length}');
  }

  Widget _attendanceTable() {
    return Scrollbar(
      controller: _horizontalScrollController,
      thumbVisibility: true,
      trackVisibility: true,
      child: Scrollbar(
        controller: _verticalScrollController,
        thumbVisibility: true,
        trackVisibility: true,
        child: SingleChildScrollView(
          controller: _verticalScrollController,
          scrollDirection: Axis.vertical,
          child: SingleChildScrollView(
            controller: _horizontalScrollController,
            scrollDirection: Axis.horizontal,
            child: Table(
              border: TableBorder.all(
                color: Colors.black,
                width: 2,
              ),
              defaultColumnWidth: const FixedColumnWidth(150),
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              children: [
                // * Header Row
                TableRow(
                  decoration: const BoxDecoration(
                    color: Colors.grey,
                  ),
                  children: [
                    const SizedBox(
                      height: 50,
                      width: 50,
                      child: Center(
                        child: Text(
                          '#',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 50,
                      width: 50,
                      child: Center(
                        child: Text(
                          'ID',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 50,
                      width: 50,
                      child: Center(
                        child: Text(
                          'Student Name',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    for (var lectureName in _lectureList)
                      Tooltip(
                        message: lectureName.lectureDate,
                        child: SizedBox(
                          height: 50,
                          width: 50,
                          child: Center(
                            child: Text(
                              lectureName.lectureName,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(
                      height: 50,
                      width: 50,
                      child: Center(
                        child: Text(
                          'Total',
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

                // * Table Data.
                for (int i = 0; i < _userAttendance.length; i++)
                  TableRow(
                    children: [
                      ...[
                        SizedBox(
                          height: 50,
                          width: 50,
                          child: Center(
                            child: Text(
                              '${i + 1}',
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
                          width: 50,
                          child: Center(
                            child: Text(
                              _courseUsers
                                  .firstWhere((element) =>
                                      element.userIdentification ==
                                      (_userAttendance.keys.toList())[i])
                                  .userIdentification,
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
                          width: 50,
                          child: Center(
                            child: Text(
                              _courseUsers
                                  .firstWhere((element) =>
                                      element.userIdentification ==
                                      (_userAttendance.keys.toList())[i])
                                  .userName,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        for (int j = 0;
                            j <
                                (_userAttendance[(_userAttendance.keys
                                            .toList())[i]] ??
                                        [])
                                    // (userAttendance[courseUsers[i].userName] ?? [])
                                    .length;
                            j++)
                          Tooltip(
                            message: _courseUsers
                                .firstWhere((element) =>
                                    element.userIdentification ==
                                    (_userAttendance.keys.toList())[i])
                                .userName,
                            child: SizedBox(
                              height: 50,
                              width: 50,
                              child: Center(
                                child: (_userAttendance[(_userAttendance.keys
                                            .toList())[i]])?[j] ??
                                        false
                                    ? const Icon(
                                        Icons.check_box,
                                        color: Colors.black,
                                        size: 25,
                                      )
                                    : Container(),
                              ),
                            ),
                          ),
                        SizedBox(
                          height: 50,
                          width: 50,
                          child: Center(
                            child: Text(
                              '${_userAttendance[(_userAttendance.keys.toList())[i]]?.where((element) => element == true).length ?? 0} / ${_lectureList.length}',
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
                    ],
                  ),

                // * Table Footer.
                TableRow(
                  decoration: const BoxDecoration(
                    color: Colors.grey,
                  ),
                  children: [
                    const SizedBox(
                      // height: 50,
                      height: 0,
                      width: 50,
                      child: Center(
                        child: Text(
                          '',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      // height: 50,
                      height: 0,
                      width: 50,
                      child: Center(
                        child: Text(
                          '',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 50,
                      width: 50,
                      child: Center(
                        child: Text(
                          'Student/Lecture',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    for (int i = 0; i < _lectureList.length; i++)
                      SizedBox(
                        height: 50,
                        width: 50,
                        child: Center(
                          child: Text(
                            '${_totalUserLecture[i]} / ${_courseUsers.length}',
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(
                      // height: 50,
                      height: 0,
                      width: 50,
                      child: Center(
                        child: Text(
                          '',
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            'Attendance ${selectedCourse.name.replaceRange(0, 1, selectedCourse.name[0].toUpperCase())}'),
        titleTextStyle: const TextStyle(
          // color: Colors.black,
          fontSize: 24,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
        backgroundColor: Colors.lightBlueAccent[700],
        foregroundColor: Colors.white,
        shadowColor: Colors.redAccent,
        elevation: 5,
        actions: [
          InkWell(
            onTap: () {
              Navigator.of(context)
                ..popUntil(
                  (route) => route.isFirst,
                )
                ..pushReplacement(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
            },
            child: SvgPicture.asset(
              'assets/icons/logout_icon.svg',
              color: Colors.black,
              width: 24,
              height: 24,
            ),
          ),
          const SizedBox(width: 30),
        ],
      ),
      body: !_isLoading
          ? Container(
              height: MediaQuery.sizeOf(context).height,
              width: MediaQuery.sizeOf(context).width,
              color: const Color(0xffF5F5F5),
              alignment: Alignment.topCenter,
              child: _lectureList.isNotEmpty
                  ? Column(
                      children: [
                        const SizedBox(height: 30),
                        TextField(
                          controller: _searchController,
                          style: const TextStyle(
                            color: Colors.black,
                            // color: Colors.blueGrey,
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Carme',
                          ),
                          onEditingComplete: FocusScope.of(context).nextFocus,
                          canRequestFocus: true,
                          // cursorColor: Colors.white,
                          cursorColor: Colors.blueGrey,
                          onSubmitted: (_) async {
                            print('Search icon is Pressed');
                            var s = _searchController.text.trim();
                            if (s.length > 2) {
                              _isLoading = true;
                              _sortSearchedStudent(s);
                              await Future.delayed(
                                const Duration(milliseconds: 800),
                              );
                            } else {}
                            //setState
                            setState(() {
                              _isLoading = false;
                            });
                          },
                          decoration: InputDecoration(
                            constraints: BoxConstraints(
                              maxWidth: MediaQuery.sizeOf(context).width - 30,
                              minWidth: MediaQuery.sizeOf(context).width - 30,
                            ),
                            labelText: 'Search',
                            hintText: 'Student Name',
                            contentPadding:
                                const EdgeInsets.symmetric(horizontal: 25),
                            labelStyle: const TextStyle(
                              color: Colors.black,
                              fontSize: 20,
                              fontWeight: FontWeight.w400,
                              fontFamily: 'Carme',
                            ),
                            hintStyle: const TextStyle(
                              // color: Colors.deepPurpleAccent,
                              // color: Colors.blueGrey,
                              color: Colors.grey,
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Carme',
                            ),
                            border: const OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(5),
                              ),
                              borderSide: BorderSide(
                                width: 1,
                                color: Colors.white,
                              ),
                            ),
                            focusedBorder: const OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(5),
                              ),
                              borderSide: BorderSide(
                                width: 2,
                                color: Colors.blue,
                                // color: Colors.deepPurpleAccent,
                              ),
                            ),
                            suffix: InkWell(
                              onTap: () async {
                                print('Search icon is Pressed');
                                var s = _searchController.text.trim();
                                if (s.length > 3) {
                                  _isLoading = true;
                                  _sortSearchedStudent(s);
                                  await Future.delayed(
                                    const Duration(milliseconds: 800),
                                  );
                                } else {}
                                //setState
                                setState(() {
                                  _isLoading = false;
                                });
                              },
                              child: const Icon(
                                Icons.search,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),
                        Expanded(child: _attendanceTable()),
                        // const SizedBox(height: 15),
                      ],
                    )
                  : const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 35),
                        child: Text(
                          'There is no lectures',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 25,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
            )
          : Container(
              height: MediaQuery.sizeOf(context).height,
              width: MediaQuery.sizeOf(context).width,
              color: const Color(0xffF5F5F5),
              child: const Center(
                child: CircularProgressIndicator(
                  color: Colors.black,
                  strokeAlign: 3,
                  strokeWidth: 25,
                  // strokeAlign: 50,
                ),
              ),
            ),
    );
  }
}
