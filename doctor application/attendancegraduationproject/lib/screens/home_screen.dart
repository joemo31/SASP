import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../data/universal_data.dart';

import 'login_screen.dart';
import 'coursedetailsoption_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print('courses count is ${coursesList.length}');
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
        // color: Color(0xffFC804B),
        color: const Color(0xffF5F5F5),
        child: coursesList.isNotEmpty
            ? ListView.builder(
                padding: EdgeInsets.symmetric(
                    horizontal: MediaQuery.sizeOf(context).width * 0.15,
                    vertical: 65),
                itemCount: coursesList.length,
                itemBuilder: (gridViewContext, index) => Container(
                  height: 100,
                  width: MediaQuery.sizeOf(context).width,
                  margin: EdgeInsets.only(top: 85),
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
                      selectedCourse = coursesList[index];
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) =>
                              const CourseDetailsOptionScreen(),
                        ),
                      );
                    },
                    child: Center(
                      child: Text(
                        coursesList[index].name,
                        style: const TextStyle(
                          fontSize: 25,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Cairo',
                        ),
                      ),
                    ),
                  ),
                ),
              )
            : const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 35),
                  child: Text(
                    'You haven\'t any courses',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 25,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}
