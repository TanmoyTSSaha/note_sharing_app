import 'dart:convert';
import 'dart:developer';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:note_sharing_app/Hive/token/token.dart';
import 'package:note_sharing_app/Services/login_service.dart';
import 'package:note_sharing_app/main.dart';
import 'package:note_sharing_app/shared.dart';
import '../../Hive/logged_in.dart';
import '../../Hive/user_profile.dart';
import '../../Services/post_service.dart';
import '../../constants.dart';
import '../../models/comment_model.dart';
import '../../models/posts_model.dart';
import 'package:http/http.dart' as http;

import '../Profile/profile_screen.dart';
import 'comment_screeen.dart';

class PostsPage2 extends StatefulWidget {
  // final UserDataHive? userData;
  // final UserProfileDataHive? userProfileDetail;
  const PostsPage2({
    super.key,
  });

  @override
  State<PostsPage2> createState() => _PostsPage2State();
}

class _PostsPage2State extends State<PostsPage2> {
  late Future<AllPostsModel?> allPosts;
  TokenModel userToken = box.get(tokenHiveKey);
  UserProfileDataHive? profileData;
  UserDataHive? userData;

  assignValue() {
    allPosts = PostServices().getPosts(
      userToken: userToken.accessToken!,
      refreshToken: userToken.refreshToken!,
    );
  }

  @override
  void initState() {
    super.initState();
    assignValue();
    userData = box.get(userDataKey);

    log(allPosts.toString());
  }

  @override
  Widget build(BuildContext context) {
    profileData = box.get(userProfileKey);
    return Scaffold(
      // appBar: AppBar(
      //   backgroundColor: Colors.white,
      //   elevation: 0,
      //   leading: GestureDetector(
      //     onTap: () {
      //       Get.to(() => ProfileScreen(
      //             userData: userData!,
      //             // userProfileData: profileData,
      //           ));
      //     },
      //     child: CircleAvatar(
      //       backgroundColor: Colors.white,
      //       foregroundImage: NetworkImage(
      //           'https://note-sharing-application.onrender.com${profileData!.profile_image}'),
      //     ),
      //   ),
      //   leadingWidth: 80,
      //   titleSpacing: 0,
      //   centerTitle: false,
      //   /*     title: Column(
      //     crossAxisAlignment: CrossAxisAlignment.start,
      //     mainAxisAlignment: MainAxisAlignment.center,
      //     mainAxisSize: MainAxisSize.max,
      //     children: [
      //       widget.userData != null
      //           ? Text(
      //               "Hi ${widget.userData!.first_name} ",
      //               style: GoogleFonts.poppins(
      //                 fontSize: 16,
      //                 fontWeight: FontWeight.w600,
      //                 color: textColorBlack,
      //               ),
      //             )
      //           : TextButton(
      //               onPressed: () => Get.to(() => ProfileScreen(
      //                     userData: widget.userData!,
      //                     // userProfileData: profileData,
      //                   )),
      //               child: Text(
      //                 "Complete your profile",
      //                 style: GoogleFonts.poppins(
      //                   fontSize: 16,
      //                   fontWeight: FontWeight.w600,
      //                   color: textColorBlack,
      //                 ),
      //               )),
      //       // const SizedBox(height: 2.5),
      //       Text(
      //         "Welcome back!",
      //         style: GoogleFonts.poppins(
      //           fontSize: 14,
      //           fontWeight: FontWeight.w400,
      //           color: textColorBlack.withOpacity(0.6),
      //         ),
      //       ),
      //     ],
      //   ),
      // actions: [
      //     IconButton(
      //       onPressed: () {},
      //       splashRadius: 24,
      //       splashColor: primaryColor3,
      //       icon: const Icon(
      //         CupertinoIcons.bell_fill,
      //         color: primaryColor1,
      //         size: 24,
      //       ),
      //     ),
      //   ],*/
      // ),
      body: Container(
        height: Get.height - 80,
        width: Get.width,
        padding: const EdgeInsets.all(16),
        child: allPosts != null
            ? FutureBuilder(
                initialData: null,
                future: allPosts,
                builder: (context, AsyncSnapshot<AllPostsModel?> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  return ListView.separated(
                    shrinkWrap: true,
                    physics: const BouncingScrollPhysics(),
                    itemCount: snapshot.data!.data!.length,
                    itemBuilder: (context, index) {
                      // return Text(snapshot.data!.data.toString());
                      return Posts(
                        post: snapshot.data!.data![index],
                        userAccessToken: userToken.accessToken!,
                        user_id: userData!.id!,
                        userRefreshToken: userToken.refreshToken!,
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
    );
  }
}

class Posts extends StatefulWidget {
  String userAccessToken;
  String userRefreshToken;
  int user_id;
  PostModel post;
  Posts({
    super.key,
    required this.post,
    required this.user_id,
    required this.userAccessToken,
    required this.userRefreshToken,
  });

  @override
  State<Posts> createState() => _PostsState();
}

class _PostsState extends State<Posts> {
  int likeCount = 0;
  bool liked = false;
  Map<String, dynamic>? userDetails;
  Map<String, dynamic>? userProfileData;
  CommentModel? commentModel;

  Future postLike() async {
    http.Response likePostResponse = await http.post(
      Uri.parse(
          "https://note-sharing-application.onrender.com/post/post=${widget.post.post_id}/like/"),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${widget.userAccessToken}'
      },
    );
    log('post like : ' + likePostResponse.statusCode.toString());
    toastMessage('Post Liked');
    return likePostResponse;
  }

  Future deleteLike() async {
    http.Response deleteLikePostResponse = await http.delete(
      Uri.parse(
          "https://note-sharing-application.onrender.com/post/post=${widget.post.post_id}/like/"),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${widget.userAccessToken}'
      },
    );
    log('delete like : ' + deleteLikePostResponse.statusCode.toString());
    toastMessage('Like removed!');
    return deleteLikePostResponse;
  }

  Future getPostLike() async {
    try {
      http.Response like = await http.get(
        Uri.parse(
            "https://note-sharing-application.onrender.com/post/post=${widget.post.post_id}/like"),
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
        toastMessage('Something went wrong. Please refresh or login again');
        log('Something went wrong. Status code = ${like.statusCode}');
      }
    } catch (e) {
      // toastMessage('Something went wrong. ' + e.toString());
      toastMessage('Something went wrong. ');

      log(e.toString());
    }
  }

  Future getUserData() async {
    try {
      http.Response userResponse = await http.get(
        Uri.parse(
            "https://note-sharing-application.onrender.com/user/api/user/user=${widget.post.post_author}"),
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

  Future getUserProfileData(
      {required String userRefreshToken,
      required String userAccessToken}) async {
    try {
      http.Response userProfileResponse = await http.get(
        Uri.parse(
            "https://note-sharing-application.onrender.com/user/api/profile/user=${widget.post.post_author}"),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${userAccessToken}'
        },
      );

      if (userProfileResponse.statusCode == 401) {
        try {
          LoginService().getAccessToken(refreshToken: userRefreshToken);
        } finally {
          getUserProfileData(
            userRefreshToken: userRefreshToken,
            userAccessToken: userAccessToken,
          );
        }
      } else if (userProfileResponse.statusCode == 200) {
        userProfileData =
            jsonDecode(userProfileResponse.body) as Map<String, dynamic>;
        userProfileData = userProfileData!['data'];
        log('getUserProfileData else if : ' + userProfileData.toString());
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
    getPostLike();
    getUserData();
    getUserProfileData(
      userAccessToken: widget.userAccessToken,
      userRefreshToken: widget.userRefreshToken,
    );
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
                  ? userProfileData!['profile_image'] != null
                      ? Container(
                          height: 48,
                          width: 48,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(48),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(48),
                            child: Image.network(
                              'https://note-sharing-application.onrender.com${userProfileData!['profile_image']}',
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: primaryColor3,
                                );
                              },
                            ),
                          ),
                        )
                      : Container(
                          height: 48,
                          width: 48,
                          decoration: BoxDecoration(
                            color: secondaryColor3,
                            borderRadius: BorderRadius.circular(48),
                          ),
                          child: userProfileData!["gender"] == 'Female'
                              ? Image.asset("assets/images/girl_avatar.png")
                              : Image.asset("assets/images/boys_avatar.png"),
                        )
                  : Container(
                      height: 48,
                      width: 48,
                      padding: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(48),
                      ),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: primaryColor1,
                        ),
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
                  const SizedBox(height: 4),
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
            widget.post.post_content!,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: textColorBlack,
            ),
          ),
          const SizedBox(height: 12),
          widget.post.post_image != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    "https://note-sharing-application.onrender.com${widget.post.post_image}",
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: Get.width,
                      height: Get.width,
                      color: Colors.grey.shade300,
                      child: Center(
                        child: Text(
                          'Oops! Something went wrong...',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: textColorBlack,
                          ),
                        ),
                      ),
                    ),
                  ),
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
                  setState(() {
                    Get.to(
                      () => CommentScreen(
                        post_id: widget.post.post_id!,
                        userAccessToken: widget.userAccessToken,
                        userRefreshToken: widget.userRefreshToken,
                      ),
                    );
                  });
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
                        "comments",
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
