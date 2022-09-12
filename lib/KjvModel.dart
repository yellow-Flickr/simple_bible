// Generated by https://quicktype.io
//
// To change quicktype's target language, run command:
//
//   "Set quicktype target language"
// To parse this JSON data, do
//
//     final kjv = kjvFromJson(jsonString);

import 'dart:convert';

import 'package:flutter/widgets.dart';

List<Kjv> kjvFromJson(String str) {
  final jsonData = json.decode(str);
  return List<Kjv>.from(jsonData.map((x) => Kjv.fromJson(x)));
}

String kjvToJson(List<Kjv> data) {
  final dyn = List<dynamic>.from(data.map((x) => x.toJson()));
  return json.encode(dyn);
}

class Kjv {
  int chapter;
  int verse;
  String text;
  String translationId;
  String bookId;
  String bookName;
  String testament;

  Kjv({
    required this.chapter,
    required this.verse,
    required this.text,
    required this.translationId,
    required this.bookId,
    required this.bookName,
    required this.testament,
  });

  factory Kjv.fromJson(Map<String, dynamic> json) => Kjv(
        chapter: json["chapter"],
        verse: json["verse"],
        text: json["text"],
        translationId: json["translation_id"],
        bookId: json["book_id"],
        bookName: json["book_name"],
        testament: json["testament"],
      );

  Map<String, dynamic> toJson() => {
        "chapter": chapter,
        "verse": verse,
        "text": text,
        "translation_id": translationId,
        "book_id": bookId,
        "book_name": bookName,
        "testament": testament,
      };
}

class Word extends InheritedWidget {
  final List<Kjv> kjv;
  final Widget child;
  const Word({Key? key, required this.kjv, required this.child})
      : super(key: key, child: child);
  static Word? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<Word>();
  }

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) {
    // TODO: implement updateShouldNotify
    throw UnimplementedError();
  }
}