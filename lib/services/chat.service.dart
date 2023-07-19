import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/chat.dart';

class ChatService {
  final CollectionReference _chatsCollection =
      FirebaseFirestore.instance.collection('chat');

  Future<void> create({required Chat chat}) async {
    try {
      await _chatsCollection.add(chat.toJson());
    } catch (e) {
      print('Error creating chat: $e');
    }
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
