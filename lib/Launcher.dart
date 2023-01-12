import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:simple_bible/DAO/LocalState.dart';
import 'package:simple_bible/DAO/versionClassModel.dart';

import 'package:simple_bible/scriptureScreen.dart';

class Launcher extends StatefulWidget {
  const Launcher({Key? key}) : super(key: key);

  @override
  State<Launcher> createState() => _LauncherState();
}

class _LauncherState extends State<Launcher> {
  late Versions version;
  List<Versions> versions = [];
  void _loadAssets() {
    rootBundle.loadString('asset/kjv.json').then((value) {
      version = versionsFromJson(value);
      versions.add(version);
      Provider.of<LocalState>(context, listen: false).version = version;
      Provider.of<LocalState>(context, listen: false).book = version.books!.first;
      Provider.of<LocalState>(context, listen: false).chapter = 1;
    }).then((value) {
      rootBundle.loadString('asset/AkuapemTwi.json').then((value) {
        version = versionsFromJson(value);
        versions.add(version);
        Provider.of<LocalState>(context, listen: false).versions = versions;
      }).then((value) => Navigator.push(context,
          MaterialPageRoute(builder: ((context) => const ScriptureScreen()))));
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _loadAssets();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 20, 6, 46),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Text(
              'THE',
              textScaleFactor: 3,
              style: TextStyle(
                  color: Color.fromARGB(214, 218, 16, 2), fontSize: 20),
            ),
            Text(
              'HOLY',
              textScaleFactor: 6,
              style: TextStyle(
                  fontWeight: FontWeight.w400,
                  color: Color.fromARGB(255, 196, 211, 255),
                  fontSize: 20),
            ),
            Text(
              'BIBLE',
              textScaleFactor: 6,
              style: TextStyle(
                  fontWeight: FontWeight.w400,
                  color: Color.fromARGB(255, 196, 211, 255),
                  fontSize: 20),
            ),
          ],
        ),
      ),
    );
  }
}
