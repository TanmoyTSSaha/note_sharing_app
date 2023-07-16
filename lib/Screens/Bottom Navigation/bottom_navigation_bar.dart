import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:note_sharing_app/Screens/Chat/chat.dart';
import 'package:note_sharing_app/Screens/Home/home.dart';
import 'package:note_sharing_app/Screens/Home/post_r.dart';
import 'package:note_sharing_app/Screens/Home/posts_screen.dart';
import 'package:note_sharing_app/Services/login_service.dart';
import 'package:note_sharing_app/constants.dart';
import 'package:provider/provider.dart';

import '../../Hive/logged_in.dart';
import '../../Hive/token/token.dart';
import '../../Hive/user_profile.dart';
import '../../Services/upload_service.dart';
import '../../main.dart';
import '../Explore/explore.dart';
import '../Profile/profile_screen.dart';
import '../QnA Forum/qna_forum.dart';
import '../upload/upload_post.dart';

class CustomBottomNavBar extends StatefulWidget {
  const CustomBottomNavBar({super.key});

  @override
  State<CustomBottomNavBar> createState() => _CustomBottomNavBarState();
}

class _CustomBottomNavBarState extends State<CustomBottomNavBar> {
  int bottomNavIndex = 0;
  UserProfileDataHive? profileData;
  UserDataHive? userData;
  TokenModel? tokens;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Box>(
        valueListenable: box.listenable(),
        builder: (context, boxdetails, _) {
          profileData = box.get(userProfileKey);
          userData = box.get(userDataKey);
          tokens = box.get(tokenHiveKey);
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              leading: GestureDetector(
                onTap: () {
                  Get.to(() => ProfileScreen(
                        userData: userData!,
                      ));
                },
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  backgroundImage: profileData!.gender == 'Female'
                      ? AssetImage('assets/images/girl_avatar.png')
                      : AssetImage('assets/images/boy_av.png'),
                ),
              ),
              leadingWidth: 80,
              titleSpacing: 0,
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Text(
                    "Hi ${userData!.first_name} ",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: textColorBlack,
                    ),
                  ),
                  // const SizedBox(height: 2.5),
                  Text(
                    "Welcome back!",
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: textColorBlack.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
              actions: [
                IconButton(
                  onPressed: () {
                    // Provider.of<UploadFileService>(context, listen: false)
                    //     .getUploadedPostsOfUser(
                    //         userData!.id!, tokens!.accessToken!);
                  },
                  splashRadius: 24,
                  splashColor: primaryColor3,
                  icon: const Icon(
                    CupertinoIcons.bell_fill,
                    color: primaryColor1,
                    size: 24,
                  ),
                ),
              ],
            ),
            body: IndexedStack(
              index: bottomNavIndex,
              children: [
                PostsPage2(),
                const Home(),
                const QnA_Forum(),
                const QnA_Forum(),
              ],
            ),
            bottomNavigationBar: Container(
              height: Get.height * 0.08,
              width: Get.width * 0.9,
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  width: 1,
                  color: primaryColor3,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  InkWell(
                    onTap: () {
                      setState(() {
                        bottomNavIndex = 0;
                      });
                    },
                    child: SizedBox(
                      width: Get.width * 0.2,
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Icon(
                            Icons.home,
                            size: 28,
                            color: bottomNavIndex == 0
                                ? primaryColor1
                                : primaryColor3,
                          ),
                          Text(
                            "Home",
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: bottomNavIndex == 0
                                  ? primaryColor1
                                  : primaryColor3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      setState(() {
                        bottomNavIndex = 1;
                      });
                    },
                    child: SizedBox(
                      width: Get.width * 0.2,
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Icon(
                            Icons.grid_view_rounded,
                            size: 28,
                            color: bottomNavIndex == 1
                                ? primaryColor1
                                : primaryColor3,
                          ),
                          Text(
                            "Explore",
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: bottomNavIndex == 1
                                  ? primaryColor1
                                  : primaryColor3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () async {
                      XFile? file = await UploadFileService().pickImage();
                      if (file != null) {
                        Get.to(UploadPost(
                          file: File(file.path),
                        ));
                      }
                      // setState(() {
                      //   bottomNavIndex = 2;
                      // });
                    },
                    child: SizedBox(
                      width: Get.width * 0.2,
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Icon(
                            Icons.add_box,
                            size: 28,
                            color: bottomNavIndex == 2
                                ? primaryColor1
                                : primaryColor3,
                          ),
                          Text(
                            "Upload",
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: bottomNavIndex == 2
                                  ? primaryColor1
                                  : primaryColor3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      setState(() {
                        bottomNavIndex = 3;
                      });
                    },
                    child: SizedBox(
                      width: Get.width * 0.2,
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Icon(
                            Icons.chat_rounded,
                            size: 28,
                            color: bottomNavIndex == 3
                                ? primaryColor1
                                : primaryColor3,
                          ),
                          Text(
                            "QNA Forum",
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: bottomNavIndex == 3
                                  ? primaryColor1
                                  : primaryColor3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }
}
