import 'package:flutter/material.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

class CallPage extends StatelessWidget {
  final String userID; // Patient's unique ID
  final String userName;
  final String callID;

  // Patient's name

  // Constructor to accept userID and userName
  const CallPage({Key? key, required this.userID, required this.userName, required this.callID})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ZegoUIKitPrebuiltCall(
      appID:
          1501130655, // Fill in the appID that you get from ZEGOCLOUD Admin Console.
      appSign:
          "498caad4a94c78410e4434f1cf96281868d4159e701e955d0c771b35c25c25d0", // Fill in the appSign that you get from ZEGOCLOUD Admin Console.
      userID: userID, // Dynamic userID passed to the widget
      userName: userName, // Dynamic userName passed to the widget
      callID:
          callID, // Call ID, ensure it's unique or matches the desired call session
      config: ZegoUIKitPrebuiltCallConfig.oneOnOneVideoCall(),
    );
  }
}
