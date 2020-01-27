import 'package:argon_buttons_flutter/argon_buttons_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../main.dart';

class VerifyEmailRoute extends StatelessWidget {
  VerifyEmailRoute({BuildContext context}) {
    // FirebaseAuth.instance.currentUser().then((user) async {
    //   bool done = false;
    //   while (!done) {
    //     await Future.delayed(Duration(seconds: 4), () {
    //       print('inside');
    //       if (user.isEmailVerified) {
    //         Navigator.popAndPushNamed(context, MyApp.userHome);
    //         done = true;
    //       }
    //     });
    //   }
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Verify Email'),
        centerTitle: true,
        actions: <Widget>[
          FlatButton(
            child: Text('SignOut'),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              } else {
                Navigator.pushReplacementNamed(context, MyApp.startPage);
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'Please Click the email verification link sent to you on your email!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(
                height: 30,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TimerButton(),
                  SizedBox(
                    width: 10,
                  ),
                  RaisedButton(
                    elevation: 10,
                    child: Text(
                      'Done',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    onPressed: () async {
                      Utils.showLoadingDialog(context);
                      await (await FirebaseAuth.instance.currentUser())
                          .reload();

                      if ((await FirebaseAuth.instance.currentUser())
                          .isEmailVerified) {
                        if (Session.data['user'] == null) {
                          Navigator.popAndPushNamed(context, MyApp.driverHome);
                        } else {
                          Navigator.popAndPushNamed(context, MyApp.userHome);
                        }
                        print('Email Verified');
                      } else {
                        Navigator.pop(context);
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TimerButton extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _TimerButtonState();
  }
}

class _TimerButtonState extends State<TimerButton> {
  @override
  Widget build(BuildContext context) {
    return ArgonTimerButton(
      // Optional
      height: 38,
      disabledElevation: 0,
      width: MediaQuery.of(context).size.width * 0.45,
      minWidth: MediaQuery.of(context).size.width * 0.30,
      color: Colors.white,
      elevation: 10,
      borderRadius: 5.0,
      child: Text(
        "Resend Email",
        style: TextStyle(
          color: Colors.black,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
      loader: (timeLeft) {
        return Container(
          width: MediaQuery.of(context).size.width * 0.45,
          child: Center(
            child: Text(
              "Wait | $timeLeft",
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        );
      },
      roundLoadingShape: false,
      onTap: (startTimer, btnState) async {
        if (btnState == ButtonState.Idle) {
          (await FirebaseAuth.instance.currentUser()).sendEmailVerification();
          startTimer(30);
        }
      },
    );
  }
}
