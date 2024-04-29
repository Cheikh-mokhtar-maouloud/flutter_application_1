// // import 'package:flutter/material.dart';

// // class VideoCallScreen extends StatefulWidget {
// //   @override
// //   _VideoCallScreenState createState() => _VideoCallScreenState();
// // }

// // class _VideoCallScreenState extends State<VideoCallScreen> {
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(
// //         title: Text('Video Call'),
// //         actions: <Widget>[
// //           IconButton(
// //             icon: Icon(Icons.call_end),
// //             onPressed: () {
// //               // Ajoutez ici la logique pour terminer l'appel vidéo
// //               Navigator.of(context).pop();
// //             },
// //           ),
// //         ],
// //       ),
// //       body: Stack(
// //         children: [
// //           // Ajoutez ici le composant pour la vidéo en direct
// //           // Exemple : VideoPlayer(videoUrl),
// //           Center(
// //             child: Text(
// //               'Vidéo en direct',
// //               style: TextStyle(fontSize: 20.0),
// //             ),
// //           ),
// //           // Ajoutez ici les contrôles pour la vidéo
// //           Positioned(
// //             bottom: 20.0,
// //             left: 0,
// //             right: 0,
// //             child: Row(
// //               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
// //               children: <Widget>[
// //                 IconButton(
// //                   icon: Icon(Icons.mic),
// //                   onPressed: () {
// //                     // Gérer le son (activer/désactiver)
// //                   },
// //                 ),
// //                 IconButton(
// //                   icon: Icon(Icons.videocam),
// //                   onPressed: () {
// //                     // Gérer la caméra (activer/désactiver)
// //                   },
// //                 ),
// //                 IconButton(
// //                   icon: Icon(Icons.switch_camera),
// //                   onPressed: () {
// //                     // Changer de caméra (frontale/arrière)
// //                   },
// //                 ),
// //                 IconButton(
// //                   icon: Icon(Icons.volume_up),
// //                   onPressed: () {
// //                     // Gérer le volume (activer/désactiver)
// //                   },
// //                 ),
// //               ],
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // }

// import 'package:flutter/material.dart';

// import 'package:agora_rtc_engine/rtc_engine.dart';
// import 'package:permission_handler/permission_handler.dart';

// import 'package:agora_rtc_engine/rtc_local_view.dart' as RtcLocalView;
// import 'package:agora_rtc_engine/rtc_remote_view.dart' as RtcRemoteView;

// class VideoCallScreen extends StatefulWidget {
//   final String channelId;

//   VideoCallScreen({required this.channelId});

//   @override
//   _VideoCallScreenState createState() => _VideoCallScreenState();
// }

// class _VideoCallScreenState extends State<VideoCallScreen> {
//   RtcEngine? _engine;

//   @override
//   void initState() {
//     super.initState();
//     initializeAgora();
//   }

//   Future<void> initializeAgora() async {
//     // Demander les permissions
//     await [Permission.microphone, Permission.camera].request();

//     // Créer le moteur RTC
//     _engine = await RtcEngine.create('431bcc4e1ea24bceaf83e68f2d1d90fb');
//     _engine?.setEventHandler(
//       RtcEngineEventHandler(
//         joinChannelSuccess: (channel, uid, elapsed) {
//           print('joinChannelSuccess $channel, uid: $uid');
//         },
//         userJoined: (uid, elapsed) {
//           print('userJoined $uid');
//         },
//         userOffline: (uid, reason) {
//           print('userOffline $uid');
//         },
//       ),
//     );

//     // Activer la vidéo
//     await _engine?.enableVideo();

//     // Rejoindre le canal
//     await _engine?.joinChannel(null, widget.channelId, null, 0);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Video Call'),
//       ),
//       body: Stack(
//         children: [
//           RtcLocalView.SurfaceView(),
//           Align(
//             alignment: Alignment.topRight,
//             child: Padding(
//               padding: const EdgeInsets.only(top: 20),
//               child: RtcRemoteView.SurfaceView(
//                 uid: 1,
//                 channelId: widget.channelId,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _engine?.leaveChannel();
//     _engine?.destroy();
//     super.dispose();
//   }
// }
