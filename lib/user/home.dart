import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sennit/main.dart';
import 'package:sennit/user/recieveIt.dart';

class UserHomeRoute extends StatelessWidget {
  static bool _willExit = false;
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_willExit) {
          SystemNavigator.pop();
        } else {
          BotToast.showText(text: 'Press Again to Exit');
          _willExit = true;
          Future.delayed(Duration(seconds: 3)).then((value) {
            _willExit = false;
          });
        }
        return false;
      },
          child: Scaffold(
        appBar: AppBar(
          title: Text('User Home'),
          centerTitle: true,
        ),
        body: UserHomeBody(MediaQuery.of(context).size),
        backgroundColor: Colors.white,
      ),
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
                                          ),
                                          SizedBox(
                                            width: 2,
                                          ),
                                          // Tooltip(
                                          //   child: IconButton(
                                          //     icon: Icon(Icons.help),
                                          //     onPressed: () {},
                                          //   ),
                                          //   message:
                                          //       "This Feature Allow user to buy things from our partner stores.",
                                          // ),
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
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return ReceiveItRoute();
                      }));
                      currentSizeRecieveIt = defaultSize;
                    });
                  },
                  onTapCancel: () {
                    setState(() {
                      currentSizeRecieveIt = defaultSize;
                    });
                  },
                  onTap: () {},
                  onLongPress: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        fullscreenDialog: false,
                        maintainState: true,
                        builder: (context) {
                          return HelpScreenRecieveIt();
                        },
                      ),
                    );
                  },
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
                    Navigator.of(context).pushNamed(MyApp.selectFromAddress);
                  },
                  onLongPress: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        fullscreenDialog: false,
                        maintainState: true,
                        builder: (context) {
                          return HelpScreenSennit();
                        }));
                  },
                ),
              ],
            ),
            Spacer(
              flex: 2,
            ),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Hold down a button to see Help',
                    style: Theme.of(context).textTheme.subhead,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
            Spacer(
              flex: 2,
            ),
          ],
        ),
      ),
    );
  }
}

class HelpScreenSennit extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Help'),
      ),
      body: SafeArea(
        minimum: EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              height: 20,
            ),
            Center(
              child: Icon(
                Icons.help,
                size: 80,
              ),
            ),
            SizedBox(
              height: 30,
            ),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'This Feature helps you to send anything, anywhere to anyone with no effort. We are responsible for picking the package from your door and delivering it to your friend\'s door. Just Follow the Instruction below and Leave everything to Us.',
                    style: Theme.of(context).textTheme.subtitle,
                    textAlign: TextAlign.justify,
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 15,
            ),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Instructions',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headline,
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 10,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  padding: EdgeInsets.all(6),
                  decoration: ShapeDecoration(
                    color: Theme.of(context).accentColor,
                    shape: CircleBorder(
                      side: BorderSide(
                        style: BorderStyle.solid,
                        color: Theme.of(context).accentColor,
                      ),
                    ),
                  ),
                  child: Text(
                    '1',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  // color: Theme.of(context).accentColor,
                ),
                SizedBox(
                  width: 6,
                ),
                Text(
                  'Pick a pickup point',
                  style: Theme.of(context).textTheme.subhead,
                ),
              ],
            ),
            SizedBox(
              height: 5,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  padding: EdgeInsets.all(6),
                  decoration: ShapeDecoration(
                    color: Theme.of(context).accentColor,
                    shape: CircleBorder(
                      side: BorderSide(
                        style: BorderStyle.solid,
                        color: Theme.of(context).accentColor,
                      ),
                    ),
                  ),
                  child: Text(
                    '2',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  // color: Theme.of(context).accentColor,
                ),
                SizedBox(
                  width: 6,
                ),
                Text(
                  'Provide delivery Location',
                  style: Theme.of(context).textTheme.subhead,
                ),
              ],
            ),
            SizedBox(
              height: 5,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  padding: EdgeInsets.all(6),
                  decoration: ShapeDecoration(
                    color: Theme.of(context).accentColor,
                    shape: CircleBorder(
                      side: BorderSide(
                        style: BorderStyle.solid,
                        color: Theme.of(context).accentColor,
                      ),
                    ),
                  ),
                  child: Text(
                    '3',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  // color: Theme.of(context).accentColor,
                ),
                SizedBox(
                  width: 6,
                ),
                Text(
                  'Provide Details of your package',
                  style: Theme.of(context).textTheme.subhead,
                ),
              ],
            ),
            SizedBox(
              height: 5,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  padding: EdgeInsets.all(6),
                  decoration: ShapeDecoration(
                    color: Theme.of(context).accentColor,
                    shape: CircleBorder(
                      side: BorderSide(
                        style: BorderStyle.solid,
                        color: Theme.of(context).accentColor,
                      ),
                    ),
                  ),
                  child: Text(
                    '4',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  // color: Theme.of(context).accentColor,
                ),
                SizedBox(
                  width: 6,
                ),
                Text(
                  'Select Payment Method',
                  style: Theme.of(context).textTheme.subhead,
                ),
              ],
            ),
            SizedBox(
              height: 5,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  padding: EdgeInsets.all(6),
                  decoration: ShapeDecoration(
                    color: Theme.of(context).accentColor,
                    shape: CircleBorder(
                      side: BorderSide(
                        style: BorderStyle.solid,
                        color: Theme.of(context).accentColor,
                      ),
                    ),
                  ),
                  child: Text(
                    '5',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  // color: Theme.of(context).accentColor,
                ),
                SizedBox(
                  width: 6,
                ),
                Text(
                  'Click Done',
                  style: Theme.of(context).textTheme.subhead,
                ),
              ],
            ),
            SizedBox(height: 30),
            Text(
              'Our Delivery Guy will be at your door step in a flash.',
              style: Theme.of(context).textTheme.subtitle,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class HelpScreenRecieveIt extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Help'),
      ),
      body: SafeArea(
        minimum: EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              height: 20,
            ),
            Center(
              child: Icon(
                Icons.help,
                size: 80,
              ),
            ),
            SizedBox(
              height: 30,
            ),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'This Feature helps you to order anything, anywhere from our partner stores. We are responsible for delivering the product to your door step. Just Follow the Instruction below and Leave everything to Us.',
                    style: Theme.of(context).textTheme.subtitle,
                    textAlign: TextAlign.justify,
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 15,
            ),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Instructions',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headline,
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 10,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  padding: EdgeInsets.all(6),
                  decoration: ShapeDecoration(
                    color: Theme.of(context).accentColor,
                    shape: CircleBorder(
                      side: BorderSide(
                        style: BorderStyle.solid,
                        color: Theme.of(context).accentColor,
                      ),
                    ),
                  ),
                  child: Text(
                    '1',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  // color: Theme.of(context).accentColor,
                ),
                SizedBox(
                  width: 6,
                ),
                Expanded(
                  child: Text(
                    'Select a product from any of our partner store',
                    style: Theme.of(context).textTheme.subhead,
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 5,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  padding: EdgeInsets.all(6),
                  decoration: ShapeDecoration(
                    color: Theme.of(context).accentColor,
                    shape: CircleBorder(
                      side: BorderSide(
                        style: BorderStyle.solid,
                        color: Theme.of(context).accentColor,
                      ),
                    ),
                  ),
                  child: Text(
                    '2',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  // color: Theme.of(context).accentColor,
                ),
                SizedBox(
                  width: 6,
                ),
                Text(
                  'Select the product quantity',
                  style: Theme.of(context).textTheme.subhead,
                ),
              ],
            ),
            SizedBox(
              height: 5,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  padding: EdgeInsets.all(6),
                  decoration: ShapeDecoration(
                    color: Theme.of(context).accentColor,
                    shape: CircleBorder(
                      side: BorderSide(
                        style: BorderStyle.solid,
                        color: Theme.of(context).accentColor,
                      ),
                    ),
                  ),
                  child: Text(
                    '3',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  // color: Theme.of(context).accentColor,
                ),
                SizedBox(
                  width: 6,
                ),
                Text(
                  'Enter the delivery location',
                  style: Theme.of(context).textTheme.subhead,
                ),
              ],
            ),
            SizedBox(
              height: 5,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  padding: EdgeInsets.all(6),
                  decoration: ShapeDecoration(
                    color: Theme.of(context).accentColor,
                    shape: CircleBorder(
                      side: BorderSide(
                        style: BorderStyle.solid,
                        color: Theme.of(context).accentColor,
                      ),
                    ),
                  ),
                  child: Text(
                    '4',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  // color: Theme.of(context).accentColor,
                ),
                SizedBox(
                  width: 6,
                ),
                Text(
                  'Select Payment Method',
                  style: Theme.of(context).textTheme.subhead,
                ),
              ],
            ),
            SizedBox(
              height: 5,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  padding: EdgeInsets.all(6),
                  decoration: ShapeDecoration(
                    color: Theme.of(context).accentColor,
                    shape: CircleBorder(
                      side: BorderSide(
                        style: BorderStyle.solid,
                        color: Theme.of(context).accentColor,
                      ),
                    ),
                  ),
                  child: Text(
                    '5',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  // color: Theme.of(context).accentColor,
                ),
                SizedBox(
                  width: 6,
                ),
                Text(
                  'Click Done',
                  style: Theme.of(context).textTheme.subhead,
                ),
              ],
            ),
            SizedBox(height: 30),
            Text(
              'Our Delivery Guy will be at your door step in a flash.',
              style: Theme.of(context).textTheme.subtitle,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}