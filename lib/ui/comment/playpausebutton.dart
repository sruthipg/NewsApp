
import 'package:flutter/material.dart';

class PlayPauseButton extends StatefulWidget {
  final bool isPlaying;
  final VoidCallback onPressed;

  PlayPauseButton({required this.isPlaying, required this.onPressed});

  @override
  _PlayPauseButtonState createState() => _PlayPauseButtonState();
}

class _PlayPauseButtonState extends State<PlayPauseButton> {
  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(widget.isPlaying ? Icons.pause : Icons.play_arrow),
      onPressed: widget.onPressed,
    );
  }
}