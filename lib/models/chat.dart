class Chat {
  final String? text;
  final String? file;
  final bool? isRead;

  Chat({
    this.text,
    this.file,
    this.isRead,
  });

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'file': file,
      'isRead': isRead,
    };
  }

  factory Chat.fromJson(Map<String, dynamic> json) {
    return Chat(
      text: json['text'],
      file: json['file'],
      isRead: json['isRead'],
    );
  }
}
