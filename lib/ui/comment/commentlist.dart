import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:top_news_app/bloc/comments/audiocomment_bloc.dart';
import 'package:top_news_app/ui/comment/commenttile.dart';
import 'package:top_news_app/utils/constants.dart';

import '../../bloc/comments/audiocomment_event.dart';
import '../../bloc/comments/audiocomment_state.dart';
import '../../model/comment/comment.dart';
import '../../resource/dimens.dart';
import '../../utils/audiofile.dart';

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
  final AudioRecorder _audioRecorder = AudioRecorder();
  bool _isAudioPlayRecordInitiated = false;
  final AudioCommentsBloc _audioComment = AudioCommentsBloc();

  @override
  void initState() {
    _audioComment.add(FetchAudioComments(id: widget.sourceID));
    super.initState();
  }

  void initRecorder() async {
    _isAudioPlayRecordInitiated = await _audioRecorder.init();
  }

  bool _isRecordStarted = false;
  String _mPath = '';

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      BlocConsumer<AudioCommentsBloc, AudioCommentsState>(
          bloc: _audioComment,
          listener: (context, state) {},
          builder: (context, state) {
            if (state is AudioCommentLoadingState) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is AudioCommentsLoaded) {
              List<Comment>? comments = (state.comments ?? []);
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
                      return CommentTile(
                        audioUrl: comments[index].audioUrl ?? '',
                      );
                    },
                  ),
                );
              } else {
                return const Center(child: Text(AppConstants.noData));
              }
            } else if (state is AudioCommentsAdded) {
              _audioComment.add(FetchAudioComments(id: widget.sourceID));
              return const Center(child: CircularProgressIndicator());
            } else if (state is AudioCommentsError) {
              return Center(
                  child: Text('${AppConstants.loadFailed}: ${state.message}'));
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
                recordAndSave();
              });
            },
            child: Text(
                _isRecordStarted
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

// This is not completely developed, just created a function to record audio
// Can create a single instance and able to use
  // We should also handle while playing record should not work
  void recordAndSave() async {
    if (!_isAudioPlayRecordInitiated) {
      initRecorder();
    }
    bool? isRecording = await _audioRecorder?.checkRecordStopped();
    print(isRecording);
    if (_isAudioPlayRecordInitiated && !_isRecordStarted) {
      if (isRecording == true) {
        _isRecordStarted = true;
        _audioRecorder?.record();
      }
    } else if (isRecording == false) {
      _isRecordStarted = false;
      _mPath = (await _audioRecorder?.stopRecorder())!;
      saveFileToDb();
    }
  }

  void saveFileToDb() {
    Comment comment = Comment(newsId: widget.sourceID, audioUrl: _mPath);
    _audioComment.add(AddAudioComment(comment: comment));
  }
}
