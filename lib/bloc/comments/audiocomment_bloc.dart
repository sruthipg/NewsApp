import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:top_news_app/bloc/comments/audiocomment_event.dart';
import 'package:top_news_app/bloc/comments/audiocomment_state.dart';
import 'package:top_news_app/repository/audiocomment_repository.dart';
import 'package:top_news_app/utils/constants.dart';

import '../../model/comment/comment.dart';

class AudioCommentsBloc extends Bloc<AudioCommentsEvent, AudioCommentsState> {
  final AudioCommentRepository _repository = AudioCommentRepository();

  AudioCommentsBloc() : super(AudioCommentsInitial());

  @override
  AudioCommentsState get initialState => AudioCommentsInitial();

  @override
  Stream<AudioCommentsState> mapEventToState(AudioCommentsEvent event) async* {
    if (event is FetchAudioComments) {
      yield AudioCommentLoadingState();
      try {
        List<Comment> audioComments = [];
        audioComments = await _repository.getAudioComment(event.id);
        yield AudioCommentsLoaded(comments: audioComments);
      } catch (e) {
        yield AudioCommentsError(message: '${AppConstants.loadFailed} $e');
      }
    }
    if (event is AddAudioComment) {
      yield AudioCommentLoadingState();
      try {
        await _repository.saveAudioComment(event.comment);
        //Can update in constants
        yield AudioCommentsAdded(message: AppConstants.loadSuccess);
      } catch (e) {
        yield AudioCommentsError(message: '${AppConstants.loadFailed} $e');
      }
    }
    if (event is AudioPlayEvent) {
      yield AudioPlayState(isPlaying: event.isPlaying, url: event.url);
    }
  }
}
