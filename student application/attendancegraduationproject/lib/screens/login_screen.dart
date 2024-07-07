import 'dart:io';
import 'dart:convert' as convert;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;

import '../models/user_model.dart';

import '../data/universal_data.dart';

import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final FocusScopeNode _emailFocusNode = FocusScopeNode();
  final FocusScopeNode _passwordFocusNode = FocusScopeNode();
  final FocusScopeNode _loginActionFocusNode = FocusScopeNode();

  bool _isHiddenPassword = true;
  bool _isLoading = false;

  void _showErrorSnackBar(String message) {
    FocusScope.of(context).requestFocus(_emailFocusNode);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.sizeOf(context).height,
        width: MediaQuery.sizeOf(context).width,
        color: const Color(0xffF5F5F5),
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 50),
              Container(
                height: 150,
                width: 150,
                // padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(60)),
                  shape: BoxShape.rectangle,
                  // color: Colors.white,
                  color: Colors.lightBlueAccent[400],
                  boxShadow: const [
                    BoxShadow(
                      offset: Offset(0, 5),
                      color: Colors.black,
                      blurRadius: 5,
                    )
                  ],
                ),
                child: Center(
                  child: SvgPicture.asset(
                    'assets/icons/qr_code_action_icon.svg',
                    height: 100,
                    width: 100,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 50),
              const Text(
                "Login",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 25,
                ),
              ),
              const SizedBox(height: 50),

              // * User name field
              TextField(
                autofocus: true,
                focusNode: _emailFocusNode,
                controller: _userNameController,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(
                  //color: Colors.white,
                  color: Colors.black,
                  // color: Colors.blueGrey,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Carme',
                ),
                onEditingComplete: FocusScope.of(context).nextFocus,
                canRequestFocus: true,
                //cursorColor: Colors.white,
                cursorColor: Colors.blueGrey,
                decoration: InputDecoration(
                  //hintText: 'User Name',
                  labelText: 'User Name',
                  labelStyle: TextStyle(
                    //color: Color.fromRGBO(237, 231, 246, 1),
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.w400,
                    fontFamily: 'Carme',
                  ),
                  hintStyle: TextStyle(
                    // color: Colors.deepPurpleAccent,
                    // color: Colors.blueGrey,
                    //color: Colors.grey[50],
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Carme',
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(25),
                    ),
                    borderSide: BorderSide(
                      width: 1,
                      color: Colors.white,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(25),
                    ),
                    borderSide: BorderSide(
                      width: 2,
                      color: Colors.blue,
                      // color: Colors.deepPurpleAccent,
                    ),
                  ),
                  enabled: true,
                  // fillColor: Colors.black,
                  //fillColor: Colors.lightBlueAccent[400],
                  fillColor: Colors.white,
                  filled: true,
                ),
              ),

              // * Password
              const SizedBox(height: 20),
              TextField(
                obscuringCharacter: '*',
                obscureText: _isHiddenPassword,
                focusNode: _passwordFocusNode,
                controller: _passwordController,
                keyboardType: TextInputType.text,
                style: const TextStyle(
                  //color: Colors.white,
                  color: Colors.black,
                  // color: Colors.blueGrey,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Carme',
                ),
                onEditingComplete: () =>
                    FocusScope.of(context).requestFocus(_loginActionFocusNode),
                canRequestFocus: true,
                //cursorColor: Colors.white,
                cursorColor: Colors.black,
                decoration: InputDecoration(
                  //hintText: 'Password',
                  labelText: 'Password',
                  labelStyle: const TextStyle(
                    //color: Color.fromRGBO(237, 231, 246, 1),
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.w400,
                    fontFamily: 'Carme',
                  ),
                  hintStyle: TextStyle(
                    // color: Colors.deepPurpleAccent,
                    //color: Colors.grey[50],
                    color: Colors.black,
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
                      // color: Colors.deepPurpleAccent,
                      color: Colors.blue,
                    ),
                  ),
                  enabled: true,
                  // fillColor: Colors.black,
                  //fillColor: Colors.lightBlueAccent[400],
                  fillColor: Colors.white,
                  filled: true,
                  suffix: InkWell(
                    canRequestFocus: false,
                    onTap: () {
                      setState(() {
                        _isHiddenPassword = !_isHiddenPassword;
                      });
                    },
                    child: Icon(
                      _isHiddenPassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                      // color: Colors.white,
                      color: const Color.fromRGBO(237, 231, 246, 1),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              InkWell(
                focusNode: _loginActionFocusNode,
                focusColor: const Color.fromARGB(106, 255, 255, 255),
                canRequestFocus: true,
                onTap: _isLoading
                    ? null
                    : () async {
                        setState(() {
                          _isLoading = true;
                          _isHiddenPassword = true;
                        });
                        try {
                          String userNameEntry =
                              _userNameController.text.trim();
                          String userPasswordEntry =
                              _passwordController.text.trim();
                          if (userNameEntry.isNotEmpty &&
                              userPasswordEntry.isNotEmpty) {
                            var res = await http.get(
                              Uri.parse(
                                "https://timegapws.com/content-manager/collection-types/api::aaa-doctor.aaa-doctor?filters[username][\$eq]=$userNameEntry&filters[password][\$eq]=$userPasswordEntry&populate=*",
                              ),
                              headers: {HttpHeaders.authorizationHeader: token},
                            );

                            var responseJson = convert.jsonDecode(res.body);

                            print('Response json body is $responseJson');

                            if ((responseJson['results'] != null) &&
                                ((responseJson['results'] as List)
                                    .isNotEmpty)) {
                              userData = UserModel.fromJson(
                                (responseJson['results'] as List).first,
                              );
                              if (!userData.isDoctor) {
                                // Navigator.of(context).pushReplacement(
                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                    builder: (context) => const HomeScreen(),
                                  ),
                                );
                                // Get.off(() => const HomeScreen());
                              } else {
                                _showErrorSnackBar(
                                  'Your Email can\'t login in this application',
                                );
                              }
                            } else {
                              _showErrorSnackBar(
                                'Error during login\nPlease try again',
                              );
                            }
                          } else {
                            _showErrorSnackBar(
                              'Please enter Email field and password field',
                            );
                          }
                        } catch (e) {
                          _showErrorSnackBar(
                            'Please Check your internet connection and try again',
                          );
                        }
                        setState(() {
                          _isLoading = false;
                        });
                      },
                child: Container(
                  height: 50,
                  width: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(25)),
                    // color: Colors.black,
                    // color: Colors.lightBlueAccent[400],
                    color: Colors.lightBlueAccent[700],
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black,
                        offset: Offset(0, 2),
                        blurRadius: 2,
                      ),
                    ],
                  ),
                  child: Center(
                    child: !_isLoading
                        ? const Text(
                            "Login",
                            // style: TextStyle(
                            //   color: Colors.white,
                            // ),
                            style: TextStyle(
                              // color: Colors.deepPurpleAccent,
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Cairo',
                            ),
                          )
                        : const CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
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
