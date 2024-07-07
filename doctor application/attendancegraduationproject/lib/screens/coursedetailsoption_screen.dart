import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../data/universal_data.dart';

import './login_screen.dart';
import './courseattendance_screen.dart';
import './manualattendance_screen.dart';
import './qr_screen.dart';

class CourseDetailsOptionScreen extends StatefulWidget {
  const CourseDetailsOptionScreen({super.key});

  @override
  State<CourseDetailsOptionScreen> createState() =>
      _CourseDetailsOptionScreenState();
}

class _CourseDetailsOptionScreenState extends State<CourseDetailsOptionScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Options'),
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
              // Get.off(() => const LoginScreen());
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
      body: Container(
        height: MediaQuery.sizeOf(context).height,
        width: MediaQuery.sizeOf(context).width,
        color: const Color(0xffF5F5F5),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 35),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 75),
              Text.rich(
                TextSpan(
                  text: 'Course',
                  children: [
                    const TextSpan(text: '  '),
                    TextSpan(
                      text: selectedCourse.name.replaceRange(
                          0, 1, selectedCourse.name[0].toUpperCase()),
                      style: TextStyle(
                        // color: Colors.black,
                        color: Colors.lightBlueAccent[700],
                        fontSize: 28,
                        fontWeight: FontWeight.w600,
                        // decoration: TextDecoration.underline,
                        // decorationStyle: TextDecorationStyle.double,
                        decorationThickness: 2,
                        decorationColor: Colors.blue,
                        // letterSpacing: 2.5,
                        fontFamily: 'Carme',
                      ),
                    ),
                  ],
                ),
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 25,
                  fontWeight: FontWeight.w300,
                  fontFamily: 'Cairo',
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
                        builder: (context) => const QrScreen(),
                      ),
                    );
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
                        'Course QR-Code',
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
                    // selectedCourse = coursesList[index];
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const ManualAttendanceScreen(),
                      ),
                    );
                  },
                  // child: const Center(
                  //   child: Text(
                  //     'Mark Attendance Manual',
                  //     textAlign: TextAlign.center,
                  //     style: TextStyle(
                  //       fontSize: 25,
                  //       fontWeight: FontWeight.w500,
                  //       color: Colors.black,
                  //     ),
                  //   ),
                  // ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Icon(
                        Icons.check,
                        color: Colors.black,
                        size: 30,
                      ),
                      Text(
                        'Mark Attendance Manual',
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
                // padding: const EdgeInsets.symmetric(vertical: 15),
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
                        builder: (context) => const CourseAttendanceScreen(),
                      ),
                    );
                  },
                  // child: const Center(
                  //   child: Text(
                  //     'Course Attendance',
                  //     style: TextStyle(
                  //       fontSize: 25,
                  //       fontWeight: FontWeight.w500,
                  //       color: Colors.black,
                  //     ),
                  //   ),
                  // ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      SvgPicture.asset(
                        'assets/icons/person-combination-svgrepo-com.svg',
                        width: 50,
                        height: 50,
                        color: Colors.black,
                      ),
                      const Text(
                        'View Attendance ',
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
            ],
          ),
        ),
      ),
    );
  }
}
