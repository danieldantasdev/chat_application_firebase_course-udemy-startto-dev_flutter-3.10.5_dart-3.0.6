import 'package:chat/models/chat.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../services/chat.service.dart';
import '../widgets/widgets.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ChatService _chatService = ChatService();

  void _sendMessage(Chat chat) {
    _chatService.create(chat: chat);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text(
          widget.title,
          style: const TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance.collection('chat').snapshots(),
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.none:
                    return const Center(child: Text('Error'));
                  case ConnectionState.active:
                    List<QueryDocumentSnapshot<Map<String, dynamic>>>
                        documents = snapshot.data!.docs.reversed.toList();

                    return ListView.builder(
                      reverse: true,
                      itemCount: documents.length,
                      itemBuilder: (context, index) {
                        Map<String, dynamic> data = documents[index].data();
                        String text = data['text'] as String;

                        return ListTile(
                          title: Text(text),
                        );
                      },
                    );
                  case ConnectionState.waiting:
                    return const Center(child: CircularProgressIndicator());
                  case ConnectionState.done:
                    List<QueryDocumentSnapshot<Map<String, dynamic>>>
                        documents = snapshot.data!.docs;

                    return ListView.builder(
                      reverse: true,
                      itemCount: documents.length,
                      itemBuilder: (context, index) {
                        Map<String, dynamic> data = documents[index].data();
                        String text = data['text'] as String;

                        return ListTile(
                          title: Text(text),
                        );
                      },
                    );
                }
              },
            ),
          ),
          TextComposerWidget(_sendMessage),
        ],
      ),
    );
  }
}
