import 'package:flutter/material.dart';

import '../data/universal_data.dart';

import '../widget/bottom_navigation_bar_widget.dart';

import './changepassword_screen.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Setting'),
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
      body: Container(
        height: MediaQuery.sizeOf(context).height,
        width: MediaQuery.sizeOf(context).width,
        // color: const Color(0xffFC804B),
        // color: Colors.blueGrey[900],
        color: const Color(0xffF5F5F5),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 35),
          child: Column(
            children: [
              const SizedBox(height: 50),
              // CircleAvatar(
              //   //backgroundColor: Colors.black,
              //   backgroundColor: Colors.white,
              //   radius: 50,
              //   child: Center(
              //     child: Icon(
              //       Icons.person_outline_rounded,
              //       size: 50,
              //       //color: Colors.white,
              //       color: Colors.black,
              //       // color: Colors.indigo[900],
              //     ),
              //   ),
              // ),
              Container(
                //backgroundColor: Colors.black,
                height: 100,
                width: 100,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 2,
                      offset: Offset(-2, 0),
                      color: Colors.black.withOpacity(0.21),
                    ),
                    BoxShadow(
                      blurRadius: 4,
                      offset: Offset(2, 0),
                      color: Colors.black.withOpacity(0.21),
                    ),
                    BoxShadow(
                      blurRadius: 4,
                      offset: Offset(0, -2),
                      color: Colors.black.withOpacity(0.21),
                    ),
                    BoxShadow(
                      blurRadius: 4,
                      offset: Offset(0, 2),
                      color: Colors.black.withOpacity(0.8),
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    Icons.person_outline_rounded,
                    size: 50,
                    //color: Colors.white,
                    color: Colors.black,
                    // color: Colors.indigo[900],
                  ),
                ),
              ),
              const SizedBox(height: 50),
              SizedBox(
                width: MediaQuery.sizeOf(context).width,
                height: 50,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      'Name:',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Carme',
                        color: Colors.black,
                        fontSize: 25,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Container(
                        decoration: const BoxDecoration(
                          //color: Colors.black,
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black,
                              offset: Offset(0, 2),
                              blurRadius: 2,
                            ),
                          ],
                          borderRadius: BorderRadius.all(
                            Radius.circular(25),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            userData.userName,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              //color: Colors.white,
                              color: Colors.black,
                              fontFamily: 'Carme',
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              height: 1,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 50),

              SizedBox(
                width: MediaQuery.sizeOf(context).width,
                height: 50,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: const Text(
                        'ID:',
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontFamily: 'Carme',
                          color: Colors.black,
                          fontSize: 25,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      flex: 3,
                      child: Container(
                        decoration: const BoxDecoration(
                          //color: Colors.black,
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black,
                              offset: Offset(0, 2),
                              blurRadius: 2,
                            ),
                          ],
                          borderRadius: BorderRadius.all(
                            Radius.circular(25),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            userData.useridentification,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              //color: Colors.white,
                              color: Colors.black,
                              fontFamily: 'Carme',
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              height: 1,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 50),

              Container(
                height: 50,
                width: MediaQuery.sizeOf(context).width,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(25)),
                  //color: Colors.black,
                  //color: Colors.lightBlueAccent[400],
                  color: Colors.red[900],

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
                        builder: (context) => const ChangePasswordScreen(),
                      ),
                    );
                  },
                  child: const Center(
                    child: Text(
                      'Change Password',
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
      ),
    );
  }
}
