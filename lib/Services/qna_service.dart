import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;

import '../models/qna_model.dart';

class QnaService extends ChangeNotifier {
  // String? userToken;
  Future getQnAPosts(String? userToken) async {
    try {
      http.Response qnaPosts = await http.get(
        Uri.parse("https://note-sharing-application.onrender.com/qna/"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $userToken"
        },
      );
      if (qnaPosts.statusCode == 200 && qnaPosts.body.isNotEmpty) {
        Map<String, dynamic> qnaPostsMap = jsonDecode(qnaPosts.body) as Map<String, dynamic>;
        QnaModel qnaModel = QnaModel.fromJson(qnaPostsMap);
        notifyListeners();
      } else {
        log("Empty data QnA Posts");
      }
    } catch (e) {
      log('QnA Posts Exception : $e');
    }
  }
}