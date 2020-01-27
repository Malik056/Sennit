import 'package:argon_buttons_flutter/argon_buttons_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sennit/main.dart';

enum UserType {
  driver,
  user,
}


class ForgotPasswordRoute extends StatelessWidget {
  static UserType userType;
  ForgotPasswordRoute({@required UserType userType}) {
    ForgotPasswordRoute.userType = userType;
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text('Password Reset'),
      ),
      body: _ForgotPasswordBody(),
      
    );
  }
}

class _ForgotPasswordBody extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ForgotPasswordBodyState();
  }
}

class _ForgotPasswordBodyState extends State<_ForgotPasswordBody> {
  double interGroupGap = 40;
  double intraGroupGap = 30;

  static TextEditingController _emailController;

  bool textFieldEnable = true;

  _ForgotPasswordBodyState() {
    _emailController = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
  }

  String codeValue;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 10,
        right: 10,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          BulletPointWithNumber(
            number: 1,
            message: 'Please Enter your Email',
          ),
          SizedBox(
            height: intraGroupGap,
          ),
          TextField(
            controller: _emailController,
            decoration: InputDecoration(hintText: 'Email'),
          ),
          SizedBox(
            height: intraGroupGap,
          ),
          Center(
            child: TimerButton(),
          ),
          SizedBox(
            height: interGroupGap,
          ),
          BulletPointWithNumber(
            number: 2,
            message: 'Check your Email!',
          ),
          SizedBox(
            height: interGroupGap,
          ),
          Center(
            child: RaisedButton(
              child: Text(
                'Done',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
          // SizedBox(
          //   height: interGroupGap,
          // ),
          // BulletPointWithNumber(
          //   number: 3,
          //   message: 'Enter your Password Reset Code below: ',
          // ),
          // SizedBox(
          //   height: intraGroupGap,
          // ),
          // PinCodeTextField(
          //   enabled: textFieldEnable,
          //   length: 6,
          //   obsecureText: false,
          //   animationType: AnimationType.fade,
          //   shape: PinCodeFieldShape.box,
          //   animationDuration: Duration(milliseconds: 300),
          //   borderRadius: BorderRadius.circular(5),
          //   selectedColor: Theme.of(context).primaryColor,
          //   fieldHeight: 40,
          //   fieldWidth: 35,
          //   onChanged: (value) {
          //     codeValue = value;
          //     setState(() {});
          //   },
          // ),
          // SizedBox(
          //   height: intraGroupGap,
          // ),
          // Center(
          //   child: RaisedButton(
          //     child: Text('Verify'),
          //     onPressed: (){

          //     },
          //   ),
          // ),
        ],
      ),
    );
  }
}

class BulletPointWithNumber extends StatelessWidget {
  final int number;
  final String message;

  const BulletPointWithNumber({Key key, this.number, this.message})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          height: 20,
          width: 20,
          // padding: EdgeInsets.all(4),
          decoration: ShapeDecoration(
            color: Theme.of(context).primaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          child: Center(
            child: Text(
              '$number',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ),
        ),
        SizedBox(
          width: 5,
        ),
        Text(
          '$message',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
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
      height: 40,
      disabledElevation: 0,
      width: MediaQuery.of(context).size.width * 0.45,
      minWidth: MediaQuery.of(context).size.width * 0.30,
      color: Colors.white,
      elevation: 10,
      borderRadius: 5.0,
      child: Text(
        "Send Code",
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
          String email = _ForgotPasswordBodyState._emailController.text;
          if (email == null || email.isEmpty) {
            Utils.showSnackBarError(context, "Please Enter an Email Address");
            return;
          } else if (!Utils.isEmailCorrect(email)) {
            Utils.showSnackBarError(context, "Invalid Email Address");
            return;
          }
          startTimer(30);
          if (ForgotPasswordRoute.userType == UserType.user) {
            QuerySnapshot snapshot = await Firestore.instance
                .collection("users")
                .where('email',
                    isEqualTo: _ForgotPasswordBodyState._emailController.text)
                .getDocuments();
            if (snapshot.documents.length == 0) {
              Utils.showSnackBarError(
                context,
                "This email address is not associated with any user account",
              );
              startTimer(1);
              return;
            } else {
              await sendForgotPasswordEmail();
            }
          } else {
            QuerySnapshot snapshot = await Firestore.instance
                .collection("drivers")
                .where(
                  'email',
                  isEqualTo: _ForgotPasswordBodyState._emailController.text,
                )
                .getDocuments();
            if (snapshot.documents.length == 0) {
              Utils.showSnackBarError(
                context,
                "This email address is not associated with any driver's account",
              );
              startTimer(1);
              return;
            } else {
              await sendForgotPasswordEmail();
            }
          }
        }
      },
    );
  }

  sendForgotPasswordEmail() async {
    await FirebaseAuth.instance.sendPasswordResetEmail(
      email: _ForgotPasswordBodyState._emailController.text,
    );
    Utils.showSnackBarSuccess(context, "Email Send!");
  }
}
