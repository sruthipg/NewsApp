import 'package:top_news_app/utils/constants.dart';

import '../model/comment/comment.dart';
import '../utils/audiocommentdb.dart';

class CommentDao {
  final dbHelper = DatabaseHelper.dbHelper;

  //Adds new comment records
  Future<int?> saveComment(Comment comment) async {
    final db = await dbHelper.database;
    int? result =
        await db?.insert(AppConstants.commentTable, comment.toDatabaseJson());
    return result;
  }

  //Get All Comment items by newsId
  Future<List<Comment>> getCommentById(String newsId) async {
    final db = await dbHelper.database;
    List<Map<String, dynamic>>? result;
    if (newsId.isNotEmpty) {
      result = await db?.query(AppConstants.commentTable,
          where: '${AppConstants.newsId} = ?', whereArgs: [newsId]);
    }
    List<Comment> comment = result!.isNotEmpty
        ? result.map((item) => Comment.fromDatabaseJson(item)).toList()
        : [];
    return comment;
  }

  //Delete comment comment if not exits
  Future<int?> deleteComment(int id) async {
    final db = await dbHelper.database;
    var result = await db
        ?.delete(AppConstants.commentTable, where: 'id = ?', whereArgs: [id]);
    return result;
  }

  //We are not going to use this
  Future deleteAllComments() async {
    final db = await dbHelper.database;
    var result = await db?.delete(
      AppConstants.commentTable,
    );
    return result;
  }
}
