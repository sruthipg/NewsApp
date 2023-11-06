import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:top_news_app/model/news/news.dart';
import 'package:top_news_app/utils/constants.dart';

import '../utils/commomutils.dart';

/*** The logic should be all news should update the db and
 * if the data already exists we don't need to update the db and load the data from the database.
 * As the news object is so big and just to show how we can update the shared preference and
 * I created another logic.
 * Here I have implemented like in 30 min a new API will get call and update the total news.
 * basically it should be loaded from database
 */

class TopNewsRepository {
  final String apiUrl = AppConstants.url;

  Future<News> fetchNews() async {
    final response = await http.get(Uri.parse(apiUrl));
    final prefs = await SharedPreferences.getInstance();
    if (response.statusCode == 200) {
      final news = json.decode(response.body);
      final News newsData = News.fromJson(news);
      int total = await getTotalResults(newsData.totalResults);
      await prefs.setInt(AppConstants.totalNewsRetrieved, total);
      return newsData;
    } else {
      throw Exception('Failed to load news');
    }
  }
}
