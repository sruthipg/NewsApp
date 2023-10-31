import 'package:flutter/material.dart';

import '../../resource/dimens.dart';
import '../../utils/audiofile.dart';
import '../../utils/constants.dart';

class CommentTile extends StatefulWidget {
  final String audioUrl;

  const CommentTile({super.key, required this.audioUrl});

  @override
  CommentTileState createState() => CommentTileState();
}

class CommentTileState extends State<CommentTile> {
  bool _isPlaying = false;
  final AudioRecorder _audioRecorder = AudioRecorder();
  bool _isAudioPlayRecordInitiated = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(cornerRadius),
        ),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: userIconRadius,
            backgroundImage: NetworkImage(AppConstants.sampleAvatar),
          ),
          const SizedBox(width: dimen_16),
          // Add spacing between avatar and audio button
          // Audio Play Button
          IconButton(
            style: ButtonStyle(
              padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                const EdgeInsets.all(8),
              ),
            ),
            icon: _isPlaying
                ? const Icon(Icons.pause)
                : const Icon(Icons.play_arrow),
            iconSize: playerIconSize,
            onPressed: () {
              setState(() {
                _isPlaying = !_isPlaying;
                playAndPauseAudio(widget.audioUrl);
              });
            },
          ),
        ],
      ),
    );
  }

// This can better handle creating single instance and while playing record should not work.
// Should not allow to play multiple comments. Not a final version of code.
  void initRecorder() async {
    _isAudioPlayRecordInitiated = await _audioRecorder.init();
  }

  void playAndPauseAudio(String audioUrl) {
    if (!_isPlaying && !_isAudioPlayRecordInitiated) {
      initRecorder();
    }
    if (_isPlaying) {
      _audioRecorder.play(audioUrl);
    } else {
      _audioRecorder.stopPlayer();
    }
  }
}
