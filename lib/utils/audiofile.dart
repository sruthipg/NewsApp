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
  bool _mplayBackReady = false;

  Future<bool> init() async {
    _mPlayer.openPlayer().then((value) {
      _mPlayerIsInitiated = true;
    });

    _openTheRecorder().then((value) {
      _mRecorderIsInitiated = true;
    });
    if (_mPlayerIsInitiated && _mRecorderIsInitiated) {
      return true;
    } else {
      return false;
    }
  }

  Future<void> _openTheRecorder() async {
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
    _mRecorder!
        .startRecorder(
          toFile: _mPath,
          codec: _codec,
          audioSource: theSource,
        )
        .then((value) {});
  }

  Future<String?> stopRecorder() async {
    String? url = '';
    await _mRecorder!.stopRecorder().then((value) {
      _mplayBackReady = true;
      url = value;
    });
    _mRecorder!.closeRecorder();
    return url;
  }

  void play(String url) async {
    var isUrlExists = await checkUrlExists(url);
    if (isUrlExists) {
      assert(_mPlayerIsInitiated &&
          _mplayBackReady &&
          _mRecorder!.isStopped &&
          _mPlayer!.isStopped);
      _mPlayer!
          .startPlayer(
              fromURI: _mPath,
              //codec: kIsWeb ? Codec.opusWebM : Codec.aacADTS,
              whenFinished: () {})
          .then((value) {});
    } else {}
  }

  void stopPlayer() {
    _mPlayer!.stopPlayer().then((value) {});
    _mPlayer!.closePlayer();
  }

  Future<bool> checkUrlExists(String path) async {
    var file = File(path);
    var isFileExists = await file.exists();
    if (isFileExists) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool?> checkRecordStopped() async {
    // if (!_mRecorderIsInitiated || !_mPlayer!.isStopped) {
    //   return null;
    // }
    if (_mRecorder!.isStopped) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool?> getPlaybackFn() async {
    if (!_mPlayerIsInitiated || !_mplayBackReady || !_mRecorder!.isStopped) {
      return null;
    }
    if (_mPlayer!.isStopped) {
      return true;
    } else {
      return false;
    }
  }
}
