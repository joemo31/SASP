import 'dart:io';
import 'dart:convert' as convert;

import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;

import '../data/universal_data.dart';

import '../widget/bottom_navigation_bar_widget.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  @override
  void initState() {
    super.initState();
  }

  bool _isHiddenNewPassword = true;
  bool _isHiddenConfirmPassword = true;

  final FocusScopeNode _confirmPasswordFocusNode = FocusScopeNode();
  final FocusScopeNode _changeActionFocusNode = FocusScopeNode();

  Future<void> _showErrorSnackBar({
    required String message,
    required bool acceptedMessage,
  }) async {
    await ScaffoldMessenger.of(context)
        .showSnackBar(
          SnackBar(
            duration: const Duration(seconds: 3),
            backgroundColor: acceptedMessage ? Colors.green : Colors.red,
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
        )
        .closed;

    if (acceptedMessage) {
      Navigator.of(context).pop();
    }
  }

  void _changePasswordAction() async {
    String newPasswordEntry = _newPasswordController.text.trim();
    String confirmPasswordEntry = _confirmPasswordController.text.trim();
    if ((newPasswordEntry == confirmPasswordEntry) &&
        newPasswordEntry.isNotEmpty &&
        confirmPasswordEntry.isNotEmpty) {
      var res = await http.put(
        Uri.parse(
          "https://timegapws.com/content-manager/collection-types/api::aaa-doctor.aaa-doctor/${userData.id}",
        ),
        body: {'password': newPasswordEntry},
        headers: {HttpHeaders.authorizationHeader: token},
      );

      var responseJson = convert.jsonDecode(res.body);

      // print('Response json body is $responseJson');

      if ((responseJson != null) && ((responseJson as Map).isNotEmpty)) {
        userData.password = newPasswordEntry;

        _showErrorSnackBar(
          message: 'Updated successfully',
          acceptedMessage: true,
        );
      } else {
        _showErrorSnackBar(
            message: 'Please try to upload password again',
            acceptedMessage: false);
      }
    } else {
      _showErrorSnackBar(
        message: 'Please enter both password correct',
        acceptedMessage: false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Change Password'),
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
      // bottomNavigationBar: const CustomBottomNavigationBarWidget(),
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
              TextField(
                autofocus: true,
                obscuringCharacter: '*',
                obscureText: _isHiddenNewPassword,
                controller: _newPasswordController,
                keyboardType: TextInputType.text,
                onEditingComplete: FocusScope.of(context).nextFocus,
                canRequestFocus: true,
                //cursorColor: Colors.white,
                cursorColor: Colors.black,
                style: const TextStyle(
                  //color: Colors.white,
                  color: Colors.black,
                  // color: Colors.blueGrey,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Carme',
                ),
                decoration: InputDecoration(
                  // hintText: 'New Password',
                  labelText: 'New Password',
                  labelStyle: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.w400,
                    fontFamily: 'Carme',
                  ),
                  hintStyle: const TextStyle(
                    // color: Colors.deepPurpleAccent,
                    color: Colors.blueGrey,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Carme',
                  ),
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(25),
                    ),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(25),
                    ),
                    borderSide: BorderSide(
                      width: 2,
                      color: Colors.blue,
                    ),
                  ),
                  enabled: true,
                  //fillColor: Colors.black,
                  fillColor: Colors.white,
                  filled: true,
                  suffix: InkWell(
                    canRequestFocus: false,
                    onTap: () {
                      setState(() {
                        _isHiddenNewPassword = !_isHiddenNewPassword;
                      });
                    },
                    child: Icon(
                      _isHiddenNewPassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                      // color: Colors.white,
                      color: const Color.fromRGBO(237, 231, 246, 1),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 50),
              TextField(
                autofocus: true,
                focusNode: _confirmPasswordFocusNode,
                obscuringCharacter: '*',
                obscureText: _isHiddenConfirmPassword,
                controller: _confirmPasswordController,
                keyboardType: TextInputType.text,
                onEditingComplete: _changeActionFocusNode.requestFocus,
                canRequestFocus: true,
                //cursorColor: Colors.white,
                cursorColor: Colors.black,
                style: const TextStyle(
                  //color: Colors.white,
                  color: Colors.black,
                  // color: Colors.blueGrey,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Carme',
                ),
                decoration: InputDecoration(
                  // hintText: 'Confirm Password',
                  labelText: 'Confirm Password',
                  labelStyle: const TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.w400,
                    fontFamily: 'Carme',
                  ),
                  hintStyle: const TextStyle(
                    // color: Colors.deepPurpleAccent,
                    color: Colors.blueGrey,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Carme',
                  ),
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(25),
                    ),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(25),
                    ),
                    borderSide: BorderSide(
                      width: 2,
                      color: Colors.blue,
                    ),
                  ),
                  enabled: true,
                  //fillColor: Colors.black,
                  fillColor: Colors.white,
                  filled: true,
                  suffix: InkWell(
                    canRequestFocus: false,
                    onTap: () {
                      setState(() {
                        _isHiddenConfirmPassword = !_isHiddenConfirmPassword;
                      });
                    },
                    child: Icon(
                      _isHiddenNewPassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                      // color: Colors.white,
                      color: const Color.fromRGBO(237, 231, 246, 1),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 100),
              Container(
                height: 50,
                width: MediaQuery.sizeOf(context).width * 0.7,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(25)),
                  // color: Colors.black,
                  // color: Colors.lightBlueAccent[400],
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
                  canRequestFocus: true,
                  focusNode: _changeActionFocusNode,
                  onTap: _changePasswordAction,
                  child: const Center(
                    child: Text(
                      'Confirm',
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
