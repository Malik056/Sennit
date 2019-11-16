import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sennit/main.dart';

class UserHomeRoute extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Home'),
        centerTitle: true,
      ),
      body: UserHomeBody(MediaQuery.of(context).size),
      backgroundColor: Colors.white,
    );
  }
}

class UserHomeBody extends StatefulWidget {
  final topLeftBorder = Radius.circular(20);
  final topRightBorder = Radius.circular(20);
  final Size screenWidth;

  UserHomeBody(this.screenWidth);

  @override
  State<StatefulWidget> createState() {
    return UserHomeState();
  }
}

class UserHomeState extends State<UserHomeBody> {
  bool sendItClickable = true;
  bool recieveItClickable = true;
  double defaultSize;
  double currentSizeSendIt;
  double currentSizeRecieveIt;

  @override
  void initState() {
    defaultSize = widget.screenWidth.width * 0.4;
    currentSizeRecieveIt = defaultSize;
    currentSizeSendIt = defaultSize;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Column(
          children: [
            Spacer(),
            Icon(
              FontAwesomeIcons.userCog,
              // 'assets/images/logo.png',
              size: widget.screenWidth.width * 0.3,
              color: Theme.of(context).accentColor,
            ),
            Spacer(
              flex: 2,
            ),
            Text(
              'Choose a Service',
              style: Theme.of(context).textTheme.headline,
            ),
            Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  child: Container(
                    width: MediaQuery.of(context).size.width / 2,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedContainer(
                          width: currentSizeRecieveIt,
                          duration: Duration(milliseconds: 100),
                          child: Card(
                            // onPressed: (){},
                            elevation: 10,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                  topLeft: widget.topLeftBorder,
                                  topRight: widget.topRightBorder),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.only(
                                topLeft: widget.topLeftBorder,
                                topRight: widget.topRightBorder,
                              ),
                              child: Container(
                                color: Colors.white,
                                padding: EdgeInsets.all(5),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    ClipRRect(
                                      borderRadius: BorderRadius.only(
                                          topLeft: widget.topLeftBorder,
                                          topRight: widget.topRightBorder),
                                      child: Container(
                                        padding: EdgeInsets.only(
                                            top: 10, bottom: 10),
                                        color:
                                            Color.fromARGB(255, 235, 235, 235),

                                        // child: Icon(
                                        //   FontAwesomeIcons.shippingFast,
                                        //   color: Theme.of(context).accentColor,
                                        //   size: currentSizeRecieveIt-40,
                                        // ),

                                        child: Image.asset(
                                          'assets/images/delivery.png',
                                          color: Theme.of(context).accentColor,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: <Widget>[
                                          Padding(
                                            padding: EdgeInsets.only(
                                                top: 10, bottom: 10),
                                            child: Text(
                                              'Recieve It',
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: Theme.of(context)
                                                    .accentColor,
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  onTapDown: (tap) {
                    setState(() {
                      currentSizeRecieveIt = defaultSize - 20;
                    });
                  },
                  onTapUp: (tap) {
                    setState(() {
                      currentSizeRecieveIt = defaultSize;
                    });
                  },
                  onTapCancel: () {
                    setState(() {
                      currentSizeRecieveIt = defaultSize;
                    });
                  },
                  onTap: () {},
                ),
                GestureDetector(
                  child: Container(
                    width: MediaQuery.of(context).size.width / 2,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedContainer(
                          width: currentSizeSendIt,
                          duration: Duration(milliseconds: 100),
                          child: Card(
                            elevation: 10,
                            // padding: EdgeInsets.all(0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                  topLeft: widget.topLeftBorder,
                                  topRight: widget.topRightBorder),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.only(
                                topLeft: widget.topLeftBorder,
                                topRight: widget.topRightBorder,
                              ),
                              child: Container(
                                color: Colors.white,
                                padding: EdgeInsets.all(5),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    ClipRRect(
                                      borderRadius: BorderRadius.only(
                                          topLeft: widget.topLeftBorder,
                                          topRight: widget.topRightBorder),
                                      child: Container(
                                        padding: EdgeInsets.only(
                                            top: 10, bottom: 10),
                                        color:
                                            Color.fromARGB(255, 235, 235, 235),
                                        child: Image.asset(
                                          'assets/images/delivery.png',
                                          color: Theme.of(context).accentColor,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: <Widget>[
                                          Padding(
                                            padding: EdgeInsets.only(
                                                top: 10, bottom: 10),
                                            child: Text(
                                              'Sennit',
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: Theme.of(context)
                                                      .accentColor),
                                            ),
                                          )
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  onTapDown: (TapDownDetails tap) {
                    setState(() {
                      currentSizeSendIt = defaultSize - 20;
                    });
                  },
                  onTapUp: (tap) {
                    setState(() {
                      currentSizeSendIt = defaultSize;
                    });
                  },
                  onTapCancel: () {
                    setState(() {
                      currentSizeSendIt = defaultSize;
                    });
                  },
                  onTap: () {
                    // setState(() {
                    //   currentSizeSendIt = defaultSize - 20;
                    // });
                    // Future.delayed(Duration(milliseconds: 100))
                    //     .then((a) {
                    //   setState(() {
                    //     currentSizeSendIt = defaultSize;
                    //   });
                    // });
                    Navigator.of(context).pushNamed(MyApp.selectFromAddress);
                  },
                ),
              ],
            ),
            Spacer(
              flex: 5,
            ),
          ],
        ),
      ),
    );
  }
}
