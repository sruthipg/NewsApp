import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:top_news_app/bloc/comments/audiocomment_bloc.dart';
import 'package:top_news_app/bloc/comments/audiocomment_event.dart';
import 'package:top_news_app/bloc/news/news_bloc.dart';
import 'package:top_news_app/bloc/news/news_event.dart';
import 'package:top_news_app/resource/dimens.dart';
import 'package:top_news_app/ui/news/newstile.dart';
import 'package:top_news_app/utils/constants.dart';

import '../../bloc/news/news_state.dart';
import '../../utils/commomutils.dart';

// Widget for displaying TopNews
class TopNewsList extends StatefulWidget {
  @override
  _TopNewsListViewState createState() => _TopNewsListViewState();
}

class _TopNewsListViewState extends State<TopNewsList> {
// Update the time and check for results if required
  @override
  void initState()  {
    checkPermission();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppConstants.appName)),
      /*** Defining all the providers used by the child of this class,
       * So that it can be accessed by the child class.
       * The child of TopNewsList is CommentList
       */
      body: MultiBlocProvider(
        providers: [
          BlocProvider<NewsBloc>(
            create: (context) => NewsBloc()..add(LoadNewsEvent()),
            lazy: true,
          ),
          BlocProvider<AudioCommentsBloc>(
            create: (context) =>
                AudioCommentsBloc()..add(FetchAudioComments(id: '')),
          ),
        ],
        child: newsListWidget(),
      ),
    );
  }

// Update and return the Widget to the TopNewsList using BlocBuilder
  /** Here we have 3 states
   * 1. NewsListLoadingState shows progress bar
   * 2. NewsListLoadedState where data is available and show on the list
   * 3. NewsErrorState if there is an error from the API it displays the particular errror
   * 4. Any other issues like No internet etc will display No Data Found
   */
  Widget newsListWidget() {
    return BlocBuilder<NewsBloc, NewsState>(
      builder: (context, state) {
        if (state is NewsListLoadingState) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is NewsListLoadedState) {
          final news = state.news;
          final articles = news.articles ?? [];
          return Container(
            margin: const EdgeInsets.only(top: dimen_16, bottom: dimen_16),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(dimen_8),
                  child: Text(
                      "${AppConstants.totalNewsRetrieved} ${state.totalNews}"),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: articles.length,
                    itemBuilder: (context, index) {
                      return NewsTile(
                          imgUrl: articles[index].urlToImage ?? '',
                          title: articles[index].title ?? '',
                          sourceId: articles[index].source?.name ??
                              'News${Random().nextInt(100)}');
                    },
                  ),
                ),
              ],
            ),
          );
        } else if (state is NewsErrorState) {
          return Center(
              child: Text('${AppConstants.loadFailed} ${state.error}'));
        } else {
          return const Center(child: Text(AppConstants.noData));
        }
      },
    );
  }
}
