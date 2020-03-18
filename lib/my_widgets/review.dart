import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating/flutter_rating.dart';
import 'package:sennit/main.dart';
import 'package:sennit/models/models.dart';
import 'package:sennit/user/home.dart';

class ReviewWidget extends StatefulWidget {
  // static TextEditingController _commentController;
  final User user;
  final String itemId;
  final bool isDriver;
  final bool fromNotification;
  final String driverId;
  final String userId;
  final comment;
  final orderId;

  static GlobalKey<ReviewWidgetState> _key = GlobalKey<ReviewWidgetState>();
  ReviewWidget({
    @required this.user,
    @required this.itemId,
    this.fromNotification = false,
    this.isDriver = false,
    this.driverId = "",
    this.userId = "",
    this.comment = "",
    @required this.orderId,
  }) : super(key: _key) {
    // _commentController = TextEditingController();
    // _commentController.text = comment;
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

  setActionButtonState() {
    _ActionButton._key?.currentState?.rebuild();
  }

  @override
  State<StatefulWidget> createState() {
    return ReviewWidgetState();
  }
}

class ReviewWidgetState extends State<ReviewWidget> {
  Review review;
  Driver driver;
  bool update = false;
  double rating;

  var commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    commentController.text = widget.comment;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (widget.fromNotification) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (ctx) {
                return UserHomeRoute();
              },
              settings: RouteSettings(name: UserHomeRoute.NAME),
            ),
          );
          return false;
        }
        return true;
      },
      child: FutureBuilder<Review>(
          future: !widget.isDriver ? initReview() : initDriver(),
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
                  _ActionButton(
                    orderId: widget.orderId,
                    user: widget.user,
                    itemId: widget.itemId,
                  ),
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
                              top: 10.0,
                              bottom: 10.0,
                            ),
                            child: _StarWidget(
                              update: update,
                              rating: widget.isDriver ? 0.0 : rating,
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
                            controller: commentController,
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
          }),
    );
  }

  Future<Review> initReview() async {
    var reviewData = await Firestore.instance
        .collection('reviews')
        .document(widget.itemId)
        .get();
    if (reviewData == null ||
        reviewData.data == null ||
        reviewData.data.isEmpty) {
      update = false;
      rating = 0.0;
      return null;
    }

    Review review =
        Review.fromMap(Map.from(reviewData.data[widget.user.userId]));
    commentController.text = review.reviewDescription;
    rating = review.rating;
    update = true;
    this.review = review;
    return review;
  }

  Future<Review> initDriver() async {
    final data = await Firestore.instance
        .collection('drivers')
        .document(widget.driverId)
        .get();
    if (data != null) {
      driver = Driver.fromMap(data.data);
    }
    return null;
  }
}

class _ActionButton extends StatefulWidget {
  final user;
  final itemId;
  final orderId;

  static GlobalKey<_ActionButtonState> _key = GlobalKey<_ActionButtonState>();

  _ActionButton(
      {@required this.user, @required this.itemId, @required this.orderId})
      : super(key: _key);

  @override
  State<StatefulWidget> createState() {
    return _ActionButtonState();
  }

  setState() {
    _key?.currentState?.rebuild();
  }
}

class _ActionButtonState extends State<_ActionButton> {
  rebuild() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isDriver =
        (ReviewWidget._key?.currentWidget as ReviewWidget)?.isDriver;
    String userId = widget.user.userId;
    String driverId =
        (ReviewWidget._key?.currentWidget as ReviewWidget)?.driverId;
    Driver driver = ReviewWidget._key?.currentState?.driver;
    Review myReview = ReviewWidget._key?.currentState?.review;

    return FlatButton(
      child: Text(
        isDriver
            ? _StarWidget._key?.currentState?.rating == null ||
                    _StarWidget._key?.currentState?.rating == 0
                ? 'Cancel'
                : 'Done'
            : !((_StarWidget._key?.currentWidget as _StarWidget)?.update ??
                    false)
                ? _StarWidget._key?.currentState?.rating == null ||
                        _StarWidget._key?.currentState?.rating == 0
                    ? 'Cancel'
                    : 'Done'
                : 'Update',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.blue.shade600,
        ),
      ),
      onPressed: () async {
        var commentController =
            ReviewWidget._key?.currentState?.commentController;
        final rating = _StarWidget._key?.currentState?.rating;
        final update = (_StarWidget._key?.currentWidget as _StarWidget).update;
        if (rating == null || rating <= 0) {
          Navigator.pop(context, false);
        }
        if (isDriver) {
          DateTime lastUpdated = DateTime.now();
          ReviewForDriver review = ReviewForDriver(
            orderId: widget.orderId,
            userId: userId,
            createdOn: lastUpdated,
            driverId: driverId,
            rating: rating,
            reviewDescription: commentController?.text,
            reviewedBy: Session.data['user'].fullName,
            lastUpdated: lastUpdated,
          );
          Utils.showLoadingDialog(context);
          try {
            Firestore.instance
                .collection('drivers')
                .document(driverId)
                .collection('reviews')
                .add(
                  review.toMap(),
                );
            Firestore.instance.collection('drivers').document(driverId).setData(
              {
                'rating': ((driver.rating ?? 0) + rating) /
                    ((driver.totalReviews ?? 0) + 1),
                'totalReviews': ((driver.totalReviews ?? 0) + 1),
              },
              merge: true,
            );
            Firestore.instance
                .collection('users')
                .document(userId)
                .collection('notifications')
                .document(widget.orderId)
                .updateData({
              'rated': true,
            });
          } on dynamic catch (_) {
            print(_.toString());
          }
          Navigator.pop(context);
          Navigator.of(context).pop(true);
        } else if (!update && rating != null && rating > 0) {
          DateTime lastUpdated = DateTime.now();
          Review review = Review(
            userId: widget.user.userId,
            createdOn: lastUpdated,
            itemId: widget.itemId,
            rating: rating,
            reviewDescription: commentController?.text,
            reviewedBy: widget.user.fullName,
            lastUpdated: lastUpdated,
          );

          Firestore.instance
              .collection('reviews')
              .document(widget.itemId)
              .setData(
            {"${widget.user.userId}": review.toMap()},
            merge: true,
          );
          Navigator.of(context).pop(true);
        } else if (rating != null && rating > 0) {
          myReview.lastUpdated = DateTime.now();
          myReview.reviewDescription = commentController?.text;
          myReview.rating = rating;
          Firestore.instance
              .collection('reviews')
              .document(widget.itemId)
              .setData(
            {widget.user.userId: myReview.toMap()},
            merge: true,
          );
          Navigator.of(context).pop(true);
        } else {
          Navigator.of(context).pop(false);
        }
      },
    );
  }
}

class _StarWidget extends StatefulWidget {
  final rating;
  final bool update;
  static GlobalKey<_StarWidgetState> _key = GlobalKey<_StarWidgetState>();
  _StarWidget({
    this.rating,
    this.update = false,
  }) : super(key: _key);

  @override
  State<StatefulWidget> createState() {
    return _StarWidgetState(rating);
  }
}

class _StarWidgetState extends State<_StarWidget> {
  double rating;
  _StarWidgetState(this.rating);

  @override
  void dispose() {
    super.dispose();
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
            rating != null ? '${rating.toStringAsFixed(1)}' : "0.0",
            style: Theme.of(context).textTheme.title,
          ),
        ),
        SizedBox(
          width: 20,
        ),
        StarRating(
            rating: rating ?? 0.0,
            size: 30,
            starCount: 5,
            onRatingChanged: (value) {
              setState(() => rating = value);
              _ActionButton._key.currentState.rebuild();
            }),
      ],
    );
  }
}
