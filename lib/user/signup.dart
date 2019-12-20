import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:place_picker/place_picker.dart';
import 'package:sennit/database/mydatabase.dart';
import 'package:sennit/main.dart';
import 'package:sennit/models/models.dart';
import 'package:sqflite/sqlite_api.dart';

class UserSignUpRoute extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Sign Up'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: UserSignUpRouteBody(),
      ),
    );
  }
}

class UserSignUpRouteBody extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return UserSignUpRouteState();
  }

  // final _formKey = GlobalKey<FormState>();
  // final passwordController = TextEditingController();
}

class UserSignUpRouteState extends State<UserSignUpRouteBody> {
  User user = User();
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

  String address = "Not Available";
  final _formKey = GlobalKey<FormState>();

  final passwordController = TextEditingController();
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
                        user.firstName = firstName;
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
                        user.lastName = lastName;
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
                        user.email = email;
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
                                user.dateOfBirth = selectedDate;
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
                      decoration: InputDecoration(labelText: 'Phone Number'),
                      validator: (cellNum) {
                        if (cellNum.isEmpty) {
                          return "Please Enter your phone number";
                        }
                        user.phoneNumber = cellNum;
                        return null;
                      },
                      style: Theme.of(context).textTheme.body1,
                    ),
                    ListTile(
                      leading: Icon(
                        Icons.location_on,
                        color: Theme.of(context).accentColor,
                      ),
                      title: Text('Pick A location'),
                      onTap: () async {
                        LocationResult result =
                            await Utils.showPlacePicker(context);
                        if (result != null) {
                          setState(() {
                            address = result.formattedAddress;
                          });
                        }
                        user.homeLocationAddress = address;
                        user.homeLocationLatLng = result.latLng;
                      },
                    ),
                    ListTile(
                      leading: Icon(
                        Icons.my_location,
                        color: Theme.of(context).accentColor,
                      ),
                      title: Text('Selected Location',
                          style:
                              TextStyle(color: Theme.of(context).accentColor)),
                      subtitle: Text(
                        address,
                      ),
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
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (context) {
                              return Dialog(
                                  elevation: 8,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(4),
                                    ),
                                  ),
                                  child: CircularProgressIndicator());
                            },
                          );
                          tapped = true;
                          var form = _formKey.currentState;
                          if (form.validate() && dateInitialText != dateText) {
                            user.userCreatedOn = DateTime.now();
                            user.userId =
                                "user${DateTime.now().millisecondsSinceEpoch}";
                            Database database = DatabaseHelper.getDatabase();
                            database.insert(Tables.USER_TABLE, user.toMap());
                            await DatabaseHelper.signInUser(user.userId);
                            Firestore.instance
                                .collection("users")
                                .document(user.userId)
                                .setData(user.toMap())
                                .timeout(Duration(seconds: 10))
                                .then((a) {
                              Session.variables["user"] = user;
                              Navigator.pop(context);
                              Navigator.pop(context);
                              Navigator.of(context).pushNamed(MyApp.userHome);
                            }).catchError(() {
                              Navigator.pop(context);
                              SnackBar snackBar = SnackBar(
                                content: Text(
                                  'Something went wrong. Try again!',
                                  style: TextStyle(color: Colors.white),
                                ),
                                backgroundColor: Colors.red,
                              );
                              Scaffold.of(context).showSnackBar(snackBar);
                            });
                          } else if (dateInitialText == dateText) {
                            setState(() {
                              Navigator.pop(context);
                              dateOfBirthHeadingColor = Colors.red;
                              dateOfBirthTextColor = Colors.red;
                            });
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
