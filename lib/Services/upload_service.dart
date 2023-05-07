import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:image_picker/image_picker.dart';
import 'package:note_sharing_app/Screens/Bottom%20Navigation/bottom_navigation_bar.dart';
import 'package:note_sharing_app/Screens/Home/home.dart';
import 'package:note_sharing_app/shared.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import '../models/posts_model.dart';

class UploadFileService extends ChangeNotifier {
  AllPostsModel? allPosts;
  Future<XFile?> pickImage() async {
    final _imagePicker = ImagePicker();
    XFile? image;
    await Permission.photos.request();

    // var permissionStatus = await Permission.photos.status;1
    // if (permissionStatus.isGranted) {
    image = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      return image;
    } else {
      log("No image!!");
      // }
    }
    return null;
  }

  uploadFile(
      {required File file,
      required String userToken,
      required String post_content,
      required int post_author}) async {
    try {
      http.Response response = await http.post(
          Uri.parse("https://note-sharing-application.onrender.com/post/"),
          headers: {
            'Content-Type': 'application/json',
            "Authorization": 'Bearer $userToken',
            'Charset': 'utf-8'
          },
          body: jsonEncode({
            "post_content": post_content,
            "post_image":
                'data:image/png;base64,' + base64Encode(file.readAsBytesSync()),
            "post_author": post_author
          }));
      if (response.statusCode == 201) {
        toastMessage("Uploaded");
        log(response.statusCode.toString());
      } else {
        log("status code is not 201");
        log(response.statusCode.toString());
        log(response.body.toString());
        log(response.toString());
        toastMessage("Something went wrong! Failed to upload");
      }
    } catch (e) {
      log(e.toString());
      toastMessage("Failed to upload! please try again!!");
    }
  }

  getPosts({required String userToken}) async {
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
        allPosts = AllPostsModel.fromMap(posts);
        log(allPosts!.data.toString());
        notifyListeners();
      } else {
        toastMessage("Failed to load");
        log("status code while getting post is not 200");
      }
    } catch (e) {
      toastMessage("Failed to load");
      log("error to get posts---" + e.toString());
      toastMessage(e.toString());
    }
  }

  Future<bool> uploadPost(
      {required File image,
      required String userToken,
      required String post_content,
      required int post_author}) async {
    try {
      Map<String, String> headers = {
        'Content-Type': 'application/json',
        "Authorization": 'Bearer $userToken',
        'Charset': 'utf-8'
      };
      final request = http.MultipartRequest(
        'POST',
        Uri.parse("https://note-sharing-application.onrender.com/post/"),
      );
      request.files
          .add(await http.MultipartFile.fromPath('post_image', image.path));

      request.headers.addAll(headers);
      request.fields['post_content'] = post_content;
      request.fields['post_author'] = post_author.toString();

      log("request fields ---" + request.fields.toString());
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 201) {
        toastMessage("Posted Sucessfully");
        Get.off(CustomBottomNavBar());
        log(response.statusCode.toString());
        return true;
      } else {
        log("status code is not 201");
        log(response.statusCode.toString());
        log(response.body.toString());
        log(response.toString());
        toastMessage("Something went wrong! Failed to upload");
        return false;
      }
    } catch (e) {
      toastMessage(e.toString());
      log("Update User Error ---- : $e");
    }
    return false;
  }

  Future<List<PostModel>> getUploadedPostsOfUser(
      int uid, String userToken) async {
    try {
      http.Response response = await http.get(
          Uri.parse(
              "https://note-sharing-application.onrender.com/post/user=$uid"),
          headers: {
            'Content-Type': 'application/json',
            "Authorization": 'Bearer $userToken'
          });
      log("respose -------" + response.statusCode.toString());
      if (response.statusCode == 200) {
        Map posts = jsonDecode(response.body) as Map;
        List postData = posts["data"];
        // log(postData.toString());
        List<PostModel> myPosts = [];
        postData.forEach(
          (element) {
            var a = PostModel.fromMap(element);
            myPosts.add(a);
          },
        );
        log("my posts are ---$myPosts");
        return myPosts;
      } else {
        toastMessage("Failed to load");
        log("status code while getting post is not 200");
      }
    } catch (e) {
      toastMessage(e.toString());
      toastMessage("Somehting went wrong");
    }
    return [];
  }
}
