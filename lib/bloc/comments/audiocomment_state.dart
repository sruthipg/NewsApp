import '../../model/comment/comment.dart';

abstract class AudioCommentsState {}

class AudioCommentsInitial extends AudioCommentsState {}

class AudioCommentLoadingState extends AudioCommentsState {}

class AudioCommentsLoaded extends AudioCommentsState {
  List<Comment> comments;

  AudioCommentsLoaded({required this.comments});
}

class AudioCommentsAdded extends AudioCommentsState {
  String message;

  AudioCommentsAdded({required this.message});
}

class AudioCommentsError extends AudioCommentsState {
  final String message;

  AudioCommentsError({required this.message});
}

// Not using can use in better logic
class AudioPlayState extends AudioCommentsState {
  bool isPlaying = false;
  String url;

  AudioPlayState({required this.isPlaying, required this.url});
}
