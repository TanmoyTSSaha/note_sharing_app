import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:note_sharing_app/models/comment_model.dart';

import '../models/posts_model.dart';
import '../shared.dart';
import 'login_service.dart';

class PostServices extends ChangeNotifier {
  Future<AllPostsModel?> getPosts(
      {required String userToken, required String refreshToken}) async {
    try {
      http.Response response = await http.get(
        Uri.parse("https://note-sharing-application.onrender.com/post/"),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $userToken'
        },
      );
      log("---  " +
          response.body.toString() +
          ' ' +
          response.statusCode.toString());
      Map<String, dynamic> data =
          jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode == 200) {
        Map<String, dynamic> posts =
            jsonDecode(response.body) as Map<String, dynamic>;
        var a = AllPostsModel.fromMap(posts);
        return a;
      } else if (response.statusCode == 401) {
        toastMessage("It's taking a little bit longer time. Please Wait!");
        try {
          LoginService().getAccessToken(refreshToken: refreshToken);
        } finally {
          getPosts(userToken: userToken, refreshToken: refreshToken);
        }
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

  Future<CommentModel?> getPostComments(
      {required String userAccessToken,
      required String userRefreshToken,
      required int post_id}) async {
    try {
      http.Response commentResponse = await http.get(
        Uri.parse(
            "https://note-sharing-application.onrender.com/post/comment/post=$post_id"),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $userAccessToken'
        },
      );

      if (commentResponse.statusCode == 200) {
        Map<String, dynamic> comments =
            jsonDecode(commentResponse.body) as Map<String, dynamic>;
            log(comments.toString());
        return CommentModel.fromJson(jsonDecode(commentResponse.body));
      } else if (commentResponse.statusCode == 401) {
        toastMessage("It's taking a little bit longer time. Please Wait!");
        try {
          LoginService().getAccessToken(refreshToken: userRefreshToken);
        } finally {
          getPosts(userToken: userAccessToken, refreshToken: userRefreshToken);
        }
      } else {
        toastMessage("Failed to load. Please refresh or login again");
        log("getPostComment : status code while getting post is not 200");
      }
    } catch (e) {
      toastMessage("Failed to load. Please refresh or login again $e");
      log("getPostComment : " + e.toString());
    }
    return null;
  }
}
