import 'package:audio_session/audio_session.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:top_news_app/bloc/comments/audiocomment_event.dart';
import 'package:top_news_app/bloc/comments/audiocomment_state.dart';
import 'package:top_news_app/repository/audiocomment_repository.dart';
import 'package:top_news_app/utils/constants.dart';

import '../../model/comment/comment.dart';
import '../../utils/commomutils.dart';

class AudioCommentsBloc extends Bloc<AudioCommentsEvent, AudioCommentsState> {
  final AudioCommentRepository _repository = AudioCommentRepository();
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  final FlutterSoundPlayer _player = FlutterSoundPlayer();
  bool isRecorderInitiated = false;
  bool isPlayerInitiated = false;
  final Codec _codec = Codec.aacMP4;

  AudioCommentsBloc() : super(AudioCommentsInitial());

  @override
  AudioCommentsState get initialState => AudioCommentsInitial();

  @override
  Stream<AudioCommentsState> mapEventToState(AudioCommentsEvent event) async* {
    await _openTheRecorder().then((value) {
      isRecorderInitiated = true;
    });
    await _player.openPlayer().then((value) {
      isPlayerInitiated = true;
    });
// Fetch the comments
    if (event is FetchAudioComments) {
      print("FetchAudioComments");
      yield AudioCommentLoadingState();
      try {
        List<Comment> audioComments = [];
        audioComments = await _repository.getAudioComment(event.id);
        yield AudioCommentsLoaded(comments: audioComments);
      } catch (e) {
        yield AudioCommentsError(message: '${AppConstants.loadFailed} $e');
      }
    }
    // When new comment is added
    if (event is AddAudioComment) {
      print("AddAudioComment");
      yield AudioCommentLoadingState();
      try {
        await _repository.saveAudioComment(event.comment);
        // Update the comments
        yield AudioCommentsAdded(message: AppConstants.loadSuccess);
      } catch (e) {
        yield AudioCommentsError(message: '${AppConstants.loadFailed} $e');
      }
    }
    // Start Record
    if (event is StartRecordingEvent) {
      try {
        print("StartRecordingEvent");
        await _recorder.startRecorder(
          toFile: event.fileName,
          codec: _codec,
          audioSource: AppConstants.theSource,
        );
        _recorder.onProgress!.listen((audioData) {
          print("StartRecordingEvent $audioData");
          if (event == _recorder.isStopped) {
            add(StopRecordingEvent());
          }
        });
        yield RecordingState();
      } catch (error) {
        print('Error starting recording: $error');
      }
    } else if (event is StopRecordingEvent) {
      print("StopRecordingEvent");
      await _recorder.stopRecorder();
      yield IdleRecordState();
    }
    // Play the audiofile
    if (event is StartPlayingEvent) {
      print("StartPlayingEvent");
      try {
        await _player.startPlayer(fromURI: event.audioFilePath);
        _player.onProgress!.listen((state) {
          print("StartPlayingEvent: $state");
          if (state == PlayerState.isStopped) {
            print("StartPlayingEvent: PlayingStopped");
            add(StopPlayingEvent());
          }
        });
        yield PlayingState();
      } catch (error) {
        print('Error starting playback: $error');
      }
    } else if (event is StopPlayingEvent) {
      print("StopPlayingEvent");
      _player.stopPlayer();
      yield IdlePlayState();
    }
  }

  @override
  Future<void> close() {
    isRecorderInitiated = false;
    isPlayerInitiated = false;
    _recorder.closeRecorder();
    _player.closePlayer();
    return super.close();
  }

  Future<void> _openTheRecorder() async {
    if (!kIsWeb) {
      var status = await Permission.microphone.request();
      if (status != PermissionStatus.granted) {
        throw RecordingPermissionException('Microphone permission not granted');
      }
    }
    await _recorder!.openRecorder();

    final session = await AudioSession.instance;
    await session.configure(AudioSessionConfiguration(
      avAudioSessionCategory: AVAudioSessionCategory.playAndRecord,
      avAudioSessionCategoryOptions:
          AVAudioSessionCategoryOptions.allowBluetooth |
              AVAudioSessionCategoryOptions.defaultToSpeaker,
      avAudioSessionMode: AVAudioSessionMode.spokenAudio,
      avAudioSessionRouteSharingPolicy:
          AVAudioSessionRouteSharingPolicy.defaultPolicy,
      avAudioSessionSetActiveOptions: AVAudioSessionSetActiveOptions.none,
      androidAudioAttributes: const AndroidAudioAttributes(
        contentType: AndroidAudioContentType.speech,
        flags: AndroidAudioFlags.none,
        usage: AndroidAudioUsage.voiceCommunication,
      ),
      androidAudioFocusGainType: AndroidAudioFocusGainType.gain,
      androidWillPauseWhenDucked: true,
    ));
  }
}
