import 'dart:io';

class Chat {
  final String? text;
  final String? fileUrl;
  final File? file;
  final bool? isRead;

  Chat({
    this.text,
    this.fileUrl,
    this.file,
    this.isRead,
  });

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'fileUrl': fileUrl,
      'file': file,
      'isRead': isRead,
    };
  }

  factory Chat.fromJson(Map<String, dynamic> json) {
    return Chat(
      text: json['text'],
      fileUrl: json['fileUrl'],
      file: json['file'],
      isRead: json['isRead'],
    );
  }
}
