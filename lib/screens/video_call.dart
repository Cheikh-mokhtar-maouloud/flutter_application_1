import 'package:flutter/material.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

class CallPage extends StatelessWidget {
  final String userID; // ID unique du patient
  final String userName; // Nom du patient
  final String callID; // ID de l'appel

  // Constructeur pour accepter userID, userName et callID
  const CallPage(
      {Key? key,
      required this.userID,
      required this.userName,
      required this.callID})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Appel Vidéo'),
      ),
      body: Stack(
        children: [
          ZegoUIKitPrebuiltCall(
            appID:
                1501130655, // Remplissez avec votre appID obtenu de la console admin de ZEGOCLOUD.
            appSign:
                "498caad4a94c78410e4434f1cf96281868d4159e701e955d0c771b35c25c25d0", // Remplissez avec votre appSign obtenu de la console admin de ZEGOCLOUD.
            userID: userID, // ID utilisateur dynamique passé au widget
            userName: userName, // Nom utilisateur dynamique passé au widget
            callID:
                callID, // ID de l'appel, assurez-vous qu'il est unique ou qu'il correspond à la session d'appel souhaitée
            config: ZegoUIKitPrebuiltCallConfig.oneOnOneVideoCall(),
          ),
          Positioned(
            top: 20.0,
            right: 20.0,
            width: 120.0,
            height: 160.0,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 2),
                borderRadius: BorderRadius.circular(8.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 8.0,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: ZegoUIKitPrebuiltCall(
                  appID:
                      1501130655, // Remplissez avec votre appID obtenu de la console admin de ZEGOCLOUD.
                  appSign:
                      "498caad4a94c78410e4434f1cf96281868d4159e701e955d0c771b35c25c25d0", // Remplissez avec votre appSign obtenu de la console admin de ZEGOCLOUD.
                  userID: userID, // ID utilisateur dynamique passé au widget
                  userName:
                      userName, // Nom utilisateur dynamique passé au widget
                  callID:
                      "12", // ID de l'appel, assurez-vous qu'il est unique ou qu'il correspond à la session d'appel souhaitée
                  config: ZegoUIKitPrebuiltCallConfig.oneOnOneVideoCall(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
