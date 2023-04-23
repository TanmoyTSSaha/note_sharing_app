class CommentModel {
  int? status;
  String? message;
  List<CommentData>? commentData;

  CommentModel({this.status, this.message, this.commentData});

  CommentModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      commentData = <CommentData>[];
      json['data'].forEach((v) {
        commentData!.add(new CommentData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['message'] = this.message;
    if (this.commentData != null) {
      data['data'] = this.commentData!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class CommentData {
  int? commentId;
  String? commentContent;
  String? createdTime;
  int? user;
  int? post;

  CommentData(
      {this.commentId,
      this.commentContent,
      this.createdTime,
      this.user,
      this.post});

  CommentData.fromJson(Map<String, dynamic> json) {
    commentId = json['comment_id'];
    commentContent = json['comment_content'];
    createdTime = json['created_time'];
    user = json['user'];
    post = json['post'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['comment_id'] = this.commentId;
    data['comment_content'] = this.commentContent;
    data['created_time'] = this.createdTime;
    data['user'] = this.user;
    data['post'] = this.post;
    return data;
  }
}
