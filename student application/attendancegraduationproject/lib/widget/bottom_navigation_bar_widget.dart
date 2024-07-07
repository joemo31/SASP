import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../screens/login_screen.dart';
import '../screens/setting_screen.dart';

class CustomBottomNavigationBarWidget extends StatelessWidget {
  const CustomBottomNavigationBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.sizeOf(context).width,
      height: 80,
      // color: Colors.blue,
      // color: Colors.blue[900],
      color: Colors.lightBlueAccent[700],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          InkWell(
            onTap: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.home,
                  color: Colors.black,
                  // color: Colors.white,
                  size: 25,
                ),
                Text(
                  'Home',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    color: Colors.black,
                    // color: Color.fromRGBO(144, 164, 174, 1),
                  ),
                ),
              ],
            ),
          ),
          InkWell(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const SettingScreen()),
              );
            },
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.settings,
                  color: Colors.black,
                  // color: Colors.white,
                  size: 25,
                ),
                Text(
                  'Setting',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    color: Colors.black,
                    // color: Color.fromRGBO(144, 164, 174, 1),
                  ),
                ),
              ],
            ),
          ),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                SvgPicture.asset(
                  'assets/icons/logout_icon.svg',
                  color: Colors.black,
                  width: 24,
                  height: 24,
                ),
                // Icon(
                //   Icons.login_outlined,
                //   color: Color.fromRGBO(229, 115, 115, 1),
                //   size: 25,
                // ),
                const Text(
                  'Logout',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    // color: Colors.blue[200],
                    color: Colors.black,
                    // color: Color.fromRGBO(144, 164, 174, 1),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
