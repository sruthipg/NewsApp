import 'package:top_news_app/model/news/news.dart';

abstract class NewsState {}

class NewsListInitialState extends NewsState {}

class NewsListLoadingState extends NewsState {}

class NewsListLoadedState extends NewsState {
  final News news;
  final int totalNews;

  NewsListLoadedState({required this.news, required this.totalNews});
}

class NewsErrorState extends NewsState {
  final String error;

  NewsErrorState(this.error);
}
