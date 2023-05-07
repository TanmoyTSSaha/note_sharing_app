import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:note_sharing_app/Hive/token/token.dart';
import 'package:note_sharing_app/main.dart';
import 'package:note_sharing_app/shared.dart';
import '../../constants.dart';
import '../../models/posts_model.dart';
import 'package:http/http.dart' as http;

class PostsPage extends StatefulWidget {
  const PostsPage({super.key});

  @override
  State<PostsPage> createState() => _PostsPageState();
}

class _PostsPageState extends State<PostsPage> {
  late Future<AllPostsModel?> allPosts;
  late TokenModel a;
  Future<AllPostsModel?> getPosts({required String userToken}) async {
    try {
      http.Response response = await http.get(
        Uri.parse("https://note-sharing-application.onrender.com/post/"),
        headers: {
          'Content-Type': 'application/json',
          "Authorization": 'Bearer $userToken'
        },
      );
      log("---  " + response.body.toString());
      Map<String, dynamic> data =
          jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode == 200) {
        Map<String, dynamic> posts =
            jsonDecode(response.body) as Map<String, dynamic>;
        log(posts.toString());
        var a = AllPostsModel.fromMap(posts);
        return a;
      } else {
        toastMessage("Failed to load");
        log("status code while getting post is not 200");
      }
    } catch (e) {
      toastMessage("Failed to load");
      log("error to get posts---" + e.toString());
      toastMessage(e.toString());
    }
    return null;
  }

  assignValue() async {
    a = box.get(tokenHiveKey);
    allPosts = getPosts(userToken: a.accessToken!);
  }

  @override
  void initState() {
    super.initState();
    assignValue();
    log(allPosts.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: ArrowBackButton(
            iconColor: primaryColor1,
          ),
          leadingWidth: 80,
          titleSpacing: 0,
          title: Text(
            "Posts",
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: textColorBlack,
              fontWeight: FontWeight.w600,
            ),
          ),
          // actions: [
          //   IconButton(
          //     onPressed: () {},
          //     splashRadius: 24,
          //     splashColor: primaryColor3,
          //     icon: const Icon(
          //       CupertinoIcons.bell_fill,
          //       color: primaryColor1,
          //       size: 24,
          //     ),
          //   ),
          // ],
        ),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Container(
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
                          itemBuilder: (context, index) {
                            // return Text(snapshot.data!.data![0].toString());
                            return Posts(post: snapshot.data!.data![0]);
                          },
                          separatorBuilder: (contex, index) {
                            return SizedBox(
                              height: 4,
                            );
                          },
                          itemCount: snapshot.data!.data!.length);
                    },
                  )
                : Center(
                    child: CircularProgressIndicator.adaptive(
                    valueColor: AlwaysStoppedAnimation(primaryColor1),
                  )),
          ),
        ));
  }
}

class Posts extends StatelessWidget {
  PostModel post;
  Posts({
    super.key,
    required this.post,
  });

  @override
  Widget build(BuildContext context) {
    // return Consumer<UploadFileService>(builder: (context, uploadService, _) {
    return SizedBox(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          Row(
            children: [
              const CircleAvatar(
                backgroundColor: Colors.white,
                foregroundImage: AssetImage('assets/images/anjali.png'),
                minRadius: 24,
              ),
              const SizedBox(width: 16),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Anjali Jaiswal",
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: textColorBlack,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "2 hours ago",
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: primaryColor3,
                    ),
                  ),
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
            post.post_content!,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: textColorBlack,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            post.post_content!,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: textColorBlack,
            ),
          ),
          const SizedBox(height: 12),
          post.post_image != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset("assets/images/book.jpg"),
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
                onTap: () {},
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
                        "${post.postLiked??0} likes",
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
                onTap: () {},
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
          Container(
            height: 6,
            width: Get.width,
            decoration: BoxDecoration(
              color: primaryColor3.withOpacity(0.25),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
    // });
  }
}
