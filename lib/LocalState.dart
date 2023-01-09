// ignore_for_file: prefer_final_fields

import 'package:flutter/foundation.dart';
import 'package:simple_bible/KjvModel.dart';

class LocalState extends ChangeNotifier {
  List<Versions> _versions = [];
  Versions  _version = Versions( ) ;
  Versions  get version => _version ;
  List<Versions> get versions => _versions;

  set versions(List<Versions> versions) {
    _versions = versions;
    notifyListeners();
  }
  
  set version(Versions version) {
    _version = version;
    notifyListeners();
  }

  void addToVersions(List<Versions> versions) {
    _versions.addAll(versions);
    notifyListeners();
  }
}
