import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:note_sharing_app/Hive/logged_in.dart';
import 'package:note_sharing_app/Services/upload_service.dart';
import 'package:note_sharing_app/constants.dart';
import 'package:note_sharing_app/shared.dart';
import 'package:provider/provider.dart';

import '../../Hive/token/token.dart';
import '../../main.dart';

class UploadPost extends StatefulWidget {
  final File file;
  const UploadPost({super.key, required this.file});

  @override
  State<UploadPost> createState() => _UploadPostState();
}

class _UploadPostState extends State<UploadPost> {
  bool isbuttonPressed = false;
  UserDataHive userData = box.get(userDataKey);
  GlobalKey<FormState> uploadFormState = GlobalKey<FormState>();
  TextEditingController titleController = TextEditingController();
  TokenModel tokens = box.get(tokenHiveKey);
  late File imageFile;
  @override
  void initState() {
    super.initState();
    imageFile = widget.file;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          leading: ArrowBackButton(
            iconColor: primaryColor1,
          ),
          title: Text(
            "Upload Post",
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: textColorBlack,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        body: Form(
          key: uploadFormState,
          child: Container(
            margin: EdgeInsets.all(24),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  MyTextFormField(
                    requiredValidator: true,
                    controller: titleController,
                    hintText: "Enter description ",
                  ),
                  SizedBox(
                    height: height10 * 3,
                  ),
                  Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: Colors.grey, width: 2)),
                        height: Get.height * 0.45,
                        width: Get.width,
                        clipBehavior: Clip.hardEdge,
                        child: Image.file(
                          imageFile,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        bottom: 5,
                        right: 5,
                        child: Container(
                            height: 40,
                            width: 40,
                            decoration: BoxDecoration(
                              color: primaryColor1,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: IconButton(
                              onPressed: () async {
                                XFile? file =
                                    await UploadFileService().pickImage();
                                if (file != null) {
                                  setState(() {
                                    imageFile = File(file.path);
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
                    height: height10 * 4,
                  ),
                  CustomElevatedButton(
                      child: isbuttonPressed
                          ? Center(
                              child: CircularProgressIndicator.adaptive(
                              valueColor: AlwaysStoppedAnimation(
                                Colors.white,
                              ),
                            ))
                          : Text(
                              "Upload",
                              style: GoogleFonts.poppins(),
                            ),
                      onPressed: isbuttonPressed
                          ? () {}
                          : () async {
                              if (uploadFormState.currentState!.validate()) {
                                setState(() {
                                  isbuttonPressed = true;
                                });
                                log("button pressed");
                                var isUpload =
                                    await Provider.of<UploadFileService>(
                                            context,
                                            listen: false)
                                        .uploadPost(
                                            userToken: tokens.accessToken!,
                                            image: widget.file,
                                            post_content: titleController.text,
                                            post_author: userData.id!);
                                if (isUpload == false)
                                  setState(() {
                                    isbuttonPressed = false;
                                  });
                              }
                            })
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
