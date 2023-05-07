import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

import '../../Hive/token/token.dart';
import '../../constants.dart';
import '../../main.dart';
import '../../models/qna_model.dart';
import '../../shared.dart';

class QnA_Forum extends StatefulWidget {
  const QnA_Forum({super.key});

  @override
  State<QnA_Forum> createState() => _QnA_ForumState();
}

class _QnA_ForumState extends State<QnA_Forum> {
  late Future<QnaModel?> qnaModel;
  TokenModel userToken = box.get(tokenHiveKey);
  Future<QnaModel?> getQnAPosts() async {
    try {
      http.Response qnaPosts = await http.get(
        Uri.parse("https://note-sharing-application.onrender.com/qna/"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer ${userToken.accessToken}"
        },
      );
      if (qnaPosts.statusCode == 200 && qnaPosts.body.isNotEmpty) {
        Map<String, dynamic> qnaPostsMap =
            jsonDecode(qnaPosts.body) as Map<String, dynamic>;
        var a = QnaModel.fromJson(qnaPostsMap);
        return a;
      } else {
        log("Empty data QnA Posts");
      }
    } catch (e) {
      log('QnA Posts Exception : $e');
    }
    return null;
  }

  assignQna() {
    qnaModel = getQnAPosts();
  }

  @override
  void initState() {
    assignQna();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Container(
          width: Get.width,
          padding: const EdgeInsets.all(16),
          child: qnaModel != null
              ? FutureBuilder(
                  initialData: null,
                  future: qnaModel,
                  builder: (context, AsyncSnapshot<QnaModel?> qnaSnapshot) {
                    if (qnaSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }
                    return ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: qnaSnapshot.data!.data!.length,
                      itemBuilder: (context, index) {
                        return QnaPost(
                          qnaData: qnaSnapshot.data!.data![index],
                          user_id: qnaSnapshot.data!.data![index].user!,
                          index: index,
                          userAccessToken: userToken.accessToken!,
                        );
                      },
                      separatorBuilder: (context, index) => Container(
                        height: 6,
                        width: Get.width,
                        decoration: BoxDecoration(
                          color: primaryColor3.withOpacity(0.25),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    );
                  })
              : Center(
                  child: CircularProgressIndicator.adaptive(
                    valueColor: AlwaysStoppedAnimation(primaryColor1),
                  ),
                ),
        ),
      ),
    );
  }
}

class QnaPost extends StatefulWidget {
  QnaData qnaData;
  String userAccessToken;
  int user_id;
  int index;
  QnaPost({
    super.key,
    required this.qnaData,
    required this.user_id,
    required this.index,
    required this.userAccessToken,
  });

  @override
  State<QnaPost> createState() => _QnaPostState();
}

class _QnaPostState extends State<QnaPost> {
  int likeCount = 0;
  bool liked = false;
  Map<String, dynamic>? userDetails;
  Map<String, dynamic>? userProfileData;

  Future postLike() async {
    http.Response likePostResponse = await http.post(
      Uri.parse(
          "https://note-sharing-application.onrender.com/post/post=${widget.qnaData.qnaId}/like/"),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${widget.userAccessToken}'
      },
    );
    log('post like : ' + likePostResponse.statusCode.toString());
    return likePostResponse;
  }

  Future deleteLike() async {
    http.Response deleteLikePostResponse = await http.delete(
      Uri.parse(
          "https://note-sharing-application.onrender.com/qna/post=${widget.qnaData.qnaId}/like/"),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${widget.userAccessToken}'
      },
    );
    log('delete like : ' + deleteLikePostResponse.statusCode.toString());
    return deleteLikePostResponse;
  }

  Future getPostLike() async {
    try {
      http.Response like = await http.get(
        Uri.parse(
            "https://note-sharing-application.onrender.com/qna/qna=${widget.qnaData.qnaId}/like"),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${widget.userAccessToken}'
        },
      );
      if (like.statusCode == 200 && like.body.isNotEmpty) {
        Map<String, dynamic> likeMap =
            jsonDecode(like.body) as Map<String, dynamic>;
        setState(
          () {
            likeCount = likeMap['like_count'];
          },
        );
      } else {
        log('Something went wrong. Status code = ${like.statusCode}');
      }
    } catch (e) {
      log(e.toString());
    }
  }

  Future getUserData() async {
    try {
      http.Response userResponse = await http.get(
        Uri.parse(
            "https://note-sharing-application.onrender.com/user/api/user/user=${widget.qnaData.user}"),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${widget.userAccessToken}'
        },
      );
      if (userResponse.statusCode == 200) {
        userDetails = jsonDecode(userResponse.body) as Map<String, dynamic>;
        userDetails = userDetails!['data'];
        log(userDetails.toString());
      } else {
        toastMessage(
            'Something went wrong. Please refresh again! or Login again');
        log('getUserData : ' + userResponse.statusCode.toString());
      }
    } catch (e) {
      toastMessage('Something went wrong. $e');
      log('getUserData : ' + e.toString());
    }
  }

  Future getUserProfileData() async {
    try {
      http.Response userProfileResponse = await http.get(
        Uri.parse(
            "https://note-sharing-application.onrender.com/user/api/profile/user=${widget.qnaData.user}"),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${widget.userAccessToken}'
        },
      );
      if (userProfileResponse.statusCode == 200) {
        userProfileData =
            jsonDecode(userProfileResponse.body) as Map<String, dynamic>;
        userProfileData = userProfileData!['data'];
        log(userProfileData.toString());
      } else {
        toastMessage(
            'Something went wrong. Please refresh again! or Login again');
        log('getUserDat : ' + userProfileResponse.statusCode.toString());
      }
    } catch (e) {
      toastMessage('Something went wrong. $e');
      log('getUserDat : ' + e.toString());
    }
  }

  @override
  void initState() {
    // getPostLike();
    getUserData();
    getUserProfileData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          Row(
            children: [
              userProfileData != null
                  ? CircleAvatar(
                      backgroundColor: Colors.white,
                      foregroundImage: NetworkImage(
                          'https://note-sharing-application.onrender.com${userProfileData!['profile_image']}'),
                      minRadius: 24,
                    )
                  : CircleAvatar(
                      backgroundColor: Colors.grey.shade300,
                      child: CircularProgressIndicator(
                        color: primaryColor1,
                      ),
                    ),
              const SizedBox(width: 16),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  userDetails != null
                      ? Text(
                          "${userDetails!['first_name']} ${userDetails!['last_name']}",
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: textColorBlack,
                          ),
                        )
                      : Text(
                          "Loading...",
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: textColorBlack,
                          ),
                        ),
                  // const SizedBox(height: 4),
                  // Text(
                  //   "2 hours ago",
                  //   style: GoogleFonts.poppins(
                  //     fontSize: 10,
                  //     fontWeight: FontWeight.w600,
                  //     color: primaryColor3,
                  //   ),
                  // ),
                ],
              ),
              const Spacer(),
              IconButton(
                onPressed: () {},
                splashRadius: 24,
                splashColor: primaryColor3,
                icon: const Icon(
                  Icons.more_horiz_outlined,
                  color: primaryColor1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            widget.qnaData.questionTitle!,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: textColorBlack,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            widget.qnaData.questionDescription!,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: textColorBlack,
            ),
          ),
          const SizedBox(height: 12),
          widget.qnaData.questionImage != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                      "https://note-sharing-application.onrender.com${widget.qnaData.questionImage}"),
                )
              : const SizedBox(
                  height: 0,
                  width: 0,
                ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                onTap: () async {
                  setState(() {
                    liked = !liked;
                  });
                  liked ? postLike() : deleteLike();
                  getPostLike();
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: primaryColor3,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.thumb_up,
                        color: primaryColor1,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "$likeCount likes",
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: primaryColor1,
                        ),
                      )
                    ],
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  // setState(() {
                  //   Get.to(
                  //     () => CommentScreen(),
                  //   );
                  // });
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: primaryColor3,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.comment_outlined,
                        color: primaryColor1,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "0 comments",
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: primaryColor1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              IconButton(
                onPressed: () {},
                splashRadius: 24,
                splashColor: primaryColor3,
                icon: const Icon(
                  Icons.add_box_outlined,
                  color: primaryColor1,
                  size: 24,
                ),
              )
            ],
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
    // });
  }
}
