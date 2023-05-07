import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:note_sharing_app/Services/post_services.dart';
import 'package:note_sharing_app/constants.dart';
import 'package:note_sharing_app/models/comment_model.dart';
import 'package:note_sharing_app/shared.dart';

class CommentScreen extends StatefulWidget {
  final int post_id;
  final String userAccessToken;
  final String userRefreshToken;
  const CommentScreen({
    super.key,
    required this.post_id,
    required this.userAccessToken,
    required this.userRefreshToken,
  });

  @override
  State<CommentScreen> createState() => _CommentScreenState();
}

class _CommentScreenState extends State<CommentScreen> {
  TextEditingController commentController = TextEditingController();
  CommentModel? commentModel;

  assignComments() async {
    commentModel = await PostServices().getPostComments(
      userAccessToken: widget.userAccessToken,
      userRefreshToken: widget.userRefreshToken,
      post_id: widget.post_id,
    );
    
  }

  @override
  void initState() {
    super.initState();
    assignComments();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          FocusManager.instance.primaryFocus!.unfocus();
        });
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          leading: ArrowBackButton(iconColor: primaryColor1),
          title: Text(
            "Comments",
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: textColorBlack,
              fontWeight: FontWeight.w600,
            ),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
        ),
        body: Container(
          height: Get.height,
          width: Get.width,
          padding: EdgeInsets.all(16),
          child: commentModel != null
              ? ListView.separated(
                  itemBuilder: (context, index) {
                    return Container(
                      decoration: BoxDecoration(
                        color: primaryColor3,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: EdgeInsets.all(16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Tanmoy Saha',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: primaryColor1,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            commentModel!.commentData![index].commentContent!,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: textColorBlack,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  separatorBuilder: (context, index) {
                    return SizedBox(height: 16);
                  },
                  itemCount: commentModel!.commentData!.length)
              : SizedBox(
                  height: Get.height,
                  width: Get.width,
                  child: Center(
                    child: CircularProgressIndicator(
                      color: primaryColor1,
                    ),
                  ),
                ),
        ),
        bottomNavigationBar: Padding(
          padding: MediaQuery.of(context).viewInsets,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: MyTextFormField(
              controller: commentController,
              hintText: 'Type comment here',
              suffixIcon: IconButton(
                onPressed: () {},
                icon: Icon(
                  Icons.send_rounded,
                  color: primaryColor1,
                  size: 24,
                ),
                splashRadius: 24,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
