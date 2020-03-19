// import 'dart:async';
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// class MessageHandler extends StatefulWidget {
//   @override
//   _MessageHandlerState createState() => _MessageHandlerState();
// }

// class _MessageHandlerState extends State<MessageHandler> {

//   final Firestore _db = Firestore.instance;
//   final FirebaseMessaging _fcm = FirebaseMessaging();
//   StreamSubscription iosSubscription;

//   @override
//   void initState() {
//     super.initState();
//     if (Platform.isIOS) {
//       iosSubscription = _fcm.onIosSettingsRegistered.listen((data) {
        
//       });
//       _fcm.requestNotificationPermissions(IosNotificationSettings());
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return null;
//   }
// }

