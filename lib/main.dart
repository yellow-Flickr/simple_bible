import 'package:flutter/material.dart';
import 'package:simple_bible/ChapterScreen.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:simple_bible/KjvModel.dart';
import 'package:simple_bible/Launcher.dart';

Future<void> main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        fontFamily: 'Myriad Pro',
        primarySwatch: Colors.blue,
      ),
      home: const Launcher(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final List<Kjv> kjv;
  const MyHomePage({Key? key, required this.kjv}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // late List<Kjv> kjv;

  // Future<void> loadAsset() async {
  //   kjv = kjvFromJson(await rootBundle.loadString('asset/kjv.json'));
  // }

  // void loadData() async {
  //   await loadAsset();
  // }
  late List<String> old;
  late List<String> _new;
  @override
  void initState() {
    super.initState();
    old = widget.kjv.map((e) => e.bookName).toSet().take(39).toList();
    _new = widget.kjv.map((e) => e.bookName).toSet().skip(39).toList();
  }

  @override
  Widget build(BuildContext context) {
    return
        // Word(
        //   kjv: kjv,
        //   child:
        DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 20, 6, 46),
        appBar: TabBar(
          // indicatorPadding: EdgeInsets.symmetric(horizontal: 30,vertical: 30),

          indicatorColor: const Color.fromARGB(255, 196, 211, 255),
          indicatorWeight: 2,
          // indicator: Dec,
          indicatorSize: TabBarIndicatorSize.label,
          padding: const EdgeInsets.only(top: 50),
          labelColor: const Color.fromARGB(214, 218, 16, 2),
          labelStyle:
              const TextStyle(fontSize: 20, fontWeight: FontWeight.w400),
          tabs: [
            Text(
              widget.kjv
                  .firstWhere((element) => old.contains(element.bookName))
                  .testament,
              // style: TextStyle(color: Colors.red),
            ),
            Text(
              widget.kjv
                  .firstWhere((element) => _new.contains(element.bookName))
                  .testament,
              // style: TextStyle(color: Colors.red),
            )
          ],
        ),
        body: TabBarView(children: [
          ListView.builder(
              itemCount: old.length,
              itemBuilder: ((context, index) {
                return Padding(
                  padding: const EdgeInsets.only(left: 8.0, top: 5),
                  child: ListTile(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: ((context) => Chapter(
                                    kjv: widget.kjv
                                        .where((element) =>
                                            element.bookName == old[index])
                                        .toList(),
                                  ))));
                    },
                    title: Text(
                      old[index],
                      style:
                          TextStyle(color: Color.fromARGB(255, 196, 211, 255)),
                    ),
                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                      color: Color.fromARGB(255, 196, 211, 255),
                    ),
                  ),
                );
              })),
          ListView.builder(
              itemCount: _new.length,
              itemBuilder: ((context, index) {
                return ListTile(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: ((context) => Chapter(
                                  kjv: widget.kjv
                                      .where((element) =>
                                          element.bookName == _new[index])
                                      .toList(),
                                ))));
                  },
                  title: Text(
                    _new[index],
                    style: const TextStyle(
                        color: Color.fromARGB(255, 196, 211, 255)),
                  ),
                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    color: Color.fromARGB(255, 196, 211, 255),
                  ),
                );
              }))
        ]),
      ),
    );
    // );
  }
}
