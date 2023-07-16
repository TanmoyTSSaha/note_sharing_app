import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:note_sharing_app/Hive/token/token.dart';
import 'package:note_sharing_app/Screens/Profile/create_profile.dart';
import 'package:note_sharing_app/Screens/Register/user_login.dart';
import 'package:note_sharing_app/Services/login_service.dart';
import 'package:note_sharing_app/constants.dart';
import 'package:note_sharing_app/main.dart';
import 'package:note_sharing_app/shared.dart';
import 'package:provider/provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  GlobalKey<FormState> _registerFormKey = GlobalKey<FormState>();
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  TextEditingController userNameController = TextEditingController();
  TokenModel? userData;
  bool? userNameAlreadyExist = false;
  bool? useremailAlreadyExist = false;
  bool isButtonPressed = false;
  bool obscureText = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<LoginService>(builder: (context, loginService, _) {
        return Container(
          margin: const EdgeInsets.all(32),
          child: SingleChildScrollView(
            child: Form(
              key: _registerFormKey,
              child: Center(
                child: Column(children: [
                  SizedBox(
                    height: height10 * 3,
                  ),
                  Text("Create an Account",
                      style: GoogleFonts.poppins(
                        textStyle: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 22),
                      )),
                  SizedBox(
                    height: height10 * 0.5,
                  ),
                  Text(
                    "Sign up and start learning",
                    style: GoogleFonts.poppins(),
                  ),
                  SizedBox(
                    height: height10 * 2,
                  ),
                  MyTextFormField(
                    onChanged: (val) {
                      loginService.changeStatusUserNameExist(false);
                    },
                    ownValidator: true,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Required";
                      } else if (userNameAlreadyExist == true) {
                        return "User already exist! Please try new user name";
                      }
                    },
                    keyboardType: TextInputType.text,
                    controller: userNameController,
                    hintText: "User Name",
                  ),
                  SizedBox(
                    height: height10,
                  ),
                  MyTextFormField(
                    controller: firstNameController,
                    hintText: "First Name",
                    maxLength: 50,
                  ),
                  SizedBox(
                    height: height10,
                  ),
                  MyTextFormField(
                    controller: lastNameController,
                    hintText: "Last Name",
                    maxLength: 50,
                  ),
                  SizedBox(
                    height: height10,
                  ),
                  MyTextFormField(
                    ownValidator: true,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Required";
                      } else if (!value.isEmail) {
                        return "Must be Email";
                      } else if (useremailAlreadyExist == true) {
                        return "User with this email already exist";
                      }
                    },
                    onChanged: (val) {
                      loginService.changeStatusEmailExist(false);
                    },
                    emailValidator: true,
                    controller: emailController,
                    hintText: "Email",
                  ),
                  SizedBox(
                    height: height10,
                  ),
                  MyTextFormField(
                    suffixIcon: obscureText
                        ? IconButton(
                            onPressed: () {
                              setState(() {
                                obscureText = false;
                              });
                            },
                            icon: const Icon(
                              Icons.visibility,
                              size: 20,
                            ))
                        : IconButton(
                            onPressed: () {
                              setState(() {
                                obscureText = true;
                              });
                            },
                            icon: const Icon(
                              Icons.visibility_off,
                              size: 20,
                              // color: primaryColor2,
                            )),
                    obscureText: obscureText,
                    maxlines: 1,
                    maxLength: 25,
                    ownValidator: true,
                    validator: ((value) {
                      if (value!.isEmpty) {
                        return "Required";
                      } else if (value.length < 8) {
                        return "Must be at least 8 character";
                      }
                    }),
                    controller: passwordController,
                    hintText: "Password",
                  ),
                  SizedBox(
                    height: height10,
                  ),
                  MyTextFormField(
                    maxLength: 25,
                    ownValidator: true,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Required";
                      } else if (value != passwordController.text) {
                        return "Password not matched";
                      }
                    },
                    maxlines: 1,
                    obscureText: true,
                    controller: confirmPasswordController,
                    hintText: "Confirm password",
                  ),
                  SizedBox(
                    height: height10 * 3,
                  ),
                  CustomElevatedButton(
                      onPressed: isButtonPressed
                          ? null
                          : () async {
                              if (_registerFormKey.currentState!.validate()) {
                                setState(() {
                                  isButtonPressed = true;
                                });
                                FocusScope.of(context)
                                    .requestFocus(new FocusNode());
                                await loginService.registerUser(
                                    firstName: firstNameController.text,
                                    lastName: lastNameController.text,
                                    email: emailController.text,
                                    password: passwordController.text,
                                    userName: userNameController.text);
                                userData = loginService.userResponseToken;
                                toastMessage('User Registered successfully');
                                log("userdata---- $userData");
                                userNameAlreadyExist =
                                    loginService.isUserAlreadyExist;
                                useremailAlreadyExist =
                                    loginService.isuserEmailAlreadyExist;
                                if (userData != null) {
                                  loginService.getUserData();
                                  log("user data is not null");
                                  Get.offAll(CreateProfileScreen(
                                      userData: box.get(userDataKey),
                                      isNew: true));
                                }
                                if (loginService.userResponseToken != null) {
                                  setState(() {
                                    isButtonPressed = false;
                                    Get.offAll(CreateProfileScreen(
                                      isNew: true,
                                      userData: loginService.userData!,
                                    ));
                                  });
                                  log(userData.toString());
                                } else {
                                  log("user response is null....");
                                  Fluttertoast.showToast(
                                      msg: "User Already Exist");
                                  setState(() {
                                    isButtonPressed = false;
                                  });
                                }
                              }
                            },
                      child: isButtonPressed
                          ? const Center(
                              child: CircularProgressIndicator.adaptive(
                                  valueColor:
                                      AlwaysStoppedAnimation(Colors.white)),
                            )
                          : const Text("Register")),
                  SizedBox(
                    height: height10 * 0.5,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Already have an account?"),
                      TextButton(
                          onPressed: () {
                            Get.offAll(const UserLoginPage());
                          },
                          child: Text(
                            "Login",
                            style: TextStyle(color: primaryColor1),
                          ))
                    ],
                  )
                ]),
              ),
            ),
          ),
        );
      }),
    );
  }
}
