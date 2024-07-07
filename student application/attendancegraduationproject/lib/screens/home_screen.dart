import 'dart:io';
import 'dart:convert' as convert;

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:qr_bar_code_scanner_dialog/qr_bar_code_scanner_dialog.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../data/universal_data.dart';

import '../models/attendance_model.dart';
import '../models/qr_data_model.dart';

import '../widget/bottom_navigation_bar_widget.dart';

import './availablecourses_screen.dart';

// TODO: COMPLETE Attendance request and solve all it's error

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 3),
        backgroundColor: Colors.red,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 25),
        content: SizedBox(
          child: Text(
            message,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  ///
  /// * Method name: Update student data ==> update attendance action.
  /// * Return: Future void.
  /// * Input: Build context and Qr Data model.
  /// ^ Sequence:
  ///   ^ 1. Send request to check Student is not attend to lecture or not:
  ///      ? 1.1. If Student is not Attend:
  ///   ^         2. Read student lectures.
  ///   ^         3. Update lecture id.
  ///
  ///      ? 1.2. If Student is Attended:
  ///           --> Show dialog.
  ///
  Future<void> _updateStudentData(
    BuildContext context,
    QrDataModel qrData,
  ) async {
    // ^ 1. Send request to check Student is not attend to lecture or not.
    var res = await http.get(
      Uri.parse(
        'https://timegapws.com/content-manager/collection-types/api::aaa-lecture.aaa-lecture'
        '?filters[\$and][0][date][\$eq]=${qrData.lectureDate}'
        '&filters[\$and][1][aaa_course][id][\$eq]=${qrData.courseId}'
        '&filters[\$and][2][aaa_users][username][\$eq]=${qrData.doctorName}'
        '&filters[\$and][3][aaa_users][useridentification][\$eq]=${userData.useridentification}'
        '&sort=id:DESC',
      ),
      headers: {HttpHeaders.authorizationHeader: token},
    );
    var responseJson = convert.jsonDecode(res.body);

    // ? If User is not Attend:
    if ((responseJson['results'] as List).isEmpty) {
      print('Response is empty');

      // Read ifg user is registered to the course or not.
      res = await http.get(
        Uri.parse(
          'https://timegapws.com/content-manager/collection-types/api::aaa-lecture.aaa-lecture'
          '?filters[\$and][0][aaa_course][id][\$eq]=${qrData.courseId}'
          '&filters[\$and][1][aaa_users][useridentification][\$eq]=${userData.useridentification}'
          '&sort=id:ASC',
        ),
        headers: {HttpHeaders.authorizationHeader: token},
      );

      responseJson = convert.jsonDecode(res.body);

      print('response is $responseJson');

      // ? If user is registered to the course Do:
      if ((responseJson['results'] as List).isNotEmpty) {
        // ^ 2. Read student lectures.
        res = await http.get(
          Uri.parse(
            'https://timegapws.com/content-manager/collection-types/api::aaa-doctor.aaa-doctor/${userData.id}',
          ),
          headers: {HttpHeaders.authorizationHeader: token},
        );

        responseJson = convert.jsonDecode(res.body);
        if (responseJson != null) {
          List<int> lecturesIdList = [];
          for (var userData in (responseJson['aaa_lectures'] as List)) {
            lecturesIdList = [
              ...lecturesIdList,
              AttendanceModel.fromJson(userData).lectureId,
            ];
          }
          print('Lecture id is ${qrData.lectureId}');
          lecturesIdList = [...lecturesIdList, qrData.lectureId];

          print('Send Lectures id are ${lecturesIdList.toString()}');
          print(
            '''Body which will send is ''' +
                convert.jsonEncode({'aaa_lectures': lecturesIdList.toList()}),
          );
          // final String body = convert.jsonEncode({"aaa_lectures": lecturesIdList});
          final String body =
              convert.jsonEncode({"aaa_lectures": lecturesIdList.toList()});

          // TODO: Check if current data and time is before expired data from recieved qrcode.
          if (DateTime.now().isBefore(qrData.expiredTime)) {
            // ^ 3. Update lecture id.
            res = await http.put(
              Uri.parse(
                'https://timegapws.com/content-manager/collection-types/api::aaa-doctor.aaa-doctor/${userData.id}',
              ),
              body: body,
              headers: {
                HttpHeaders.authorizationHeader: token,
                HttpHeaders.acceptHeader: 'application/json',
                HttpHeaders.contentTypeHeader: 'application/json',
              },
            );
            responseJson = convert.jsonDecode(res.body);
            print('Response body after put is $responseJson');
            showDialog(
              context: context,
              useSafeArea: true,
              builder: (context) {
                return Container(
                  margin: EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: MediaQuery.sizeOf(context).height * 0.2,
                  ),
                  child: const Material(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.black,
                          radius: 25,
                          child: Icon(
                            Icons.check,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Attended Successfully',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          } else {
            showDialog(
              context: context,
              barrierColor: Colors.red,
              builder: (context) {
                return Container(
                  margin: EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: MediaQuery.sizeOf(context).height * 0.2,
                  ),
                  child: const Material(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.red,
                          radius: 25,
                          child: Icon(
                            Icons.close,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          'This QR code is expired, Please Ask Doctor to make you attendance manual',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        } else {
          showDialog(
            context: context,
            barrierColor: Colors.red,
            builder: (context) {
              return Container(
                margin: EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: MediaQuery.sizeOf(context).height * 0.2,
                ),
                child: const Material(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.red,
                        radius: 25,
                        child: Icon(
                          Icons.close,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        'Time is out, You can\'t attend to this lecture',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }
      }

      // ? If user is not registered to the course Do:
      else {
        showDialog(
          context: context,
          barrierColor: Colors.red,
          builder: (context) {
            return Container(
              margin: EdgeInsets.symmetric(
                horizontal: 30,
                vertical: MediaQuery.sizeOf(context).height * 0.2,
              ),
              child: const Material(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.red,
                      radius: 25,
                      child: Icon(
                        Icons.close,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      'You can\'t registered for course\nYou are not registered to this course',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }
    }
  }

  void qrScanner(BuildContext context) {
    final qrBarCodeScannerDialogPlugin = QrBarCodeScannerDialog();

    qrBarCodeScannerDialogPlugin.getScannedQrBarCode(
      //It takes the context of the parent widget to show it correctly.
      context: context,
      onCode: (qrCode) async {
        if (qrCode != null) {
          _updateStudentData(context, QrDataModel.fromJson(qrCode));
        } else {
          _showErrorSnackBar('Please Try again');
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MTI University'),
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
      bottomNavigationBar: const CustomBottomNavigationBarWidget(),
      body: Container(
        height: MediaQuery.sizeOf(context).height,
        width: MediaQuery.sizeOf(context).width,
        color: const Color(0xffF5F5F5),
        // color: Colors.blueGrey[900],
        // color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // const SizedBox(height: 300),
            Container(
              height: 100,
              width: MediaQuery.sizeOf(context).width,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(25)),
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
              child: InkWell(
                borderRadius: BorderRadius.circular(25),
                onTap: () {
                  qrScanner(context);
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    SvgPicture.asset(
                      'assets/icons/qr_code_action_icon.svg',
                      color: Colors.black,
                      width: 30,
                      height: 30,
                    ),
                    const Text(
                      'Scan QR Code',
                      style: TextStyle(
                        fontSize: 25,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Cairo',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 50),
            Container(
              height: 100,
              width: MediaQuery.sizeOf(context).width,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(25)),
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
              child: InkWell(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const AvailableCoursesScreen(),
                    ),
                  );
                },
                child: const Center(
                  child: Text(
                    "View Attendance",
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
          ],
        ),
      ),
    );
  }
}
