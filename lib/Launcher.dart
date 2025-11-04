import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter/services.dart';
// import 'package:simple_bible/DAO/locals_state.dart';
import 'package:simple_bible/bible_reader/data/scripture_repository.dart';
import 'package:simple_bible/home/presentation/home.dart';

class Launcher extends ConsumerStatefulWidget {
  const Launcher({super.key});

  @override
  ConsumerState<Launcher> createState() => _LauncherState();
}

class _LauncherState extends ConsumerState<Launcher> {
  void _loadAssets() {
    Future.delayed(Duration(seconds: 2), () {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: ((context) => const Home())));
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
    ref.watch(scriptureDataProvider);
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
                  textScaler: TextScaler.linear(1.5),
                  style: TextStyle(
                      //fontFamily: 'Canterbury',
                      color: theme.primaryColorDark,
                      fontSize: 20),
                ),
                Text(
                  'HOLY',
                  textScaler: TextScaler.linear(5),
                  style: TextStyle(
                      fontFamily: 'Myriad Pro',
                      fontWeight: FontWeight.w200,
                      color: theme.primaryColorLight,
                      fontSize: 20),
                ),
                Text(
                  'BIBLE',
                  textScaler: TextScaler.linear(5),
                  style: TextStyle(
                      fontFamily: 'Myriad Pro',
                      fontWeight: FontWeight.w400,
                      color: theme.primaryColorLight,
                      fontSize: 20),
                ),
                const SizedBox(height: 50),
                Icon(Icons.menu_book_outlined,
                    size: 100, color: theme.primaryColorDark)
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
