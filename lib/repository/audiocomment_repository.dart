import '../localdata/CommentDao.dart';
import '../model/comment/comment.dart';

// We also can use emit instead of return the Future
class AudioCommentRepository {
  CommentDao commentDao = CommentDao();

  Future<List<Comment>> getAudioComment(String newsId) async {
    return await commentDao.getCommentById(newsId);
  }

  Future<int> saveAudioComment(Comment comment) async {
    return await commentDao.saveComment(comment) ?? 0;
  }
}
