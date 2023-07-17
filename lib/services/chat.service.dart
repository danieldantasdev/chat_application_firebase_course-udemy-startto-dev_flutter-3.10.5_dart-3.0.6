import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

import '../models/chat.dart';

class ChatService {
  final CollectionReference _chatsCollection =
      FirebaseFirestore.instance.collection('chat');
  final FirebaseFirestore _firestore;

  ChatService() : _firestore = FirebaseFirestore.instance {
    Firebase.initializeApp();
  }

  Future<void> create({required Chat chat}) async {
    try {
      await _chatsCollection.add(chat.toJson());
    } catch (e) {
      print('Error creating chat: $e');
    }
  }

  Stream<List<Chat>> get() {
    return _chatsCollection.snapshots().map((QuerySnapshot snapshot) {
      List<Chat> chats = [];
      snapshot.docs.forEach((QueryDocumentSnapshot doc) {
        Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;
        chats.add(Chat.fromJson(data!));
      });
      return chats;
    });
  }

  Future<void> update(String id, String newMessage) async {
    try {
      await _chatsCollection.doc(id).update({'message': newMessage});
    } catch (e) {
      print('Error updating chat: $e');
    }
  }

  Future<void> delete(String id) async {
    try {
      await _chatsCollection.doc(id).delete();
    } catch (e) {
      print('Error deleting chat: $e');
    }
  }
}
