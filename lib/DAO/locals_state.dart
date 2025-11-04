// ignore_for_file: prefer_final_fields

import 'package:flutter/foundation.dart';
import 'package:simple_bible/bible_reader/domain/scripture_models.dart';

class LocalState extends ChangeNotifier {
  List<Versions> _versions = [];
  // Versions _version = Versions();
  // Verse _book = Verse(id: 0);
  // Lis<Books> _books = Books();
  int _chapter = 1;
  List<int> _bookIds = [];
  // Versions get version => _version;
  List<Versions> get versions => _versions;
  List<int> get bookIds => _bookIds;
  // Verse get book => _book;
  int get chapter => _chapter;

  set versions(List<Versions> versions) {
    _versions = versions;
    notifyListeners();
  }

  // set version(Versions version) {
  //   _version = version;
  //   _bookIds.clear();
  //   version.books!.map((e) => e.bookName).toSet().forEach(
  //     (elements) {
  //       _bookIds.add(version.books!
  //           .firstWhere((element) => element.bookName == elements)
  //           .id);
  //     },
  //   );

  //   notifyListeners();
  // }

  set book(Verse book) {
    // _book = book;
    notifyListeners();
  }

  set chapter(int chapter) {
    _chapter = chapter;
    notifyListeners();
  }

  set bookIds(List<int> bookIds) {
    _bookIds = bookIds;
    notifyListeners();
  }

  void addToVersions(List<Versions> versions) {
    _versions.addAll(versions);
    notifyListeners();
  }
}
