import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:note_sharing_app/Hive/logged_in.dart';
import 'package:note_sharing_app/Hive/token/token.dart';
import 'package:note_sharing_app/Screens/Bottom%20Navigation/bottom_navigation_bar.dart';
import 'package:note_sharing_app/Screens/Home/home.dart';
import 'package:note_sharing_app/Services/login_service.dart';
import 'package:note_sharing_app/Services/upload_service.dart';
import 'package:note_sharing_app/main.dart';
import 'package:note_sharing_app/shared.dart';
import 'package:provider/provider.dart';
import '../../Hive/user_profile.dart';
import '../../constants.dart';

class CreateProfileScreen extends StatefulWidget {
  final bool isNew;
  final UserDataHive userData;
  const CreateProfileScreen(
      {super.key, required this.userData, required this.isNew});

  @override
  State<CreateProfileScreen> createState() => _CreateProfileScreenState();
}

class _CreateProfileScreenState extends State<CreateProfileScreen> {
  TextEditingController collegeController = TextEditingController();
  TextEditingController courseController = TextEditingController();
  TextEditingController yearController = TextEditingController();
  TextEditingController descController = TextEditingController();
  String? collegeId;
  String? profilePicUrl;
  GlobalKey<FormState> _createProfileScreen = GlobalKey<FormState>();
  int? gender;
  bool isButtonPressed = false;
  UserProfileDataHive? profileData = box.get(userProfileKey);
  TokenModel? token;
  XFile? imageFile;

  @override
  void initState() {
    super.initState();
    log("init state");
    token = box.get(tokenHiveKey);
    if (profileData != null) {
      courseController.text = profileData!.course!;
      collegeController.text = profileData!.university!;
      yearController.text = profileData!.year!.toString();
      descController.text = profileData!.description!;
      gender = profileData!.gender == 'Male'
          ? 1
          : profileData!.gender == 'Female'
              ? 2
              : 3;
      profilePicUrl = profileData!.profile_image!;
      collegeId = profileData!.collegeID;
    }
  }

  @override
  Widget build(BuildContext context) {
    log("---------------" + profilePicUrl.toString());

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: const ArrowBackButton(
          iconColor: primaryColor1,
        ),
        title: Text(
          widget.isNew ? "Create Profile" : "Update Profile ",
          style: GoogleFonts.poppins(
            fontSize: 16,
            color: textColorBlack,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Consumer<LoginService>(
          builder: (context, LoginService loginService, _) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Form(
            key: _createProfileScreen,
            child: SingleChildScrollView(
              child: Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    SizedBox(
                      height: height10 * 3,
                    ),
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        SizedBox(
                          height: Get.height * 0.125,
                          width: Get.height * 0.125,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: imageFile != null
                                ? Image.file(
                                    File(imageFile!.path),
                                    height: Get.height * 0.125,
                                    width: Get.height * 0.125,
                                    fit: BoxFit.cover,
                                  )
                                : profilePicUrl != null
                                    ? Image.network(
                                        'https://note-sharing-application.onrender.com$profilePicUrl')
                                    : Image.asset(
                                        // File(profile!.path),
                                        "assets/images/anjali.png",
                                        height: Get.height * 0.125,
                                        width: Get.height * 0.125,
                                        fit: BoxFit.cover,
                                        filterQuality: FilterQuality.high,
                                      ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(4),
                          child: Container(
                              height: 32,
                              width: 32,
                              decoration: BoxDecoration(
                                color: primaryColor1,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: IconButton(
                                onPressed: () async {
                                  var a = await UploadFileService().pickImage();
                                  if (a != null) {
                                    setState(() {
                                      imageFile = a;
                                    });
                                  }
                                },
                                icon: const Icon(
                                  Icons.edit,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              )),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: height10 * 3,
                    ),
                    MyTextFormField(
                      controller: collegeController,
                      hintText: "University/College",
                    ),
                    SizedBox(
                      height: height10,
                    ),
                    MyTextFormField(
                      controller: courseController,
                      hintText: "Course",
                    ),
                    SizedBox(
                      height: height10,
                    ),
                    MyTextFormField(
                      controller: yearController,
                      hintText: "Year",
                    ),
                    SizedBox(
                      height: height10,
                    ),
                    MyTextFormField(
                      controller: descController,
                      hintText: "Description",
                    ),
                    SizedBox(
                      height: height10 / 2,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: DropdownButtonFormField(
                          value: gender,
                          validator: (value) {
                            if (value == null) {
                              return "Required";
                            }
                          },
                          hint: const Text("Select Gender"),
                          items: const [
                            DropdownMenuItem(
                              value: 1,
                              child: Text("Male"),
                            ),
                            DropdownMenuItem(
                              value: 2,
                              child: Text("Female"),
                            ),
                            DropdownMenuItem(
                              value: 3,
                              child: Text("Other"),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() {
                              gender = value as int;
                            });
                          }),
                    ),
                    SizedBox(
                      height: height10 * 3,
                    ),
                    CustomElevatedButton(
                        onPressed: isButtonPressed
                            ? () {}
                            : () {
                                if (_createProfileScreen.currentState!
                                    .validate()) {
                                  FocusScope.of(context).unfocus();

                                  setState(() {
                                    isButtonPressed = true;
                                    log("button status changed to true");
                                  });
                                  // if (profile == null) {
                                  //   Fluttertoast.showToast(
                                  //       msg: "please upload image");
                                  // } else {
                                  if (widget.isNew == false) {
                                    log("update screen for profile details");
                                    loginService.updateProfileDetails2(
                                        course: courseController.text,
                                        usertoken: token!.accessToken,
                                        desc: descController.text,
                                        university: collegeController.text,
                                        userId: widget.userData.id.toString(),
                                        profileImage: File(imageFile!.path),
                                        year: (yearController.text),
                                        gender: gender == 1
                                            ? "Male"
                                            : gender == 2
                                                ? "Female"
                                                : "Other");
                                    profileData = loginService.userProfile;
                                    if (profileData != null &&
                                        widget.isNew == true) {
                                      setState(() {
                                        isButtonPressed = false;
                                      });
                                      log("-------" + profileData.toString());
                                      Get.offAll(CustomBottomNavBar());
                                    } else {
                                      setState(() {
                                        isButtonPressed = false;
                                      });
                                    }
                                  } else {
                                    loginService.createProfile(
                                        course: courseController.text,
                                        usertoken: token!.accessToken,
                                        desc: descController.text,
                                        university: collegeController.text,
                                        userId: widget.userData.id.toString(),
                                        // profileImage: File(profile!.path),
                                        year: (yearController.text),
                                        gender: gender == 1
                                            ? "Male"
                                            : gender == 2
                                                ? "Female"
                                                : "Other");
                                    profileData = loginService.userProfile;
                                    if (profileData != null &&
                                        widget.isNew == true) {
                                      setState(() {
                                        isButtonPressed = false;
                                      });
                                      log("-------" + profileData.toString());
                                      Get.offAll(Home(
                                          // userData: loginService.userData!,
                                          // userProfileData: profileData,
                                          ));
                                    } else {
                                      setState(() {
                                        isButtonPressed = false;
                                      });
                                    }
                                  }

                                  // }
                                }
                              },
                        child: isButtonPressed
                            ? const Center(
                                child: CircularProgressIndicator.adaptive(
                                  valueColor:
                                      AlwaysStoppedAnimation(Colors.white),
                                ),
                              )
                            : Text(widget.isNew ? "Create" : "Update",
                                style: GoogleFonts.poppins(
                                  textStyle: const TextStyle(fontSize: 16),
                                )))
                  ],
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
