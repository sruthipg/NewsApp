import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:top_news_app/bloc/news/news_event.dart';
import 'package:top_news_app/bloc/news/news_state.dart';
import 'package:top_news_app/utils/commomutils.dart';
import 'package:top_news_app/utils/constants.dart';

import '../../repository/topnews_repository.dart';

class NewsBloc extends Bloc<NewsEvent, NewsState> {
  final TopNewsRepository repository = TopNewsRepository();

  NewsBloc() : super(NewsListInitialState());

  @override
  NewsState get initialState => NewsListInitialState();

  @override
  Stream<NewsState> mapEventToState(NewsEvent event) async* {
    if (event is LoadNewsEvent) {
      yield NewsListLoadingState();
      try {
        final newsList = await repository.fetchNews();
        final total = await getTotalResults(0);
        yield NewsListLoadedState(news: newsList, totalNews: total);
      } catch (e) {
        yield NewsErrorState('${AppConstants.loadFailed} $e');
      }
    }
  }
}
