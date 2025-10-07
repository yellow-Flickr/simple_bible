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
      Provider.of<LocalState>(context, listen: false).book =
          version.books!.first;
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
        var theme = Theme.of(context);

    return Scaffold(
      // backgroundColor: darkColor,
      body: Stack(
        children: [
          Positioned(
              top: 0,
              left: 86,
              child: Container(
                width: 2,
                height: 250,
                color: theme.primaryColorDark,
              )),
          Center(
            child: Column(
              //crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              // textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  'THE',
                  textScaleFactor: 1.5,
                  style: TextStyle(
                      //fontFamily: 'Canterbury',
                      color: theme.primaryColorDark,
                      fontSize: 20),
                ),
                  Text(
                  'HOLY',
                  textScaleFactor: 5,
                  style: TextStyle(
                      fontFamily: 'Myriad Pro',
                      fontWeight: FontWeight.w200,
                      color: theme.primaryColorLight,
                      fontSize: 20),
                ),
                  Text(
                  'BIBLE',
                  textScaleFactor: 5,
                  style: TextStyle(
                      fontFamily: 'Myriad Pro',
                      fontWeight: FontWeight.w400,
                      color: theme.primaryColorLight,
                      fontSize: 20),
                ),
                const SizedBox(height: 50),
                Icon(Icons.menu_book_outlined, size: 100, color: theme.primaryColorDark)
              ],
            ),
          ),
          Positioned(
              bottom: 0,
              right: 90,
              child: Container(
                width: 2,
                height: 250,
                color: theme.primaryColorDark,
              ))
        ],
      ),
    );
  }
}
