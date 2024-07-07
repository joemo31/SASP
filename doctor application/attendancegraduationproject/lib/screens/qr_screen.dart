import 'dart:io';
import 'dart:convert' as convert;

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:barcode_widget/barcode_widget.dart';
import 'package:intl/intl.dart';

import '../models/lecture_data_model.dart';
import '../models/qr_data_model.dart';

import '../data/universal_data.dart';

class QrScreen extends StatefulWidget {
  const QrScreen({super.key});

  @override
  State<QrScreen> createState() => _QrScreenState();
}

class _QrScreenState extends State<QrScreen> {
  bool _isLoading = true;

  String _data = '';
  final int qrCodeEndTimeSeconds = 60;

  @override
  void initState() {
    final String currentDateFormat =
        DateFormat('dd/MM/yyyy').format(DateTime.now());
    final String currentTimeFormat =
        DateFormat('hh:mm:ss a').format(DateTime.now());
    print('Current Date formate is $currentDateFormat');
    print('Current Time formate is $currentTimeFormat');

    super.initState();

    print('Request lectures is ${(
      'https://timegapws.com/content-manager/collection-types/api::aaa-lecture.aaa-lecture'
          '?filters[\$and][0][aaa_course][courseid][\$eq]=${selectedCourse.courseId}'
          '&filters[\$and][1][aaa_users][username][\$eq]=${userData.userName}'
          '&sort=id:DESC'
          '&pageSize:12',
    )}');

    http.get(
      Uri.parse(
        /*
          'https://timegapws.com/content-manager/collection-types/api::aaa-lecture.aaa-lecture'
          '?filters[\$and][0][aaa_course][courseid][\$eq]=database100'
          '&filters[\$and][1][aaa_users][username][\$eq]=dr mohamed'
          '&sort=id:DESC'
          '&pageSize=12'
        */
        'https://timegapws.com/content-manager/collection-types/api::aaa-lecture.aaa-lecture'
        '?filters[\$and][0][aaa_course][courseid][\$eq]=${selectedCourse.courseId}'
        '&filters[\$and][1][aaa_users][username][\$eq]=${userData.userName}'
        '&sort=id:DESC'
        '&pageSize=12',
      ),
      headers: {HttpHeaders.authorizationHeader: token},
    ).then(
      (res) async {
        late LectureDataModel currentLectureData;
        LectureDataModel lastLectureData = LectureDataModel.fromJson({});
        var responseJson = convert.jsonDecode(res.body);
        bool isAtSameMomentAs = false;
        int totalLectureLength = 0;

        print('Response json body is $responseJson');

        bool containCurrentData = false;
        if ((responseJson['results'] != null) &&
            ((responseJson['results'] as List).isNotEmpty)) {
          totalLectureLength = (responseJson['results'] as List).length;
          lastLectureData = LectureDataModel.fromJson(
              (responseJson['results'] as List).first);
          print(
              'Read lecture length is ${(responseJson['results'] as List).length}');
          print('Date from model ${lastLectureData.toString()}');
          print('Date from model ${lastLectureData.lectureDate}');
          DateTime lastLecture =
              DateFormat("dd/MM/yyyy").parse(lastLectureData.lectureDate);
          DateTime currentDate = DateTime.now();

          print('Lecture Date in String is ${lastLectureData.lectureDate}');
          print('Last lecture date is $lastLecture');

          print(
              'Compare result for date is ${lastLecture.isAtSameMomentAs(DateTime.now())}');
          // isAtSameMomentAs = lastLecture.isAtSameMomentAs(DateTime.now());
          isAtSameMomentAs = (lastLecture.day == currentDate.day) &&
              (lastLecture.month == currentDate.month) &&
              (lastLecture.year == currentDate.year);

          print('isAtSameMomentAs $isAtSameMomentAs');
          print(
            '''The compare is 
Last lecture Date day:${lastLecture.day} Current Data is  ${currentDate.day}} 
Last lecture Date Month:${lastLecture.month} Current Data is  ${currentDate.month}} 
Last lecture Date Year:${lastLecture.year} Current Data is  ${currentDate.year}}''',
          );
          print(
            '''The compare is 
${lastLecture.day == currentDate.day} 
${lastLecture.month == currentDate.month} 
${lastLecture.year == currentDate.year}''',
          );
        }

        if (isAtSameMomentAs) {
          // currentLectureData = lectureData.last;
          currentLectureData = lastLectureData;

          print('$currentLectureData');
        } else {
          final res = await http.post(
            Uri.parse(
              'https://timegapws.com/content-manager/collection-types/api::aaa-lecture.aaa-lecture',
            ),
            headers: {HttpHeaders.authorizationHeader: token},
            body: {
              "lecturename": "lec${totalLectureLength + 1}",
              "date": currentDateFormat,
              "aaa_course": selectedCourse.id.toString(),
              "aaa_users": userData.id.toString(),
            },
          );
          var responseJson = convert.jsonDecode(res.body);

          print('Response json body from post data is $responseJson');

          currentLectureData = LectureDataModel.fromJson(responseJson);
        }

        Future.delayed(Duration(seconds: qrCodeEndTimeSeconds)).then(
          (_) {
            print('Timer has been finished');
            showDialog(
              context: context,
              useSafeArea: true,
              barrierDismissible: false,
              builder: (context) => Container(
                margin: EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: MediaQuery.sizeOf(context).height * 0.2,
                ),
                color: Colors.blue.shade900,
                child: Material(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      const CircleAvatar(
                        backgroundColor: Colors.black,
                        radius: 25,
                        child: Icon(
                          Icons.info_outlined,
                          color: Colors.white,
                        ),
                      ),
                      const Text(
                        'QR code has been expired',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.of(context)
                            ..pop()
                            ..pop();
                        },
                        child: Container(
                          width: MediaQuery.sizeOf(context).width,
                          margin: const EdgeInsets.symmetric(horizontal: 30),
                          decoration: const BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.all(Radius.circular(25)),
                          ),
                          // color: Colors.black,
                          child: const Center(
                            child: Text(
                              'Ok',
                              style: TextStyle(
                                fontSize: 25,
                                fontWeight: FontWeight.w400,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );

        final DateTime expiredTime =
            DateTime.now().add(Duration(seconds: qrCodeEndTimeSeconds));

        QrDataModel qrData = QrDataModel(
          lectureId: currentLectureData.id,
          doctorName: userData.userName,
          courseId: selectedCourse.id,
          lectureName: currentLectureData.lectureName,
          lectureDate: currentLectureData.lectureDate,
          expiredTime: expiredTime,
          createdTime: currentTimeFormat,
        );
        setState(
          () {
            _isLoading = false;
            _data = qrData.toJson();
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${selectedCourse.name} QR Code'),
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
      body: Container(
        height: MediaQuery.sizeOf(context).height,
        width: MediaQuery.sizeOf(context).width,
        color: const Color(0xffF5F5F5),
        child: Center(
          child: !_isLoading
              ? BarcodeWidget(
                  height: MediaQuery.sizeOf(context).height / 2,
                  width: MediaQuery.sizeOf(context).width / 2,
                  data: _data,
                  // color: Colors.blue.shade900,
                  color: Colors.black,
                  barcode: Barcode.qrCode(),
                )
              : const CircularProgressIndicator(
                  strokeWidth: 50,
                  strokeAlign: 3,
                ),
        ),
      ),
    );
  }
}
