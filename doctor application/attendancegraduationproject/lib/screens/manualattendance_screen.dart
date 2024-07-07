import 'dart:io';
import 'dart:convert' as convert;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;

import '../data/universal_data.dart';

import '../models/attendance_model.dart';

import '../models/lecture_data_model.dart';
import '../models/user_model.dart';
import 'login_screen.dart';

class ManualAttendanceScreen extends StatefulWidget {
  const ManualAttendanceScreen({super.key});

  @override
  State<ManualAttendanceScreen> createState() => _ManualAttendanceScreenState();
}

class _ManualAttendanceScreenState extends State<ManualAttendanceScreen> {
  bool isSearching = false;
  String text = '';
  bool isLoading = true;
  List<LectureModel> lectureList = [];
  List<UserModel> courseUsers = [];
  Map<String, List<bool>> userAttendance = {};
  Map<String, List<bool>> previousUserAttendance = {};

  bool isEdit = false;

  final ScrollController _verticalScrollController = ScrollController();
  final ScrollController _horizontalScrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  String maxRequestSize = '&pageSize=12';

  Future<void> _postEditedData() async {
    for (int i = 0; i < courseUsers.length; i++) {
      List<int> lecturesIdList = [];
      String userName = courseUsers[i].userIdentification;

      print(
        'https://timegapws.com/content-manager/collection-types/api::aaa-lecture.aaa-lecture'
        '?filters[\$and][0][aaa_users][useridentification][\$eq]=${userData.userIdentification}'
        '&filters[\$and][0][aaa_course][id][\$ne]=${selectedCourse.id}'
        '&sort=id:ASC'
        '&pageSize=100',
      );

      // * Read All courses except current course attend.
      var mainResponse = await http.get(
        Uri.parse(
          'https://timegapws.com/content-manager/collection-types/api::aaa-lecture.aaa-lecture'
          '?filters[\$and][0][aaa_users][useridentification][\$eq]=${courseUsers[i].userIdentification}'
          '&filters[\$and][0][aaa_course][id][\$ne]=${selectedCourse.id}'
          '&sort=id:ASC'
          '&pageSize=100',
        ),
        headers: {HttpHeaders.authorizationHeader: token},
      );
      var responseJson = convert.jsonDecode(mainResponse.body);

      print(
          'User ${userData.userIdentification} Response json body is $responseJson');

      if ((responseJson['results'] != null) &&
          ((responseJson['results'] as List).isNotEmpty)) {
        for (var lectureTmp in (responseJson['results'] as List)) {
          lecturesIdList = [
            ...lecturesIdList,
            LectureDataModel.fromJson(lectureTmp).id,
          ];
        }
      }

      for (int j = 0; j < lectureList.length; j++) {
        (userAttendance[userName]?[j]) ?? false
            ? lecturesIdList = [
                ...lecturesIdList,
                lectureList[j].lectureId,
              ]
            : null;
      }
      final String body =
          convert.jsonEncode({"aaa_lectures": lecturesIdList.toList()});
      await http.put(
        Uri.parse(
          'https://timegapws.com/content-manager/collection-types/api::aaa-doctor.aaa-doctor/${courseUsers[i].id}',
        ),
        body: body,
        headers: {
          HttpHeaders.authorizationHeader: token,
          HttpHeaders.acceptHeader: 'application/json',
          HttpHeaders.contentTypeHeader: 'application/json',
        },
      );
    }
  }

  Future<void> _readStudentWhoAttendedEachLecture() async {
    for (int i = 0; i < lectureList.length; i++) {
      var mainResponse = await http.get(
        Uri.parse(
          'https://timegapws.com/content-manager/collection-types/api::aaa-doctor.aaa-doctor'
          '?filters[\$and][0][isDoctor][\$eq]=false'
          '&filters[\$and][1][aaa_courses][coursename][\$eq]=${selectedCourse.name}'
          '&filters[\$and][2][aaa_lectures][id][\$eq]=${lectureList[i].lectureId}'
          // '&filters[\$and][2][aaa_lectures][lecturename][\$eq]=${lectureList[i].lectureName}'
          '&sort=id:ASC'
          '$maxRequestSize',
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
            ...courseUsers,
            UserModel.fromJson(course),
          ];
          userAttendance[attendedStudent.last.userIdentification]?[i] != null
              ? userAttendance[attendedStudent.last.userIdentification]![i] =
                  true
              : userAttendance[attendedStudent.last.userIdentification]![i] =
                  false;
        }
      }
    }
    previousUserAttendance.addAll(userAttendance);
  }

  Future<void> _readAllStudentRegisteredCourse() async {
    var mainResponse = await http.get(
      Uri.parse(
        'https://timegapws.com/content-manager/collection-types/api::aaa-doctor.aaa-doctor'
        '?filters[\$and][0][isDoctor][\$eq]=false'
        '&filters[\$and][1][aaa_courses][coursename][\$eq]=${selectedCourse.name}'
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
        courseUsers = [
          ...courseUsers,
          UserModel.fromJson(course),
        ];
        userAttendance = {
          ...userAttendance,
          courseUsers.last.userIdentification:
              List.generate(lectureList.length, (index) => false),
        };
      }
    }
  }

  Future<void> _readCourseLectures() async {
    isSearching = false;
    text = '';
    isLoading = true;
    lectureList = [];
    courseUsers = [];
    userAttendance = {};
    previousUserAttendance = {};
    isEdit = false;
    http.get(
      Uri.parse(
        'https://timegapws.com/content-manager/collection-types/api::aaa-lecture.aaa-lecture'
        '?filters[\$and][0][aaa_course][coursename][\$eq]=${selectedCourse.name}'
        '&filters[\$and][1][aaa_users][username][\$eq]=${userData.userName}'
        '&sort=id:ASC'
        '$maxRequestSize',
      ),
      headers: {HttpHeaders.authorizationHeader: token},
    ).then(
      (res) async {
        var responseJson = convert.jsonDecode(res.body);

        print('Response json body is $responseJson');

        if ((responseJson['results'] != null) &&
            ((responseJson['results'] as List).isNotEmpty)) {
          for (var course in (responseJson['results'] as List)) {
            lectureList = [
              ...lectureList,
              LectureModel.fromJson(course),
            ];
          }

          await _readAllStudentRegisteredCourse();
          await _readStudentWhoAttendedEachLecture();
        }

        setState(
          () {
            isLoading = false;
          },
        );
      },
    );
  }

  void _sortSearchedStudent(String inputData) {
    Map<String, List<bool>> tmpMap = {};

    var tmpUsers = courseUsers
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
            userAttendance[tmpUsers[i].userIdentification] ??
                List.generate(lectureList.length, (index) => false),
    };

    for (var user in tmpMap.keys) {
      userAttendance.remove(user);
    }
    userAttendance = {
      ...tmpMap,
      ...userAttendance,
    };

    print('Temp Map Length ${tmpMap.length}');
    print('Temp User attendance length ${userAttendance.length}');
  }

  @override
  void initState() {
    super.initState();
    _readCourseLectures();
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
            padding: const EdgeInsets.symmetric(horizontal: 15),
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
                    for (var lectureName in lectureList)
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
                  ],
                ),

                // * Table Data.
                for (int i = 0; i < userAttendance.length; i++)
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
                              courseUsers
                                  .firstWhere((element) =>
                                      element.userIdentification ==
                                      (userAttendance.keys.toList())[i])
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
                              courseUsers
                                  .firstWhere((element) =>
                                      element.userIdentification ==
                                      (userAttendance.keys.toList())[i])
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
                                (userAttendance[(userAttendance.keys
                                            .toList())[i]] ??
                                        [])
                                    // (userAttendance[courseUsers[i].userName] ?? [])
                                    .length;
                            j++)
                          Tooltip(
                            message: courseUsers
                                .firstWhere((element) =>
                                    element.userIdentification ==
                                    (userAttendance.keys.toList())[i])
                                .userName,
                            child: SizedBox(
                              height: 50,
                              width: 50,
                              child: InkWell(
                                onTap: isEdit
                                    ? () {
                                        setState(
                                          () => userAttendance[(userAttendance
                                                  .keys
                                                  .toList())[i]]?[j] =
                                              !userAttendance[(userAttendance
                                                  .keys
                                                  .toList())[i]]![j],
                                          // () => userAttendance[courseUsers[i].userName]
                                          //         ?[j] =
                                          //     !userAttendance[courseUsers[i].userName]![
                                          //         j],
                                        );
                                      }
                                    : null,
                                child: Center(
                                  child: (userAttendance[(userAttendance.keys
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
                          ),
                      ],
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
            'Manual Attendance ${selectedCourse.name.replaceRange(0, 1, selectedCourse.name[0].toUpperCase())}'),
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
      body: !isLoading
          ? Container(
              height: MediaQuery.sizeOf(context).height,
              width: MediaQuery.sizeOf(context).width,
              color: const Color(0xffF5F5F5),
              child: lectureList.isNotEmpty
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
                              isLoading = true;
                              _sortSearchedStudent(s);
                              await Future.delayed(
                                const Duration(milliseconds: 800),
                              );
                            } else {}
                            //setState
                            setState(() {
                              isLoading = false;
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
                                  isLoading = true;
                                  _sortSearchedStudent(s);
                                  await Future.delayed(
                                    const Duration(milliseconds: 800),
                                  );
                                } else {}
                                //setState
                                setState(() {
                                  isLoading = false;
                                });
                              },
                              child: const Icon(
                                Icons.search,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 25),
                        isEdit
                            ? Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    height: 50,
                                    width: 150,
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(25)),
                                      border: Border.symmetric(
                                        vertical: BorderSide(
                                          width: 2,
                                          color: Colors.red,
                                        ),
                                        horizontal: BorderSide(
                                          width: 2,
                                          color: Colors.red,
                                        ),
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          blurRadius: 4,
                                          offset: Offset(-5, 4),
                                          color:
                                              Color.fromARGB(164, 244, 67, 54),
                                        ),
                                      ],
                                    ),
                                    margin: const EdgeInsets.symmetric(
                                      vertical: 15,
                                      horizontal: 15,
                                    ),
                                    // padding:  EdgeInsets.symmetric(
                                    //   vertical: 15,
                                    //   horizontal: 15,
                                    // ),
                                    child: InkWell(
                                      onTap: () async {
                                        _readCourseLectures();
                                        // userAttendance.clear();
                                        // userAttendance = {
                                        //   ...previousUserAttendance
                                        // };
                                        setState(
                                          () {
                                            isEdit = false;
                                          },
                                        );
                                      },
                                      child: const Center(
                                        child: Text(
                                          'Cancel',
                                          style: TextStyle(
                                            // color: Colors.deepPurpleAccent,
                                            color: Colors.black,
                                            fontSize: 20,
                                            fontWeight: FontWeight.w600,
                                            fontFamily: 'Cairo',
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    height: 50,
                                    width: 150,
                                    decoration: const BoxDecoration(
                                      color: Colors.green,
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(25)),
                                      boxShadow: [
                                        BoxShadow(
                                          blurRadius: 4,
                                          offset: Offset(5, 4),
                                          color: Colors.black,
                                        ),
                                      ],
                                    ),
                                    margin: const EdgeInsets.only(right: 30),
                                    child: InkWell(
                                      onTap: () async {
                                        await _postEditedData();
                                        setState(() => isEdit = false);
                                      },
                                      child: const Center(
                                        child: Text(
                                          'Change',
                                          style: TextStyle(
                                            // color: Colors.deepPurpleAccent,
                                            color: Colors.white,
                                            fontSize: 20,
                                            fontWeight: FontWeight.w600,
                                            fontFamily: 'Cairo',
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : Container(
                                // height: 50,
                                // width: 200,
                                height: 100,
                                width: MediaQuery.sizeOf(context).width * 0.60,
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(25)),
                                  // color: Colors.black,
                                  // color: Colors.lightBlueAccent[400],
                                  color: Colors.lightBlueAccent[700],
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.black,
                                      offset: Offset(0, 2),
                                      blurRadius: 2,
                                    ),
                                  ],
                                ),

                                child: InkWell(
                                  focusColor:
                                      const Color.fromARGB(106, 255, 255, 255),
                                  onTap: () {
                                    setState(() => isEdit = true);
                                  },
                                  child: const Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      Icon(
                                        Icons.edit,
                                        size: 30,
                                      ),
                                      Center(
                                        child: Text(
                                          'Edit Attendance',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 20,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                        const SizedBox(height: 25),
                        Expanded(child: _attendanceTable()),
                        const SizedBox(height: 25),
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


/*
https://timegapws.com/content-manager/collection-types/api::aaa-lecture.aaa-lecture
?filters[$and][0][aaa_course][coursename][$eq]=${selectedCourse.name}
&filters[$and][1][aaa_users][useridentification][$eq]=2024005
&sort=id:ASC
&pageSize=12
*/