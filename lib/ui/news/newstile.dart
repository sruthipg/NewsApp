import 'package:flutter/material.dart';
import 'package:top_news_app/resource/dimens.dart';
import 'package:top_news_app/ui/comment/commentlist.dart';
import 'package:top_news_app/utils/constants.dart';
import 'package:top_news_app/utils/hex_color.dart';

// Widget to Display each News  and corresponding Comments

class NewsTile extends StatefulWidget {
  final String imgUrl, title, sourceId;

// Currently we are taking the Source Name to save comments in SQL database
  const NewsTile(
      {super.key,
      required this.imgUrl,
      required this.title,
      required this.sourceId});

  @override
  NewsTileState createState() => NewsTileState();
}

class NewsTileState extends State<NewsTile> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      alignment: Alignment.bottomCenter,
      decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
              bottomRight: Radius.circular(6), bottomLeft: Radius.circular(6))),
      width: MediaQuery.of(context).size.width,
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ClipRRect(
                borderRadius: BorderRadius.circular(boxRadius),
                child: Image.network(
                  widget.imgUrl,
                  height: newsImageHeight,
                  width: MediaQuery.of(context).size.width,
                  fit: BoxFit.cover,
                )),
            const SizedBox(
              height: 12,
            ),
            Text(
              widget.title,
              maxLines: 2,
              style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 20,
                  fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: dimen_10),
            GestureDetector(
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  builder: (BuildContext context) {
                    return CommentList(sourceID: widget.sourceId);
                  },
                );
              },
              child: Container(
                padding: const EdgeInsets.all(dimen_10),
                color: HexColor('#DFDFDF'),
                child: const Text(
                  AppConstants.viewReplies,
                    style: TextStyle(
                        color: Colors.black87,
                        fontSize: 20,
                        fontWeight: FontWeight.w500)
                ),
              ),
            )
          ]),
    );
  }
}
