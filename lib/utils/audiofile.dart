import 'dart:async';
import 'dart:io';

import 'package:audio_session/audio_session.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_sound/flutter_sound.dart';
import 'package:flutter_sound_platform_interface/flutter_sound_recorder_platform_interface.dart';
import 'package:permission_handler/permission_handler.dart';
import '../utils/commomutils.dart';

const theSource = AudioSource.microphone;

class AudioRecorder {
  final Codec _codec = Codec.aacMP4;
  String _mPath = '';
  final FlutterSoundPlayer _mPlayer = FlutterSoundPlayer();
  final FlutterSoundRecorder _mRecorder = FlutterSoundRecorder();
  bool _mPlayerIsInitiated = false;
  bool _mRecorderIsInitiated = false;

  Future<bool> initPlayer() async {
    _mPlayer.openPlayer().then((value) {
      _mPlayerIsInitiated = true;
    });
    return _mPlayerIsInitiated;
  }

  Future<bool> initAudioRecord() async {
    openTheRecorder().then((value) {
      _mRecorderIsInitiated = true;
    });
    return _mRecorderIsInitiated;
  }

  Future<void> openTheRecorder() async {
    _mPath = await getFilePathMp4();
    print('openTheRecorder $_mPath');
    if (!kIsWeb) {
      var status = await Permission.microphone.request();
      if (status != PermissionStatus.granted) {
        throw RecordingPermissionException('Microphone permission not granted');
      }
    }
    await _mRecorder!.openRecorder();

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

    _mRecorderIsInitiated = true;
  }

  void record() {
    if (_mPlayer.isPlaying || _mRecorder.isRecording) {
      stopPlayer();
      stopRecorder();
      initAudioRecord();
    }
    _mRecorder!
        .startRecorder(
          toFile: _mPath,
          codec: _codec,
          audioSource: theSource,
        )
        .then((value) {});
  }

  Future<String?> stopRecorder() async {
    if (_mRecorder.isRecording) {
      await _mRecorder.stopRecorder().then((value) {
        _mPath = value!;
      });
      _mRecorder!.closeRecorder();
      print("Recorded url: $_mPath");
    }
    return _mPath;
  }

  Future<bool> isRecording() async {
    return _mRecorder.isRecording;
  }

  Future<bool> isPlaying() async {
    return _mPlayer.isPlaying;
  }

  void play(String url) async {
    var isUrlExists = await checkUrlExists(url);
    if (isUrlExists) {
      if (_mPlayer.isPlaying || _mRecorder.isRecording) {
        stopPlayer();
        stopRecorder();
        initPlayer();
      }
      _mPlayer!
          .startPlayer(
              fromURI: url,
              //codec: kIsWeb ? Codec.opusWebM : Codec.aacADTS,
              whenFinished: () {})
          .then((value) {});
    } else {}
  }

  void stopPlayer() {
    if (_mPlayer.isPlaying) {
      _mPlayer!.stopPlayer().then((value) {});
      _mPlayer!.closePlayer();
    }
  }
}
