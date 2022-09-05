import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:vocapark/src/new_word/boxes.dart';

import '../models/word_to_learn.dart';

class NewWordScreen extends StatefulWidget {
  const NewWordScreen({super.key});

  @override
  State<NewWordScreen> createState() => _NewWordScreenState();
}

class _NewWordScreenState extends State<NewWordScreen> {
  @override
  void dispose() {
    super.dispose();
  }

  String word = '';
  String translation = '';

  TextEditingController _textFieldWordController = TextEditingController();
  TextEditingController _textFieldTranslationController =
      TextEditingController();

  Future<void>? _addWord(String word, String translation) {
    final wordToLearn = WordToLearn()
      ..word = word
      ..translation = translation
      ..date = DateTime.now()
      ..wordScore = 0;

    final box = Boxes.getVocabulary();
    box.add(wordToLearn);

    return null;
  }

  Future<void>? _editWord(
      String word, String translation, WordToLearn wordToLearn) {
    wordToLearn.word = word;
    wordToLearn.translation = translation;

    wordToLearn.save();

    return null;
  }

  Future<void>? _deleteWord(WordToLearn wordToLearn) {
    wordToLearn.delete();

    return null;
  }

  Future<void> _displayWordDeleteDialog(
      BuildContext context, WordToLearn wordToLearn) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Are you sure?'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('You are going to delete this word: '),
                Text(wordToLearn.word ?? ''),
              ],
            ),
            actions: <Widget>[
              ElevatedButton(
                child: Text('CANCEL'),
                onPressed: () {
                  setState(() {
                    Navigator.pop(context);
                  });
                },
              ),
              ElevatedButton(
                  child: Text('Delete'),
                  onPressed: () {
                    setState(() {
                      _deleteWord(
                        wordToLearn,
                      );
                      Navigator.pop(context);
                    });
                  }),
            ],
          );
        });
  }

  Future<void> _displayWordEditDialog(
      BuildContext context, WordToLearn wordToLearn) async {
    _textFieldWordController.text = wordToLearn.word ?? '';
    _textFieldTranslationController.text = wordToLearn.translation ?? '';

    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Edit word'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  onChanged: (value) {
                    setState(() {
                      word = value;
                    });
                  },
                  controller: _textFieldWordController,
                  decoration: InputDecoration(hintText: "English word"),
                ),
                TextField(
                  onChanged: (value) {
                    setState(() {
                      translation = value;
                    });
                  },
                  controller: _textFieldTranslationController,
                  decoration: InputDecoration(hintText: "Translation"),
                ),
              ],
            ),
            actions: <Widget>[
              ElevatedButton(
                child: Text('CANCEL'),
                onPressed: () {
                  setState(() {
                    Navigator.pop(context);
                  });
                },
              ),
              ElevatedButton(
                  child: Text('Save'),
                  onPressed: () {
                    setState(() {
                      _editWord(
                        word,
                        translation,
                        wordToLearn,
                      );
                      _textFieldWordController.clear();
                      _textFieldTranslationController.clear();
                      Navigator.pop(context);
                    });
                  }),
            ],
          );
        });
  }

  Future<void> _displayWordInputDialog(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Add new word'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  onChanged: (value) {
                    setState(() {
                      word = value;
                    });
                  },
                  controller: _textFieldWordController,
                  decoration: InputDecoration(hintText: "English word"),
                ),
                TextField(
                  onChanged: (value) {
                    setState(() {
                      translation = value;
                    });
                  },
                  controller: _textFieldTranslationController,
                  decoration: InputDecoration(hintText: "Translation"),
                ),
              ],
            ),
            actions: <Widget>[
              ElevatedButton(
                child: Text('CANCEL'),
                onPressed: () {
                  setState(() {
                    Navigator.pop(context);
                  });
                },
              ),
              ElevatedButton(
                  child: Text('Add'),
                  onPressed: () {
                    setState(() {
                      _addWord(
                        word,
                        translation,
                      );
                      _textFieldWordController.clear();
                      _textFieldTranslationController.clear();
                      Navigator.pop(context);
                    });
                  }),
            ],
          );
        });
  }

  buildContent(List<WordToLearn>? vocabulary) {
    List<Widget>? _wordLines = vocabulary
        ?.map(
          (element) => Card(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        element.word ?? '',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        element.translation ?? '',
                        style: TextStyle(
                          color: Colors.black54,
                          fontWeight: FontWeight.w300,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    OutlinedButton(
                      onPressed: () {
                        _displayWordEditDialog(context, element);
                      },
                      child: Text('Edit'),
                    ),
                    SizedBox(width: 20),
                    OutlinedButton(
                      onPressed: () {
                        _displayWordDeleteDialog(context, element);
                      },
                      child: Text('Delete'),
                    ),
                    SizedBox(width: 16),
                  ],
                ),
              ],
            ),
          ),
        )
        .toList();

    return ListView(
      children: _wordLines ?? [],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Your vocabulary park'),
      ),
      body: ValueListenableBuilder<Box<WordToLearn>>(
          valueListenable: Boxes.getVocabulary().listenable(),
          builder: (context, box, _) {
            final vocabulary = box.values.toList().cast<WordToLearn>();
            return buildContent(vocabulary);
          }),
      floatingActionButton: FloatingActionButton(
        child: Text(
          '+',
          style: TextStyle(
            fontSize: 20,
          ),
        ),
        onPressed: () {
          _displayWordInputDialog(context);
        },
      ),
    );
  }
}
