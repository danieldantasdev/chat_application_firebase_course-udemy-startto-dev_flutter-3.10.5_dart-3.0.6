import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class TextComposerWidget extends StatefulWidget {
  const TextComposerWidget(this.sendMessage, {super.key});

  final void Function({String? text, String? imgFile}) sendMessage;

  @override
  State<TextComposerWidget> createState() => _TextComposerWidgetState();
}

class _TextComposerWidgetState extends State<TextComposerWidget> {
  bool _isComposing = false;
  final TextEditingController _textEditingController = TextEditingController();

  void _resetField() {
    _textEditingController.clear();
    setState(() {
      _isComposing = false;
    });
  }

  Future<void> _onCaptureImageFromCamera() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      File file = File(pickedFile.path);
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();

      try {
        firebase_storage.Reference ref =
            firebase_storage.FirebaseStorage.instance.ref().child(fileName);
        await ref.putFile(file);
        String downloadURL = await ref.getDownloadURL();

        widget.sendMessage(imgFile: downloadURL);
      } catch (e) {
        print('Error uploading image: $e');
      }
    }
  }

  Future<File?> _onCaptureImageFromGallery() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      File file = File(pickedFile.path);
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();

      try {
        firebase_storage.Reference ref =
            firebase_storage.FirebaseStorage.instance.ref().child(fileName);
        await ref.putFile(file);
        String downloadURL = await ref.getDownloadURL();

        widget.sendMessage(imgFile: downloadURL);
      } catch (e) {
        print('Error uploading image: $e');
      }
    }
  }

  Future<void> _showImageSourceDialog() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Selecione uma imagem'),
          content: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _onCaptureImageFromCamera();
                },
                child: const Text('Câmera'),
              ),
              const SizedBox(
                width: 20,
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _onCaptureImageFromGallery();
                },
                child: const Text('Galeria'),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: <Widget>[
          IconButton(
            icon: const Icon(Icons.photo_camera),
            onPressed: () async {
              _showImageSourceDialog();
              // final File imgFile = (await ImagePicker()
              //     .pickImage(source: ImageSource.camera)) as File;
              // if (imgFile == null) return;
              // widget.sendMessage(imgFile: imgFile);
            },
          ),
          Expanded(
            child: TextField(
              controller: _textEditingController,
              decoration: const InputDecoration.collapsed(
                  hintText: 'Enviar uma Mensagem'),
              onChanged: (text) {
                setState(() {
                  _isComposing = text.isNotEmpty;
                });
              },
              onSubmitted: (text) {
                widget.sendMessage(text: text);
                _resetField();
              },
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: _isComposing
                ? () {
                    widget.sendMessage(text: _textEditingController.text);
                    _resetField();
                  }
                : null,
          ),
        ],
      ),
    );
  }
}
