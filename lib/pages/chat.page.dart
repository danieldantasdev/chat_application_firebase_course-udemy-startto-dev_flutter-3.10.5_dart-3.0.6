import 'package:chat/pages/pages.dart';
import 'package:chat/services/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../widgets/widgets.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key, required this.title});

  final String title;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final GoogleSignIn googleSignIn = GoogleSignIn();
  final GlobalKey<ScaffoldMessengerState> _scaffoldKey =
      GlobalKey<ScaffoldMessengerState>();
  final UserService _userService = UserService();

  User? _currentUser;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    setState(() {
      FirebaseAuth.instance.authStateChanges().listen((User? user) {
        _currentUser = user;
        _isLoading = false;
      });
    });
  }

  void _sendMessage({String? text, String? imgFile}) async {
    setState(() {
      _isLoading = true;
    });

    final User? user = await _userService.signIn(_currentUser, googleSignIn);

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Não foi possível fazer o login. Tente novamente!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    Map<String, dynamic> data = {
      "uid": user.uid,
      "senderName": user.displayName,
      "senderPhotoUrl": user.photoURL,
      "time": Timestamp.now(),
    };

    if (imgFile != null) {
      data['imgUrl'] = imgFile;
      Future.delayed(
        const Duration(seconds: 5),
        () {
          setState(() {
            _isLoading = false;
          });
        },
      );
    }

    if (text != null) data['text'] = text;

    FirebaseFirestore.instance.collection('chat').add(data);

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(_currentUser != null
            ? 'Olá, ${_currentUser?.displayName}'
            : 'Chat App'),
        centerTitle: true,
        elevation: 0,
        actions: <Widget>[
          _currentUser != null
              ? IconButton(
                  icon: const Icon(Icons.exit_to_app),
                  onPressed: () {
                    setState(() {
                      FirebaseAuth.instance.signOut();
                      googleSignIn.signOut();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Você saiu com sucesso!'),
                        ),
                      );
                    });
                  },
                )
              : Container()
        ],
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('chat')
                  .orderBy('time')
                  .snapshots(),
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.none:
                  case ConnectionState.waiting:
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  default:
                    List<DocumentSnapshot> documents =
                        snapshot.data!.docs.reversed.toList();

                    return ListView.builder(
                        itemCount: documents.length,
                        reverse: true,
                        itemBuilder: (context, index) {
                          return ChatMessagePage(
                            data:
                                documents[index].data() as Map<String, dynamic>,
                            mine: (documents[index].data()
                                    as Map<String, dynamic>)['uid'] ==
                                _currentUser?.uid,
                          );
                        });
                }
              },
            ),
          ),
          _isLoading == true ? const LinearProgressIndicator() : Container(),
          TextComposerWidget(_sendMessage),
        ],
      ),
    );
  }
}
