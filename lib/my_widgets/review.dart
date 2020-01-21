import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating/flutter_rating.dart';
import 'package:sennit/main.dart';
import 'package:sennit/models/models.dart';

class ReviewWidget extends StatelessWidget {
  static TextEditingController _commentController;
  final User user;
  final String itemId;
  static var actionButton;
  static Review _review;
  final bool driver;
  static bool _isDriverMode;
  static String _driverId;

  ReviewWidget({
    @required this.user,
    @required this.itemId,
    this.driver = false,
    comment = "",
    driverId = "",
  }) {
    actionButton = _ActionButton(
      user: user,
      itemId: itemId,
    );
    _isDriverMode = driver;
    _commentController = TextEditingController();
    _commentController.text = comment;
    _review = null;
    _driverId = driverId;
  }

  // @override
  // void initState() {

  //   super.initState();
  // }

  // @override
  // dispose() {
  //   super.dispose();
  //   ReviewWidgetState._review = null;
  //   _commentController = null;
  // }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Review>(
        future: !ReviewWidget._isDriverMode
            ? initReview()
            : Future.delayed(
                Duration(seconds: 0),
                () {
                  return null;
                },
              ),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.connectionState == ConnectionState.none &&
              snapshot.data == null) {
            Utils.showSnackBarError(context, 'Network Error');
            return Center(
              child: InkWell(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(Icons.replay),
                    Text('\ntab to refresh'),
                  ],
                ),
                onTap: () {
                  (context as Element).markNeedsBuild();
                },
              ),
            );
          }
          return Scaffold(
            appBar: AppBar(
              actions: <Widget>[
                actionButton,
              ],
              title: Text('Review'),
              centerTitle: true,
            ),
            body: SingleChildScrollView(
              child: Form(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Card(
                      child: Padding(
                          padding: EdgeInsets.only(
                            top: 10,
                            bottom: 10,
                          ),
                          child: _StarWidget(
                            rating:
                                _isDriverMode ? 0 : _StarWidgetState._rating,
                            parent: this,
                          )),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Card(
                      elevation: 6,
                      child: Container(
                        margin: EdgeInsets.all(8),
                        padding: EdgeInsets.all(10),
                        decoration:
                            ShapeDecoration(shape: RoundedRectangleBorder()),
                        child: TextFormField(
                          minLines: 7,
                          maxLines: 7,
                          decoration: InputDecoration(
                            hintText: 'Write a Review',
                            border: InputBorder.none,
                          ),
                          controller: _commentController,
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
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }

  Future<Review> initReview() async {
    var reviewData =
        await Firestore.instance.collection('reviews').document(itemId).get();
    if (reviewData == null ||
        reviewData.data == null ||
        reviewData.data.isEmpty) {
      _StarWidgetState._update = false;
      return null;
    }

    Review review = Review.fromMap(Map.from(reviewData.data[user.userId]));
    _commentController.text = review.reviewDescription;
    _StarWidgetState._rating = review.rating;
    _StarWidgetState._update = true;
    ReviewWidget._review = review;
    return review;
  }

  setActionButtonState() {
    actionButton.setState();
  }
}

class _ActionButton extends StatefulWidget {
  final user;
  final itemId;

  final state = _ActionButtonState();

  _ActionButton({Key key, @required this.user, @required this.itemId})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return state;
  }

  setState() {
    state.rebuild();
  }
}

class _ActionButtonState extends State<_ActionButton> {
  rebuild() {
    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      child: Text(
        ReviewWidget._isDriverMode
            ? _StarWidgetState._rating == null || _StarWidgetState._rating == 0
                ? 'Cancel'
                : 'Done'
            : !_StarWidgetState._update
                ? _StarWidgetState._rating == null ||
                        _StarWidgetState._rating == 0
                    ? 'Cancel'
                    : 'Done'
                : 'Update',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.blue.shade600,
        ),
      ),
      onPressed: () {
        if (ReviewWidget._isDriverMode) {
          DateTime lastUpdated = DateTime.now();
          ReviewForDriver review = ReviewForDriver(
            userId: widget.user.userId,
            createdOn: lastUpdated,
            driverid: ReviewWidget._driverId,
            rating: _StarWidgetState._rating,
            reviewDescription: ReviewWidget._commentController.text,
            reviewedBy: widget.user.fullname,
            lastUpdated: lastUpdated,
          );

          Firestore.instance
              .collection('reviewsForDrivers')
              .document(ReviewWidget._driverId)
              .setData(
            {"${widget.user.userId}": review.toMap()},
            merge: true,
          );
          Navigator.of(context).pop({});
        } else if (!_StarWidgetState._update &&
            _StarWidgetState._rating != null &&
            _StarWidgetState._rating > 0) {
          DateTime lastUpdated = DateTime.now();
          Review review = Review(
            userId: widget.user.userId,
            createdOn: lastUpdated,
            itemId: widget.itemId,
            rating: _StarWidgetState._rating,
            reviewDescription: ReviewWidget._commentController.text,
            reviewedBy: widget.user.fullname,
            lastUpdated: lastUpdated,
          );

          Firestore.instance
              .collection('reviews')
              .document(widget.itemId)
              .setData(
            {"${widget.user.userId}": review.toMap()},
            merge: true,
          );
          Navigator.of(context).pop({});
        } else if (_StarWidgetState._rating != null &&
            _StarWidgetState._rating > 0) {

          ReviewWidget._review.lastUpdated = DateTime.now();
          ReviewWidget._review.reviewDescription =
              ReviewWidget._commentController.text;
          ReviewWidget._review.rating = _StarWidgetState._rating;
          Firestore.instance
              .collection('reviews')
              .document(widget.itemId)
              .setData({widget.user.userId: ReviewWidget._review.toMap()},
                  merge: true);
          Navigator.of(context).pop({});
        } else {
          Navigator.of(context).pop({});
        }
      },
    );
  }
}

class _StarWidget extends StatefulWidget {
  final rating;
  final ReviewWidget parent;

  const _StarWidget({Key key, this.rating, this.parent}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _StarWidgetState(rating);
  }
}

class _StarWidgetState extends State<_StarWidget> {
  static double _rating;
  static bool _update = false;

  _StarWidgetState(rating) {
    _rating = rating;
  }

  @override
  void dispose() {
    super.dispose();
    _rating = null;
    _update = false;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          decoration: BoxDecoration(
            border: Border(right: BorderSide(width: 2)),
          ),
          alignment: Alignment.center,
          height: 40,
          width: 40,
          child: Text(
            _rating != null ? '${_rating.toStringAsFixed(1)}' : "0.0",
            style: Theme.of(context).textTheme.title,
          ),
        ),
        SizedBox(
          width: 20,
        ),
        StarRating(
            rating: _StarWidgetState._rating ?? 0.0,
            size: 30,
            starCount: 5,
            onRatingChanged: (value) {
              setState(() => _StarWidgetState._rating = value);
              widget.parent.setActionButtonState();
            }),
      ],
    );
  }
}
