import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../models/chat.dart';

class ChatService {
  final CollectionReference _chatsCollection =
      FirebaseFirestore.instance.collection('chat');

  final GoogleSignIn _googleSignIn = GoogleSignIn();

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

  // Future<User?> signIn() async {
  //   try {
  //     final GoogleSignInAccount? googleSignInAccount =
  //         await _googleSignIn.signIn();
  //     final GoogleSignInAuthentication googleSignInAuthentication =
  //         await googleSignInAccount!.authentication;
  //     final AuthCredential authCredential = GoogleAuthProvider.credential(
  //       idToken: googleSignInAuthentication.idToken,
  //       accessToken: googleSignInAuthentication.accessToken,
  //     );
  //     final UserCredential userCredential =
  //         await FirebaseAuth.instance.signInWithCredential(authCredential);
  //     final User? user = userCredential.user;
  //     return user;
  //   } catch (error) {
  //     print(error);
  //   }
  // }

  Future<User?> signIn(User? user, GoogleSignIn googleSignIn) async {
    if (user != null) return user;

    try {
      final GoogleSignInAccount? googleSignInAccount =
          await googleSignIn.signIn();
      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount!.authentication;

      final AuthCredential authCredential = GoogleAuthProvider.credential(
        idToken: googleSignInAuthentication.idToken,
        accessToken: googleSignInAuthentication.accessToken,
      );

      final UserCredential authResult =
          await FirebaseAuth.instance.signInWithCredential(authCredential);

      final User? user = authResult.user;
      return user;
    } catch (error) {
      return null;
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
