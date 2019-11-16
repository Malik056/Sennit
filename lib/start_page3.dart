import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class StartPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).accentColor,
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              color: Colors.white,
              child: FittedBox(
                fit: BoxFit.fill,
                child: Opacity(
                  opacity: 0.5,
                  child: Image.asset('assets/images/truck.jpeg'),
                ),
              ),
            ),
            StartPageBody(),
          ],
        ),
      ),
    );
  }
}

class StartPageBody extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _StartPageBodyState();
  }
}

class _StartPageBodyState extends State<StartPageBody> {
  double screenWidth;
  double screenHeight;
  Color fbColor = Color.fromARGB(0xff, 0x3b, 0x59, 0x98);
  Color fbHeighlightedColor = Color.fromARGB(0xff, 0x3b, 0x59, 0x98);
  Color defaultColor = Color.fromARGB(0xff, 0x5d, 0x5d, 0x5d);

  Color instaColor = Color.fromARGB(0xff, 0xCC, 0x55, 0x00);
  Color instaHeighlightedColor = Color.fromARGB(0xff, 0xcc, 0x55, 0x00);
  Color defaultHeighlightedColor = Color.fromARGB(0xff, 0x5d, 0x5d, 0x5d);

  double btnPaddingTop;
  double btnPaddingBottom;
  double btnPaddingLeft;
  double btnPaddingRight;

  @override
  void initState() {
    super.initState();
    btnPaddingTop = 10;
    btnPaddingBottom = 10;
    btnPaddingLeft = 20;
    btnPaddingRight = 25;
  }

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
    return NestedScrollView(
      headerSliverBuilder: (a, b) {
        return <Widget>[
          SliverAppBar(
            // backgroundColor: Theme.of(context).accentColor,
            // title: Text('Think Courier'),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: Colors.white,
                child: Image.asset(
                'assets/images/logo.jpg',
                fit: BoxFit.fitWidth,
              ),),
              title: LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraint) {
                return Opacity(
                  opacity: constraint.biggest.height <= 100 ? 1.0 : 0,
                  child: Text(
                    'Think Courier',
                    style: Theme.of(context).textTheme.title,
                  ),
                );
              }),
              centerTitle: true,
              titlePadding: EdgeInsets.only(left: 20, bottom: 10),
            ),
            expandedHeight: 300,
            pinned: true,
            floating: true,
          ),
        ];
      },
      body: ListView(
        children: <Widget>[
          Center(
            child: Column(
              // mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                // Image.asset('assets/images/logo.jpg'),
                Container(
                  width: screenWidth,
                  padding: EdgeInsets.all(10),
                  margin: EdgeInsets.only(top: 60),
                  color: Colors.white,
                  child: Column(
                    children: [
                      Text(
                        '\nAbout Us',
                        style: Theme.of(context).textTheme.headline,
                      ),
                      Text(
                        '\n Think Couriers is a unique business platform whereby both drivers and clients are able to deliver or have goods delivered respectively, with no signup costs. Sign Up now to have your goods delivered immediately!\n\n',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.body1,
                      ),
                    ],
                  ),
                ),
                Container(
                  width: screenWidth,
                  padding: EdgeInsets.only(bottom: 20),
                  margin: EdgeInsets.only(top: 20),
                  color: Colors.white,
                  child: Column(
                    children: [
                      Text(
                        '\nJoin Us',
                        style: Theme.of(context).textTheme.headline,
                      ),
                      ButtonBar(
                        alignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          FlatButton(
                            padding: EdgeInsets.only(
                                left: btnPaddingLeft,
                                right: btnPaddingRight,
                                top: btnPaddingTop,
                                bottom: btnPaddingBottom),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(
                                  Radius.elliptical(1000, 1000)),
                              side: BorderSide(color: fbColor, width: 3),
                            ),
                            child: Row(
                              children: <Widget>[
                                Icon(
                                  FontAwesomeIcons.facebookF,
                                  color: fbHeighlightedColor,
                                ),
                                Text(
                                  '\tFacebook',
                                  style: TextStyle(color: fbHeighlightedColor),
                                ),
                              ],
                            ),
                            highlightColor: fbColor,
                            onHighlightChanged: (isHeighlighted) {
                              if (isHeighlighted) {
                                fbHeighlightedColor = Colors.white;
                              } else {
                                fbHeighlightedColor = fbColor;
                              }
                              setState(() {});
                            },
                            onPressed: () {},
                          ),
                          FlatButton(
                            padding: EdgeInsets.only(
                                left: btnPaddingLeft,
                                right: btnPaddingRight,
                                top: btnPaddingTop,
                                bottom: btnPaddingBottom),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(
                                  Radius.elliptical(1000, 1000)),
                              side: BorderSide(color: instaColor, width: 3),
                            ),
                            child: Row(
                              children: <Widget>[
                                Icon(
                                  FontAwesomeIcons.instagram,
                                  color: instaHeighlightedColor,
                                ),
                                Text(
                                  '\tInstagram',
                                  style:
                                      TextStyle(color: instaHeighlightedColor),
                                ),
                              ],
                            ),
                            highlightColor: instaColor,
                            onHighlightChanged: (isHeighlighted) {
                              if (isHeighlighted) {
                                instaHeighlightedColor = Colors.white;
                              } else {
                                instaHeighlightedColor = instaColor;
                              }
                              setState(() {});
                            },
                            onPressed: () {},
                          )
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  width: screenWidth,
                  padding: EdgeInsets.only(bottom: 20),
                  margin: EdgeInsets.only(top: 20),
                  color: Colors.white,
                  child: Column(
                    children: [
                      Text(
                        '\nSupport ',
                        style: Theme.of(context).textTheme.headline,
                      ),
                      ButtonBar(
                        alignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          FlatButton(
                            padding: EdgeInsets.only(
                                left: btnPaddingLeft,
                                right: btnPaddingRight - 5,
                                top: btnPaddingTop,
                                bottom: btnPaddingBottom),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(
                                  Radius.elliptical(1000, 1000)),
                              side: BorderSide(color: defaultColor, width: 3),
                            ),
                            child: Row(
                              children: <Widget>[
                                Icon(
                                  FontAwesomeIcons.envelopeOpen,
                                  color: defaultHeighlightedColor,
                                ),
                                Text(
                                  '\t User Support',
                                  style: TextStyle(
                                      color: defaultHeighlightedColor),
                                ),
                              ],
                            ),
                            highlightColor: defaultColor,
                            onHighlightChanged: (isHeighlighted) {
                              if (isHeighlighted) {
                                defaultHeighlightedColor = Colors.white;
                              } else {
                                defaultHeighlightedColor = defaultColor;
                              }
                              setState(() {});
                            },
                            onPressed: () {},
                          ),
                          FlatButton(
                            padding: EdgeInsets.only(
                                left: btnPaddingLeft,
                                right: btnPaddingRight - 5,
                                top: btnPaddingTop,
                                bottom: btnPaddingBottom),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(
                                  Radius.elliptical(1000, 1000)),
                              side: BorderSide(color: defaultColor, width: 3),
                            ),
                            child: Row(
                              children: <Widget>[
                                Icon(
                                  FontAwesomeIcons.instagram,
                                  color: defaultHeighlightedColor,
                                ),
                                Text(
                                  '\t Driver Support',
                                  style:
                                      TextStyle(color: defaultHeighlightedColor),
                                ),
                              ],
                            ),
                            highlightColor: defaultColor,
                            onHighlightChanged: (isHeighlighted) {
                              if (isHeighlighted) {
                                defaultHeighlightedColor = Colors.white;
                              } else {
                                defaultHeighlightedColor = defaultColor;
                              }
                              setState(() {});
                            },
                            onPressed: () {},
                          )
                        ],
                      ),
                      ButtonBar(
                        alignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          FlatButton(
                            padding: EdgeInsets.only(
                                left: btnPaddingLeft,
                                right: btnPaddingRight - 5,
                                top: btnPaddingTop,
                                bottom: btnPaddingBottom),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(
                                  Radius.elliptical(1000, 1000)),
                              side: BorderSide(color: defaultColor, width: 3),
                            ),
                            child: Row(
                              children: <Widget>[
                                Icon(
                                  FontAwesomeIcons.envelopeOpen,
                                  color: defaultHeighlightedColor,
                                ),
                                Text(
                                  '\t Account Support',
                                  style: TextStyle(
                                      color: defaultHeighlightedColor),
                                ),
                              ],
                            ),
                            highlightColor: defaultColor,
                            onHighlightChanged: (isHeighlighted) {
                              if (isHeighlighted) {
                                defaultHeighlightedColor = Colors.white;
                              } else {
                                defaultHeighlightedColor = defaultColor;
                              }
                              setState(() {});
                            },
                            onPressed: () {},
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  alignment: Alignment.bottomCenter,
                  color: Colors.white,
                  margin: EdgeInsets.only(top: 60),
                  width: MediaQuery.of(context).size.width,
                  child: ListTile(
                    leading: Icon(
                      FontAwesomeIcons.userAlt,
                      color: Theme.of(context).primaryColor,
                    ),
                    title: Text(
                      'I am a User',
                      style: Theme.of(context).textTheme.subhead,
                    ),
                    trailing: Icon(
                      Icons.navigate_next,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
                Container(
                  alignment: Alignment.bottomCenter,
                  color: Colors.white,
                  margin: EdgeInsets.only(top: 10),
                  width: MediaQuery.of(context).size.width,
                  child: ListTile(
                    leading: Icon(
                      FontAwesomeIcons.car,
                      color: Theme.of(context).primaryColor,
                    ),
                    title: Text(
                      'I am a Driver',
                      style: Theme.of(context).textTheme.subhead,
                    ),
                    trailing: Icon(
                      Icons.navigate_next,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
