import 'package:flutter/material.dart';
import 'package:flutter_rating/flutter_rating.dart';

class ReviewWidget extends StatelessWidget {
  final String userName;
  final String comment;
  final double rating;

  const ReviewWidget({Key key, this.userName, this.comment, this.rating})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          FlatButton(
            child: Text(
              'Done',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),
            onPressed: () {},
          ),
        ],
        title: Text('Review'),
        centerTitle: true,
      ),
      body: Form(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Card(
              child: Padding(
                padding: EdgeInsets.only(
                  top: 10,
                  bottom: 10,
                ),
                child: Row(
                  children: <Widget>[
                    Container(
                      decoration: BoxDecoration(
                        border: Border(right: BorderSide(width: 2)),
                      ),
                      alignment: Alignment.center,
                      height: 40,
                      width: 40,
                      child: Text(
                        '5.0',
                        style: Theme.of(context).textTheme.title,
                      ),
                    ),
                    SizedBox(
                      width: 20,
                    ),
                    StarRating(
                      rating: 1,
                      size: 30,
                    )
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Card(
              elevation: 6,
              child: Container(
                margin: EdgeInsets.all(8),
                padding: EdgeInsets.all(10),
                decoration: ShapeDecoration(shape: RoundedRectangleBorder()),
                child: TextFormField(
                  minLines: 7,
                  maxLines: 7,
                  decoration: InputDecoration(
                    hintText: 'Write a Review',
                    border: InputBorder.none,
                  ),
                  style: Theme.of(context).textTheme.subtitle,
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              '     * Your review means a lot to us and it helps people.',
              style: Theme.of(context).textTheme.caption,
            )
          ],
        ),
      ),
    );
  }
}
