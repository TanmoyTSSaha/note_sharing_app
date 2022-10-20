import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:note_sharing_app/constants.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  PageController pageController = PageController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        height: Get.height,
        width: Get.width,
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 74,
        ),
        child: PageView.builder(
          controller: pageController,
          itemCount: 3,
          itemBuilder: (context, pageIndex) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  height: Get.width * 0.9,
                  width: Get.width * 0.9,
                  child: SvgPicture.asset(
                    onboardingImages[pageIndex],
                    fit: BoxFit.contain,
                  ),
                ),
                SizedBox(
                  height: 5,
                  width: 60,
                  child: ListView.separated(
                    itemCount: 3,
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, listIndex) {
                      return Container(
                        height: 5,
                        width: pageIndex == listIndex ? 20 : 5,
                        decoration: BoxDecoration(
                          color: pageIndex == listIndex
                              ? primaryColor1
                              : primaryColor3,
                          borderRadius: BorderRadius.circular(5),
                        ),
                      );
                    },
                    separatorBuilder: (context, index) => const SizedBox(
                      width: 10,
                      height: 5,
                    ),
                  ),
                ),
                Text(
                  onboardingTitle[pageIndex],
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: textColorBlack,
                  ),
                ),
                Text(
                  onboardingDescription[pageIndex],
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: primaryColor3,
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      pageIndex++;
                      pageController.animateTo(
                        pageIndex.toDouble(),
                        duration: const Duration(milliseconds: 350),
                        curve: Curves.easeIn,
                      );
                      log(pageIndex.toString());
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    maximumSize: Size(Get.width * 0.8, 50),
                    minimumSize: Size(Get.width * 0.8, 50),
                    backgroundColor: primaryColor1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    "Next",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: textColorWhite,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
