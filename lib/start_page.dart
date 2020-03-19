import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sennit/main.dart';
import 'package:sennit/my_widgets/pdf_viewer.dart';
import 'package:sennit/partner_store/login.dart';
import 'package:sennit/user/receiveit.dart';

class StartPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return StartPageState();
  }
}

class StartPageState extends State<StartPage>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  bool _willExit = false;
  TabController _tabController;
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    print('stateChanged');
    if (state == AppLifecycleState.resumed) {
      // DatabaseHelper.getDatabase().close();
      try {
        setState(() {});
      } catch (_) {}
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // translate.addStatusListener((status) {
    //   if (status == AnimationStatus.completed) {
    //     controller.repeat(reverse: true);
    //   }
    // });
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_tabController?.index != 0) {
          _tabController?.animateTo(0);
          return false;
        }
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
      child: Column(
        children: <Widget>[
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                MyStartPage(
                  onExplorePressed: () {
                    _tabController.animateTo(1);
                  },
                ),
                ReceiveItRoute(
                  tabController: _tabController,
                  demo: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MyStartPage extends StatefulWidget {
  final Function onExplorePressed;
  MyStartPage({
    Key key,
    @required this.onExplorePressed,
  }) : super(key: key);

  @override
  MyStartPageState createState() => MyStartPageState();
}

class MyStartPageState extends State<MyStartPage>
    with SingleTickerProviderStateMixin {
  AnimationController controller;
  Animation<int> translate;
  bool tutorialOn = true;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
        duration: const Duration(milliseconds: 400), vsync: this);
    final Animation curve =
        CurvedAnimation(parent: controller, curve: Curves.easeOut);
    translate = IntTween(begin: 0, end: 20).animate(curve);
    translate.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
    // controller.repeat(reverse: true);
    // Future.delayed(Duration(seconds: 4)).then((_) {
    //   controller.dispose();
    //   tutorialOn = false;
    //   if (mounted) {
    //     setState(() {});
    //   }
    // });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget getStartPage(context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Sennit'),
        centerTitle: true,
        actions: <Widget>[
          // IconButton(
          //   padding: EdgeInsets.all(0),

          // icon:
          // InkWell(
          // child:
          IconButton(
            icon: Icon(Icons.explore, color: Theme.of(context).primaryColor),
            tooltip: 'Explore',
            onPressed: () {
              widget.onExplorePressed();
            },
          ),
          //   color: Theme.of(context).primaryColor,
          //   onPressed: () {
          //     widget.onExplorePressed();
          //   },
          // ),
          PopupMenuButton(
            itemBuilder: (context) {
              return [
                PopupMenuItem(
                  child: Text('Privacy Policy'),
                  value: 1,
                ),
              ];
            },
            onSelected: (value) {
              if (value == 1) {
                Navigator.push(context, MaterialPageRoute(builder: (ctx) {
                  return PDFViewerRoute();
                }));
              }
            },
          ),
        ],
      ),
      body: SafeArea(
          child: Column(
        children: <Widget>[
          // SizedBox(
          //   height: 10,
          // ),
          // SizedBox(
          //   width: MediaQuery.of(context).size.width,
          //   height: 40,
          //   child: Stack(
          //     children: <Widget>[
          //       // tutorialOn
          //       //     ? Positioned(
          //       //         right: controller.value * 20,
          //       //         child: Row(
          //       //           mainAxisSize: MainAxisSize.min,
          //       //           mainAxisAlignment: MainAxisAlignment.end,
          //       //           crossAxisAlignment: CrossAxisAlignment.end,
          //       //           children: <Widget>[
          //       //             Text(
          //       //               'Swipe Right to Explore  ',
          //       //               style: Theme.of(context).textTheme.title.copyWith(
          //       //                     fontWeight: FontWeight.normal,
          //       //                   ),
          //       //             ),
          //       //             Image.asset(
          //       //               'assets/images/right.png',
          //       //               width: MediaQuery.of(context).size.width * 0.08,
          //       //             ),
          //       //             SizedBox(
          //       //               width: 2,
          //       //             ),
          //       //           ],
          //       //         ),
          //       //       )
          //       //     : Opacity(opacity: 0),
          //     ],
          //   ),
          // ),
          Opacity(
            opacity: 0,
            child: Container(
              height: 30,
            ),
          ),
          Expanded(
            child: Image.asset(
              'assets/images/logo.png',
            ),
          ),
          // Expanded(
          //   child:
          Container(
            padding: EdgeInsets.only(
              left: 10,
              right: 10,
            ),
            child: Text.rich(
              TextSpan(
                text: 'About Us\n',
                style: MediaQuery.of(context).size.height <
                        800 / MediaQuery.of(context).devicePixelRatio
                    ? Theme.of(context).textTheme.subhead.copyWith(fontSize: 14)
                    : Theme.of(context).textTheme.headline,
                children: [
                  TextSpan(
                    text:
                        '\nSennit is a unique business platform whereby both drivers and clients are able to deliver or have goods delivered respectively, with no signup costs. Sign Up now to have your goods delivered immediately!.',
                    style: MediaQuery.of(context).size.height <
                            800 / MediaQuery.of(context).devicePixelRatio
                        ? Theme.of(context)
                            .textTheme
                            .body1
                            .copyWith(fontSize: 12)
                        : Theme.of(context).textTheme.body1,
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
          ),
          // ),
          Spacer(
            flex: 1,
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            child: RaisedButton(
              color: Colors.white,
              child: ListTile(
                leading: Icon(
                  FontAwesomeIcons.storeAlt,
                  color: Theme.of(context).accentColor,
                ),
                title: Text(
                  'I am a Partner Store',
                  style: Theme.of(context).textTheme.subhead,
                ),
                trailing: Icon(
                  Icons.navigate_next,
                  color: Theme.of(context).accentColor,
                ),
              ),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => PartnerStoreSignInRoute(),
                  ),
                );
              },
            ),
          ),
          // Spacer(),
          SizedBox(
            height: 10,
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            child: RaisedButton(
              color: Colors.white,
              child: ListTile(
                leading: Icon(
                  FontAwesomeIcons.userAlt,
                  color: Theme.of(context).accentColor,
                ),
                title: Text(
                  'I am a User',
                  style: Theme.of(context).textTheme.subhead,
                ),
                trailing: Icon(
                  Icons.navigate_next,
                  color: Theme.of(context).accentColor,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pushNamed(MyApp.userStartPage);
              },
            ),
          ),

          Container(
            margin: EdgeInsets.only(top: 10, bottom: 10),
            width: MediaQuery.of(context).size.width,
            child: RaisedButton(
              color: Colors.white,
              child: ListTile(
                leading: Icon(
                  FontAwesomeIcons.car,
                  color: Theme.of(context).accentColor,
                ),
                title: Text(
                  'I am a Driver',
                  style: Theme.of(context).textTheme.subhead,
                ),
                trailing: Icon(
                  Icons.navigate_next,
                  color: Theme.of(context).accentColor,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pushNamed(MyApp.driverStartPage);
              },
            ),
          ),
        ],
      )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: getStartPage(context),
    );
  }
}
