import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:path_provider/path_provider.dart';
import 'package:top_news_app/bloc/comments/audiocomment_bloc.dart';
import 'package:top_news_app/ui/comment/playpausebutton.dart';
import 'package:top_news_app/utils/constants.dart';

import '../../bloc/comments/audiocomment_event.dart';
import '../../bloc/comments/audiocomment_state.dart';
import '../../model/comment/comment.dart';
import '../../resource/dimens.dart';
import '../../utils/commomutils.dart';

class CommentList extends StatefulWidget {
  final String sourceID;

  CommentList({
    super.key,
    required this.sourceID,
  });

  @override
  CommentListState createState() => CommentListState();
}

class CommentListState extends State<CommentList> {
  bool _isRecording = false;
  String _mPath = '';
  int selectedIndex = -1;
  final AudioCommentsBloc _audioCommentBloc = AudioCommentsBloc();
  List<Comment> comments = [];

  @override
  void initState() {
    _audioCommentBloc.add(FetchAudioComments(id: widget.sourceID));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      BlocConsumer<AudioCommentsBloc, AudioCommentsState>(
          bloc: _audioCommentBloc,
          listener: (context, state) {},
          builder: (context, state) {
            if (state is AudioCommentLoadingState) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is AudioCommentsLoaded) {
              comments = [];
              comments = (state.comments ?? []);
              if (comments.isNotEmpty) {
                return loadComments(comments);
              } else {
                return const Center(child: Text(AppConstants.noData));
              }
            } else if (state is AudioCommentsAdded) {
              _audioCommentBloc.add(FetchAudioComments(id: widget.sourceID));
              return const Center(child: CircularProgressIndicator());
            } else if (state is AudioCommentsError) {
              return Center(
                  child: Text('${AppConstants.loadFailed}: ${state.message}'));
            } //Player Stopped
            else if (state is IdlePlayState) {
              return loadComments(comments);
            } //Recording stopped
            else if (state is RecordingState) {
              return loadComments(comments);
            } else if (state is PlayingState) {
              return loadComments(comments);
            } else if (state is IdleRecordState) {
              saveFileToDb();
              return Container();
            } else {
              return const Center(child: Text(AppConstants.noData));
            }
          }),
      //
      recordWidget(),
    ]);
  }

  // List tile for Audio comments
  Widget commentTile(String audioUrl, int index) {
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
          PlayPauseButton(
            isPlaying: comments[index].isPlaying,
            onPressed: () {
              // Toggle play/pause state for the clicked item
              setState(() async {
                bool isUrlExists =
                    await checkUrlExists(comments[index].audioUrl);
                if (isUrlExists) {
                  comments[index].isPlaying = !comments[index].isPlaying;
                  if (comments[index].isPlaying) {
                    playAudio(comments[index].audioUrl, index);
                  } else {
                    stopPlay();
                  }
                }
              });
            },
          ),
        ],
      ),
    );
  }

  // Widget for record the audio file
  Widget recordWidget() {
    return Positioned(
      left: dimen_0,
      right: dimen_0,
      bottom: dimen_0,
      child: Container(
        padding: const EdgeInsets.all(dimen_16),
        child: ElevatedButton(
          onPressed: () {
            setState(() {
              //Save file
              _isRecording = !_isRecording;
              if (_isRecording) {
                recordAudio();
              } else {
                stopRecord();
              }
            });
          },
          child: Text(
              // Change the text based if record started
              _isRecording
                  ? AppConstants.stopRecordComment
                  : AppConstants.startRecordComment,
              style: const TextStyle(
                  color: Colors.black87,
                  fontSize: textFontSize_14,
                  fontWeight: FontWeight.w500)),
        ),
      ),
    );
  }

  // Function to save the audio file to database
  void saveFileToDb() {
    Comment comment = Comment(newsId: widget.sourceID, audioUrl: _mPath);
    _audioCommentBloc.add(AddAudioComment(comment: comment));
  }

  // Start and Stop record

  void stopRecord() {
    _audioCommentBloc.add(StopRecordingEvent());
  }

  void recordAudio() async {
    final tempDir = await getApplicationCacheDirectory();
    _mPath = await getFilePathMp4();
    _mPath = '${tempDir.path}/$_mPath';
    _audioCommentBloc.add(StartRecordingEvent(fileName: _mPath));
  }

// Start and Stop play
  void playAudio(String audioUrl, int index) async {
    _audioCommentBloc.add(StartPlayingEvent(audioFilePath: audioUrl));
  }

  void stopPlay() {
    _audioCommentBloc.add(StopPlayingEvent());
  }

  Widget loadComments(List<Comment> comments) {
    return Container(
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(cornerRadius),
        ),
      ),
      // just provided a fixed margin not the right solution.
      margin: const EdgeInsets.only(bottom: 80),

      child: ListView.builder(
        itemCount: comments.length,
        itemBuilder: (context, index) {
          return commentTile(comments[index].audioUrl ?? '', index);
        },
      ),
    );
  }
}
