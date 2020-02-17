import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_map_location_picker/google_map_location_picker.dart';
import 'package:intl/intl.dart';
// import 'package:place_picker/place_picker.dart';
import 'package:sennit/database/mydatabase.dart';
import 'package:sennit/main.dart';
import 'package:sennit/models/models.dart';
import 'package:sennit/my_widgets/verify_email_route.dart';
import 'package:sqflite/sqlite_api.dart';

class DriverSignUpRoute extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Navigator.popAndPushNamed(context, MyApp.driverStartPage);
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Driver Sign Up'),
          centerTitle: true,
        ),
        body: SafeArea(
          child: DriverSignUpRouteBody(),
        ),
      ),
    );
  }
}

class DriverSignUpRouteBody extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return DriverSignUpRouteState();
  }

  // final _formKey = GlobalKey<FormState>();
  // final passwordController = TextEditingController();
}

class DriverSignUpRouteState extends State<DriverSignUpRouteBody> {
  Driver driver = Driver();
  Color defaultColor = Colors.white;
  Color defaultHeighlightedColor = Colors.white;
  Color defaultBtnBackgroundColor = Colors.white;
  double btnPaddingTop;
  double btnPaddingBottom;
  double btnPaddingLeft;
  double btnPaddingRight;
  String dateInitialText;
  bool dateSelected = false;

  Color dateOfBirthHeadingColor;
  Color dateOfBirthTextColor;

  String dateText;
  bool tapped = false;

  String address = "Not Selected";
  final _formKey = GlobalKey<FormState>();

  final passwordController = TextEditingController();

  bool pressed = false;

  Function onSignUpError;
  @override
  void initState() {
    btnPaddingTop = 10;
    btnPaddingBottom = 10;
    btnPaddingLeft = 20;
    btnPaddingRight = 25;
    dateInitialText = 'Tap to select';
    dateText = dateInitialText;
    dateOfBirthHeadingColor = Color.fromARGB(255, 57, 59, 82);
    dateOfBirthTextColor = Colors.white;

    onSignUpError = (error) {
      pressed = false;
      Navigator.pop(context);
      Utils.showSnackBarError(context, 'Email Address is already in use');
    };
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(left: 8, right: 8, bottom: 20),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    TextFormField(
                      maxLines: 1,
                      maxLength: 20,
                      decoration: InputDecoration(labelText: 'First Name'),
                      validator: (firstName) {
                        if (firstName.isEmpty) {
                          return "First Name can't be empty";
                        }
                        driver.firstName = firstName;
                        return null;
                      },
                      style: Theme.of(context).textTheme.body1,
                    ),
                    TextFormField(
                      maxLines: 1,
                      maxLength: 20,
                      decoration: InputDecoration(labelText: 'Last Name'),
                      validator: (lastName) {
                        if (lastName.isEmpty) {
                          return "Last Name can't be empty";
                        }
                        driver.lastName = lastName;
                        return null;
                      },
                      style: Theme.of(context).textTheme.body1,
                    ),
                    TextFormField(
                      keyboardType: TextInputType.emailAddress,
                      maxLines: 1,
                      decoration: InputDecoration(labelText: 'Email'),
                      validator: (email) {
                        if (email.isEmpty) {
                          return "Email can't be empty";
                        } else {
                          RegExp re = RegExp(
                              r'^[a-zA-Z0-9]+(.([a-zA-Z0-9])+)*[a-zA-Z0-9]+@[a-zA-Z]+(.[a-zA-Z]+)+$',
                              caseSensitive: false,
                              multiLine: false);
                          if (!re.hasMatch(email)) {
                            return 'Invalid Email Format';
                          }
                        }
                        driver.email = email;
                        return null;
                      },
                      style: Theme.of(context).textTheme.body1,
                    ),
                    TextFormField(
                      controller: passwordController,
                      obscureText: true,
                      maxLines: 1,
                      decoration: InputDecoration(labelText: 'Password'),
                      validator: (password) {
                        if (password.isEmpty) {
                          return "Please enter a password";
                        } else if (password.length < 6) {
                          return "Your password should be at least 6 characters long";
                        }
                        return null;
                      },
                      style: Theme.of(context).textTheme.body1,
                    ),
                    TextFormField(
                      obscureText: true,
                      maxLines: 1,
                      decoration: InputDecoration(labelText: 'Retype Password'),
                      validator: (rePassword) {
                        if (rePassword.isEmpty) {
                          return "Please confirm your password";
                        } else if (rePassword != passwordController.text) {
                          return "Password does not match";
                        }
                        return null;
                      },
                      style: Theme.of(context).textTheme.body1,
                    ),
                    Opacity(
                      opacity: 0,
                      child: Container(
                        height: 20,
                      ),
                    ), // Text(
                    //   'Date of Birth: ',
                    //   style: TextStyle(
                    //       color: Theme.of(context).primaryColor,
                    //       fontWeight: FontWeight.bold),
                    // ),
                    Text(
                      'Date of Birth: ',
                      style: TextStyle(color: dateOfBirthHeadingColor),
                      textAlign: TextAlign.start,
                    ),
                    Row(
                      children: [
                        RaisedButton(
                          padding: EdgeInsets.only(
                              left: btnPaddingLeft - 10,
                              right: btnPaddingRight,
                              top: btnPaddingTop - 5,
                              bottom: btnPaddingBottom - 5),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.all(Radius.elliptical(100, 100)),
                          ),
                          child: Row(
                            children: <Widget>[
                              Icon(
                                FontAwesomeIcons.calendarDay,
                                color: dateOfBirthTextColor,
                              ),
                              Text(
                                '   $dateText',
                                style: TextStyle(
                                  color: dateOfBirthTextColor,
                                ),
                              ),
                            ],
                          ),
                          onPressed: () async {
                            DateTime selectedDate = await showDatePicker(
                              firstDate: DateFormat("yyyy/MM/dd", "en_US")
                                  .parse("1950/01/01"),
                              lastDate: DateTime.now(),
                              context: context,
                              initialDate: DateFormat("dd-MMM-yyyy", "en_US")
                                  .parse(dateText == dateInitialText
                                      ? "01-Jan-2000"
                                      : dateText),
                            );
                            if (selectedDate != null) {
                              setState(() {
                                dateSelected = true;
                                dateOfBirthTextColor = Colors.white;
                                dateOfBirthHeadingColor =
                                    Theme.of(context).primaryColor;
                                dateText = DateFormat("dd-MMM-yyyy", "en_US")
                                    .format(selectedDate)
                                    .toString();
                                driver.dateOfBirth = selectedDate;
                              });
                            }
                          },
                        ),
                      ],
                    ),
                    Opacity(
                      opacity: dateSelected ? 0 : 1,
                      child: tapped
                          ? (dateSelected
                              ? () {
                                  setState(() {
                                    dateOfBirthHeadingColor =
                                        Theme.of(context).primaryColor;
                                    dateOfBirthTextColor = Colors.white;
                                  });
                                  return null;
                                }()
                              : () {
                                  setState(() {
                                    dateOfBirthHeadingColor = Colors.red;
                                    dateOfBirthTextColor = Colors.red;
                                  });
                                  return Padding(
                                    padding: EdgeInsets.only(top: 10),
                                    child: Text(
                                      'Please select your date of birth',
                                      style: TextStyle(
                                          color: Colors.red, fontSize: 12),
                                    ),
                                  );
                                }())
                          : null,
                    ),
                    TextFormField(
                      keyboardType: TextInputType.phone,
                      maxLines: 1,
                      maxLength: 10,
                      decoration: InputDecoration(
                        labelText: 'Phone Number',
                        helperText: 'e.g. 0812345678',
                      ),
                      validator: (cellNum) {
                        if (!cellNum.startsWith('0')) {
                          return "Number should start with 0. e.g. 0812345678";
                        }
                        if (cellNum.length == 0) {
                          return "Invalid Phone Number. Must contain 10 digits.";
                        }
                        if (cellNum.isEmpty) {
                          return "Please Enter your phone number";
                        }
                        driver.phoneNumber = cellNum;
                        return null;
                      },
                      style: Theme.of(context).textTheme.body1,
                    ),
                    // ListTile(
                    //   leading: Icon(
                    //     Icons.location_on,
                    //     color:
                    //         tapped ? Colors.red : Theme.of(context).accentColor,
                    //   ),
                    //   title: Text(
                    //     'Pick A location',
                    //     style: TextStyle(
                    //       color: tapped ? Colors.red : Colors.black,
                    //     ),
                    //   ),
                    //   onTap: () async {
                    //     LocationResult result =
                    //         await Utils.showPlacePicker(context);
                    //     if (result == null) {
                    //       if (user.homeLocationLatLng == null) {
                    //         Utils.showSnackBarError(
                    //           context,
                    //           'Please select a location',
                    //         );
                    //       }
                    //       return;
                    //     }
                    //     if (result != null) {
                    //       setState(() {
                    //         address = result.formattedAddress;
                    //       });
                    //     }
                    //     user.homeLocationAddress = address;
                    //     user.homeLocationLatLng = result.latLng;
                    //   },
                    // ),
                    ListTile(
                      leading: Icon(
                        Icons.location_on,
                        color: tapped && address == null
                            ? Colors.red
                            : Theme.of(context).accentColor,
                      ),
                      title: Text(
                        'Selected Location',
                        style: TextStyle(
                          color: tapped && address == "Not Selected"
                              ? Colors.red
                              : Theme.of(context).accentColor,
                        ),
                      ),
                      subtitle: Text(
                        address,
                      ),
                      onTap: () async {
                        LocationResult result = await Utils.showPlacePicker(
                          context,
                          initialLocation: driver.homeLocationLatLng,
                        );
                        if (result == null) {
                          if (driver.homeLocationLatLng == null) {
                            Utils.showSnackBarError(
                              context,
                              'Please select a location',
                            );
                          }
                          return;
                        }
                        if (result != null) {
                          setState(() {
                            address = result.address;
                            driver.homeLocationAddress = address;
                            driver.homeLocationLatLng = result.latLng;
                          });
                        }
                      },
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 10, bottom: 10),
                      child: Text.rich(
                        TextSpan(
                          text: 'By creating an account you agree to our ',
                          style: TextStyle(fontSize: 12),
                          children: [
                            TextSpan(
                              text: 'Terms & Privacy',
                              style: TextStyle(
                                color: Color.fromARGB(255, 0x1E, 0x90, 0xFF),
                                fontSize: 13,
                              ),
                            ),
                            TextSpan(text: '.'),
                          ],
                        ),
                      ),
                    ),
                    Center(
                      child: RaisedButton(
                        padding: EdgeInsets.only(
                          left: btnPaddingLeft + 30,
                          right: btnPaddingRight + 30,
                          top: btnPaddingTop - 5,
                          bottom: btnPaddingBottom - 5,
                        ),
                        color: Theme.of(context).accentColor,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.all(Radius.elliptical(100, 100)),
                        ),
                        child: Text(
                          'Sign Up',
                          style: TextStyle(
                            fontSize:
                                Theme.of(context).textTheme.button.fontSize,
                            color: Colors.white,
                          ),
                        ),
                        // ],
                        // ),
                        highlightColor: defaultColor,
                        onHighlightChanged: (isHeighlighted) {
                          if (isHeighlighted) {
                            defaultHeighlightedColor = Colors.white;
                          } else {
                            defaultHeighlightedColor = defaultColor;
                          }
                          setState(() {});
                        },
                        onPressed: () async {
                          if (!pressed) {
                            pressed = true;
                            Utils.showLoadingDialog(context);
                            tapped = true;
                            var form = _formKey.currentState;
                            if (form.validate() &&
                                dateInitialText != dateText &&
                                driver.homeLocationLatLng != null) {
                              driver.userCreatedOn = DateTime.now();
                              // user.userId =
                              //     "user${DateTime.now().millisecondsSinceEpoch}";
                              try {
                                FirebaseAuth.instance
                                    .createUserWithEmailAndPassword(
                                  email: driver.email,
                                  password: passwordController.text,
                                )
                                    .catchError((error) async {
                                  Utils.showSnackBarError(
                                    context,
                                    error.message,
                                  );
                                  pressed = false;
                                  Navigator.pop(context);
                                }).then((value) {
                                  FirebaseUser firebaseUser = value.user;
                                  if (firebaseUser == null) {
                                    SnackBar snackBar = SnackBar(
                                      content: Text(
                                        'An Account with the same email already exists',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      backgroundColor: Colors.yellow,
                                      duration: Duration(seconds: 1),
                                    );
                                    Scaffold.of(context).showSnackBar(snackBar);
                                  } else {
                                    driver.driverId = firebaseUser.uid;
                                    driver.balance = 0;
                                    driver.rating = 0;
                                    driver.totalReviews = 0;
                                    Map map = driver.toMap();
                                    Firestore.instance
                                        .collection("drivers")
                                        .document(driver.driverId)
                                        .setData(map)
                                        .timeout(Duration(seconds: 10))
                                        .then((a) async {
                                      // await DatabaseHelper.signInUser(
                                      //   user.userId,
                                      // );
                                      Database database =
                                          DatabaseHelper.getDatabase();
                                      database.insert(
                                        Tables.DRIVER_TABLE,
                                        driver.toMap(),
                                      );
                                      Session.data.update('driver', (_) {
                                        return driver;
                                      }, ifAbsent: () {
                                        return driver;
                                      });
                                      // Navigator.pop(context);
                                      firebaseUser.sendEmailVerification();
                                      // Navigator.popUntil(
                                      //     context, (route) => route.isFirst);

                                      Navigator.pushAndRemoveUntil(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) {
                                            return VerifyEmailRoute(
                                              context: context,
                                            );
                                          },
                                        ),
                                        (route) => false,
                                      );

                                      // Navigator.of(context).pushReplacement(
                                      //   MaterialPageRoute(
                                      //     builder: (context) {
                                      //       return VerifyEmailRoute(
                                      //         context: context,
                                      //       );
                                      //     },
                                      //   ),
                                      // );
                                      // Navigator.of(context)
                                      //     .pushNamed(MyApp.userHome);
                                    }).catchError((error) {
                                      pressed = false;
                                      Navigator.pop(context);
                                      SnackBar snackBar = SnackBar(
                                        content: Text(
                                          'Something went wrong. Try again!',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        backgroundColor: Colors.red,
                                      );
                                      firebaseUser.sendEmailVerification();
                                      Scaffold.of(context)
                                          .showSnackBar(snackBar);
                                    });
                                  }
                                });
                              } on dynamic catch (_) {
                                onSignUpError();
                              }
                            } else if (dateInitialText == dateText ||
                                driver.homeLocationLatLng == null) {
                              setState(() {
                                pressed = false;
                                Navigator.pop(context);
                                if (dateInitialText == dateText) {
                                  dateOfBirthHeadingColor = Colors.red;
                                  dateOfBirthTextColor = Colors.red;
                                } else {}
                              });
                            } else {
                              setState(() {
                                pressed = false;
                                Navigator.pop(context);
                              });
                            }
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
