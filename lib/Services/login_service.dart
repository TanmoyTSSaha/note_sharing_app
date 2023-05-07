import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:note_sharing_app/Hive/logged_in.dart';
import 'package:note_sharing_app/constants.dart';
import 'package:note_sharing_app/main.dart';
import 'package:http/http.dart' as http;
import 'package:note_sharing_app/shared.dart';

import '../Hive/token/token.dart';
import '../Hive/user_profile.dart';
// import 'package:xfile/xfile.dart';

class LoginService extends ChangeNotifier {
  TokenModel? userResponseToken;
  bool? isUserAlreadyExist = false;
  bool? isuserEmailAlreadyExist = false;
  bool isLoggedIn = false;
  String? userToken;
  UserDataHive? userData;
  UserProfileDataHive? userProfile;
  bool refreshToken = false;
  // var box = Hive.box<UserDataHive>("UserInfo");
  void changeStatusEmailExist(bool status) {
    isuserEmailAlreadyExist = status;
    notifyListeners();
  }

  void changeStatusUserNameExist(bool status) {
    isUserAlreadyExist = status;
    notifyListeners();
  }

  registerUser(
      {required String firstName,
      required String lastName,
      required String email,
      required String password,
      required String userName}) async {
    try {
      Map<String, dynamic> userDetail = {
        "first_name": firstName,
        "last_name": lastName,
        "name": "$firstName $lastName",
        "email": email,
        "password": password,
        "username": userName
      };
      http.Response response = await http.post(
          Uri.parse(
            "https://note-sharing-application.onrender.com/user/api/register/",
          ),
          headers: {'Content-Type': 'application/json', 'Charset': 'utf-8'},
          body: jsonEncode(userDetail));

      Map<String, dynamic> data =
          jsonDecode(response.body) as Map<String, dynamic>;
      if (data.containsKey("access") || data.containsKey("refresh")) {
        userResponseToken = TokenModel.fromMap(data);
        notifyListeners();
        box.put(tokenHiveKey, userResponseToken);
        userToken = userResponseToken!.accessToken;
        notifyListeners();
      } else if (data.containsKey("username")) {
        isUserAlreadyExist = true;
        notifyListeners();
      } else if (data.containsKey("email")) {
        isuserEmailAlreadyExist = true;
        notifyListeners();
      }
    } catch (e) {
      log('$e---error');
      Fluttertoast.showToast(msg: "$e");
    }
  }

  deletePost({required int postId}) async {
    try {
      var response = await http.delete(
        Uri.parse(
            "https://note-sharing-application.onrender.com/post/post=$postId/"),
        headers: {
          'Content-Type': 'application/json',
          "Authorization": 'Bearer $userToken'
        },
      );
      log(response.body.toString() + "_-----on post delete respose");
    } catch (e) {
      toastMessage("something went wrong!!");
    }
  }

  loginUser({required String userName, required String password}) async {
    try {
      http.Response loginResponse = await http.post(
          Uri.parse(refreshToken
              ? "https://note-sharing-application.onrender.com/user/api/login/refresh:refresh_token"
              : "https://note-sharing-application.onrender.com/user/api/login/"),
          headers: {'Content-Type': 'application/json', 'Charset': 'utf-8'},
          body: jsonEncode({"username": userName, "password": password}));

      Map<String, dynamic> data =
          jsonDecode(loginResponse.body) as Map<String, dynamic>;
      log(loginResponse.body.toString());

      if (data.containsKey("refresh") || data.containsKey("access")) {
        userResponseToken = TokenModel.fromMap(data);
        box.put(tokenHiveKey, userResponseToken);
        isLoggedIn = true;
        notifyListeners();
        userToken = userResponseToken!.accessToken;
        notifyListeners();
        // log(userResponseToken.toString());
      } else if (data.containsKey("message") &&
          data.containsValue("Token is invalid or expired")) {
        refreshToken = true;
        notifyListeners();
      } else if (data.containsKey("error") &&
          data.containsValue("Invalid credentials")) {
        log("worng credentials");
        isLoggedIn = false;
        notifyListeners();
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "$e");
      log(e.toString());
    }
  }

  getUserData() async {
    try {
      http.Response loginResponse = await http.get(
        Uri.parse(
            "https://note-sharing-application.onrender.com/user/api/user/"),
        headers: {
          'Content-Type': 'application/json',
          "Authorization": 'Bearer $userToken'
        },
      );

      Map<String, dynamic> mapData =
          jsonDecode(loginResponse.body) as Map<String, dynamic>;
      Map<String, dynamic> data = mapData["data"];
      log("user data respose --${data}");
      if (data.containsKey("id")) {
        userData = UserDataHive.fromMap(data);
        box.put(userDataKey, userData!);
        log(userData.toString());
      } else {
        log("user data is null");
        userData = null;
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "$e");
      log("while getting user data ----$e");
    }
  }

  createProfile(
      {String? university,
      String? course,
      String? year,
      String? desc,
      String? gender,
      String? usertoken,
      // File? profileImage,
      String? userId}) async {
    try {
      http.Response response = await http.post(
          Uri.parse(
              "https://note-sharing-application.onrender.com/user/api/profile/"),
          headers: {
            'Content-Type': 'application/json',
            'Charset': 'utf-8',
            "Authorization": 'Bearer $usertoken'
          },
          body: jsonEncode({
            "user": userId,
            "gender": gender,
            "description": desc,
            "university": university,
            "course": course,
            "year": year,
            // "profile_image": profileImage
          }));
      Map<String, dynamic> data =
          jsonDecode(response.body) as Map<String, dynamic>;
      log(response.body.toString());
      if (data.containsKey("id") || data.containsKey("user")) {
        userProfile = UserProfileDataHive.fromMap(data);
        box.put(userProfileKey, userProfile!);
        log("-----------------++-----------${box.get(userProfileKey)}");
        notifyListeners();
      }
      log(data.toString());
    } catch (e) {
      Fluttertoast.showToast(msg: "$e");
      log(e.toString());
    }
  }

  updateProfileDetails(
      {String? university,
      String? course,
      String? year,
      String? desc,
      String? gender,
      String? usertoken,
      // File? profileImage,
      String? userId}) async {
    try {
      http.Response response = await http.put(
          Uri.parse(
              "https://note-sharing-application.onrender.com/user/api/profile/"),
          headers: {
            'Content-Type': 'application/json',
            'Charset': 'utf-8',
            "Authorization": 'Bearer $usertoken'
          },
          body: jsonEncode({
            "user": userId,
            "gender": gender,
            "description": desc,
            "university": university,
            "course": course,
            "year": year,
            // "profile_image": profileImage
          }));
      Map<String, dynamic> mapData =
          jsonDecode(response.body) as Map<String, dynamic>;
      log(response.body.toString());
      Map<String, dynamic> data = mapData["data"];
      if (data.containsKey("id") || data.containsKey("user")) {
        userProfile = UserProfileDataHive.fromMap(data);
        box.put(userProfileKey, userProfile!);
        toastMessage("Updated Succesfully");
        log("-----------------++-----------${box.get(userProfileKey)}");
        notifyListeners();
      }
      log(data.toString());
    } catch (e) {
      toastMessage("Failed to Update");
      Fluttertoast.showToast(msg: "$e");
      log(e.toString());
    }
  }

  getProfileDetails() async {
    try {
      http.Response response = await http.get(
        Uri.parse(
            "https://note-sharing-application.onrender.com/user/api/profile/"),
        headers: {
          'Content-Type': 'application/json',
          "Authorization": 'Bearer $userToken'
        },
      );
      log(response.body);
      Map mapData = jsonDecode(response.body) as Map;
      Map data = mapData["data"];
      if (data.containsKey("id") || data.containsKey("user")) {
        userProfile = UserProfileDataHive.fromMap(data as Map<String, dynamic>);
        box.put(userProfileKey, userProfile);
        notifyListeners();
        log("${box.get(userProfileKey)} __________________________");
      }
    } catch (e) {
      log("while getting profile details error---$e");
      Fluttertoast.showToast(msg: "Wrong Credentials");
    }
  }

  updateProfileDetails2(
      {String? university,
      String? course,
      String? year,
      String? desc,
      String? gender,
      String? usertoken,
      File? profileImage,
      String? userId}) async {
    try {
      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Charset': 'utf-8',
        "Authorization": 'Bearer $usertoken'
      };
      final request = http.MultipartRequest(
          "PUT",
          Uri.parse(
              "https://note-sharing-application.onrender.com/user/api/profile/"));
      request.files.add(await http.MultipartFile.fromPath(
          "profile_iamge", profileImage!.path));
      request.headers.addAll(headers);
      request.fields["user"] = userId!;
      request.fields["gender"] = gender!;
      request.fields["description"] = desc!;
      request.fields["university"] = university!;
      request.fields["course"] = course!;
      request.fields["year"] = year!;
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      Map<String, dynamic> mapData =
          jsonDecode(response.body) as Map<String, dynamic>;
      log(response.body.toString());
      Map<String, dynamic> data = mapData["data"];
      if (data.containsKey("id") || data.containsKey("user")) {
        userProfile = UserProfileDataHive.fromMap(data);
        box.put(userProfileKey, userProfile!);
        toastMessage("Updated Succesfully");
        log("-----------------++-----------${box.get(userProfileKey)}");
        notifyListeners();
      }
      log(data.toString());
    } catch (e) {
      toastMessage("Failed to Update");
      log(e.toString());
    }
  }

  // getProfileDetails2() async {}
  getAccessToken({required String refreshToken}) async {
    try {
      http.Response accessResponse = await http.post(
        Uri.parse(
            "https://note-sharing-application.onrender.com/user/api/login/refresh/"),
        headers: {'Content-Type': 'application/json', 'Charset': 'utf-8'},
        body: jsonEncode({"refresh": refreshToken}),
      );

      Map<String, dynamic> accessData =
          jsonDecode(accessResponse.body) as Map<String, dynamic>;
      log(accessResponse.body.toString());

      if (accessData.containsKey("refresh") ||
          accessData.containsKey("access")) {
        userResponseToken = TokenModel.fromMap(accessData);
        box.put(tokenHiveKey, userResponseToken);
        userToken = userResponseToken!.accessToken;
        notifyListeners();
      } else {
        log('getAccessToken: Something went wrong');
        toastMessage(
            'Something went wrong. Please refresh again or Login again');
      }
    } catch (e) {
      toastMessage("Something went wrong. $e");
      log('getAccessToken : ' + e.toString());
    }
  }
}
