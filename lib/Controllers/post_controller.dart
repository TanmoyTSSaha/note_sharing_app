import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:note_sharing_app/models/posts_model.dart';

class PostController extends GetxController {
  AllPostsModel? allPost;
  
  updateAllPosts({required AllPostsModel allPosts}) {
    allPost = allPosts;
    update();
  }
}