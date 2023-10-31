import 'package:top_news_app/utils/constants.dart';

class Comment {
  String newsId;
  String audioUrl;

  //When using curly braces { } we note dart that
  //the parameters are optional
  Comment({required this.newsId, required this.audioUrl});

  factory Comment.fromDatabaseJson(Map<String, dynamic> data) => Comment(
      //Factory method will be used to convert JSON objects that
      //are coming from querying the database and converting
      //it into a Comment object
      newsId: data[AppConstants.newsId],
      audioUrl: data[AppConstants.audioUrl]);

  Map<String, dynamic> toDatabaseJson() => {
        //A method will be used to convert Comment objects that
        //are to be stored into the database in a form of JSON
        AppConstants.newsId: newsId,
        AppConstants.audioUrl: audioUrl,
      };
}
