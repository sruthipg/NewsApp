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

class RecordingState extends AudioCommentsState {}

class InitialRecordState extends AudioCommentsState {}

class IdleRecordState extends AudioCommentsState {}


class PlayingState extends AudioCommentsState {}

class InitialPlayState extends AudioCommentsState {}

class IdlePlayState extends AudioCommentsState {}