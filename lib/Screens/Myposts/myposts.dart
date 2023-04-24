import 'dart:developer';
import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:note_sharing_app/Hive/logged_in.dart';
import 'package:note_sharing_app/Services/upload_service.dart';
import 'package:note_sharing_app/main.dart';
import 'package:note_sharing_app/models/posts_model.dart';
import 'package:note_sharing_app/shared.dart';
import 'package:provider/provider.dart';

import '../../Hive/token/token.dart';
import '../../constants.dart';

class MyUploadedPosts extends StatefulWidget {
  const MyUploadedPosts({super.key});

  @override
  State<MyUploadedPosts> createState() => _MyUploadedPostsState();
}

class _MyUploadedPostsState extends State<MyUploadedPosts> {
  late Future<List<PostModel?>> myPosts;
  UserDataHive userdata = box.get(userDataKey);
  TokenModel token = box.get(tokenHiveKey);
  assignValue() async {
    myPosts = Provider.of<UploadFileService>(context, listen: false)
        .getUploadedPostsOfUser(userdata.id!, token.accessToken!);
  }

  @override
  void initState() {
    super.initState();
    assignValue();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: const ArrowBackButton(
          iconColor: primaryColor1,
        ),
        title: Text(
          "My Uploaded Posts ",
          style: GoogleFonts.poppins(
            fontSize: 16,
            color: textColorBlack,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
          child: Container(
              margin: EdgeInsets.all(16),
              height: Get.height - 80,
              width: Get.width,
              child: FutureBuilder(
                initialData: null,
                future: myPosts,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator.adaptive(),
                    );
                  }
                  log("------" + snapshot.data.toString());
                  if (snapshot.data!.isEmpty)
                    return Center(
                      child: Text("No posts Uploaded yet"),
                    );
                  return ListView.separated(
                      itemBuilder: (context, index) {
                        return Post(post: snapshot.data![index]);

                        // return Text(snapshot.data![index].toString());
                      },
                      separatorBuilder: (context, index) {
                        return SizedBox(
                          height: 4,
                        );
                      },
                      itemCount: snapshot.data!.length);
                },
              ))),
    );
  }
}

class Post extends StatelessWidget {
  final UserDataHive userdata = box.get(userDataKey);

  final PostModel? post;
  Post({
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
                    "${userdata.first_name} ${userdata.last_name}",
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
            post!.post_content!,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: textColorBlack,
            ),
          ),
          const SizedBox(height: 16),
          post!.post_image != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(post!.post_image!),
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
                        "0 likes",
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
