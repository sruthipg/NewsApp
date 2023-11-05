import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:top_news_app/bloc/comments/audiocomment_bloc.dart';
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
  bool _isPlaying = false;
  bool _isRecording = false;
  String _mPath = '';
  final AudioCommentsBloc _audioCommentBloc = AudioCommentsBloc();
  List<Comment> comments = [];

  @override
  void initState() {
    checkPermission();
    _audioCommentBloc.add(FetchAudioComments(id: widget.sourceID));
    super.initState();
  }

  @override
  void setState(VoidCallback fn) {
    super.setState(fn);
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
              comments = (state.comments ?? []);
              if (comments.isNotEmpty) {
                return Container(
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(cornerRadius),
                    ),
                  ),
                  margin: const EdgeInsets.symmetric(vertical: dimen_16),
                  child: ListView.builder(
                    itemCount: comments.length,
                    itemBuilder: (context, index) {
                      return CommentTile(comments[index].audioUrl ?? '', index);
                    },
                  ),
                );
              } else {
                return const Center(child: Text(AppConstants.noData));
              }
            } else if (state is AudioCommentsAdded) {
              _audioCommentBloc.add(FetchAudioComments(id: widget.sourceID));
              return const Center(child: CircularProgressIndicator());
            } else if (state is AudioCommentsError) {
              return Center(
                  child: Text('${AppConstants.loadFailed}: ${state.message}'));
            } else if (state is IdlePlayState) {
              _isPlaying = !_isPlaying;
              return Container();
            } else if (state is IdleRecordState) {
              _isRecording = !_isRecording;
              return Container();
            } else {
              return const Center(child: Text(AppConstants.noData));
            }
          }),
      Positioned(
        left: dimen_0,
        right: dimen_0,
        bottom: dimen_0,
        child: Container(
          padding: const EdgeInsets.all(dimen_16),
          child: ElevatedButton(
            onPressed: () {
              setState(() {
                //Save file
                recordAudio();
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
      ),
    ]);
  }

  void saveFileToDb() {
    Comment comment = Comment(newsId: widget.sourceID, audioUrl: _mPath);
    _audioCommentBloc.add(AddAudioComment(comment: comment));
  }

  Widget CommentTile(String audioUrl, int index) {
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
            //Change the icon is playing
            icon: _isPlaying
                ? const Icon(Icons.pause)
                : const Icon(Icons.play_arrow),
            iconSize: playerIconSize,
            onPressed: () {
              setState(() {
                playAudio(audioUrl, index);
              });
            },
          ),
        ],
      ),
    );
  }

  void recordAudio() async {
    await checkPermission();
    _isRecording = !_isRecording;
    if (_isRecording) {
      _mPath = await getFilePathMp4();
      _audioCommentBloc.add(StartRecordingEvent(fileName: _mPath));
    } else {
      _audioCommentBloc.add(StopRecordingEvent());
    }
  }

  void playAudio(String audioUrl, int index) async {
    await checkPermission();
    _isPlaying = !_isPlaying;
    comments = await List.generate(
      5, // Replace with the desired number of items
      (index) => Comment(
          isPlaying: false,
          audioUrl: comments[index].audioUrl,
          newsId: comments[index].newsId),
    );
    if (_isPlaying) {
      comments[index].isPlaying = true;
      _audioCommentBloc.add(StartPlayingEvent(audioFilePath: audioUrl));
    } else {
      _audioCommentBloc.add(StopPlayingEvent());
    }
  }
}
