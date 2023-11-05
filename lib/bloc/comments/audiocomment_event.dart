import '../../model/comment/comment.dart';

abstract class AudioCommentsEvent {}

// Not using can use in better logic
class AudioPlayEvent extends AudioCommentsEvent {
  bool isPlaying;
  String url;

  AudioPlayEvent({required this.isPlaying, required this.url});
}

class FetchAudioComments extends AudioCommentsEvent {
  final String id;

  FetchAudioComments({required this.id});
}

class AddAudioComment extends AudioCommentsEvent {
  final Comment comment;

  AddAudioComment({required this.comment});
}

class StartRecordingEvent extends AudioCommentsEvent {
  String fileName;

  StartRecordingEvent({required this.fileName});
}

class StopRecordingEvent extends AudioCommentsEvent {}

class StartPlayingEvent extends AudioCommentsEvent {
  final String audioFilePath;

  StartPlayingEvent({required this.audioFilePath});
}

class StopPlayingEvent extends AudioCommentsEvent {}

