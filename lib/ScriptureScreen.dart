// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simple_bible/KjvModel.dart';
import 'package:simple_bible/LocalState.dart';

class ScriptureScreen extends StatefulWidget {
  // final List<Kjv> kjv;
  const ScriptureScreen({
    Key? key,
    /* required this.kjv */
  }) : super(key: key);

  @override
  State<ScriptureScreen> createState() => _ScriptureScreenState();
}

class _ScriptureScreenState extends State<ScriptureScreen> {
  final ScrollController _controller = ScrollController();

  String _book = 'Genesis';
  int _chapter = 1;

  // Define the function that scroll to an item
  // void _scrollToIndex(index) {
  //   _controller.animateTo(_height * index,
  //       duration: const Duration(seconds: 2), curve: Curves.easeIn);
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 20, 6, 46),
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          '${context.watch<LocalState>().version.versionName}',
          style: const TextStyle(color: Color.fromARGB(255, 196, 211, 255)),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          onTap: (index) {
            if (index == 0) {
              _versions(context);
            }
            if (index == 1) {
              _books(context);
            }
            if (index == 2) {
              _chapters(context);
            }
            if (index == 3) {
              _verses(context);
            }
          },
          // showSelectedLabels: false,
          showUnselectedLabels: true,
          backgroundColor: const Color.fromARGB(255, 20, 6, 46),
          elevation: 0,
          unselectedItemColor: Color.fromARGB(255, 196, 211, 255),
          selectedItemColor: Color.fromARGB(255, 196, 211, 255),
          items: [
            BottomNavigationBarItem(
                icon: Icon(Icons.translate), label: 'Versions'),
            BottomNavigationBarItem(icon: Icon(Icons.menu_book), label: 'Book'),
            BottomNavigationBarItem(
                icon: Icon(Icons.article), label: 'Chapter'),
            BottomNavigationBarItem(icon: Icon(Icons.subject), label: 'Verse'),
            BottomNavigationBarItem(icon: Icon(Icons.note_alt), label: 'Notes')
          ]),
      body: ListView.builder(
          itemCount: context.watch<LocalState>().version.books!.length,
          controller: _controller,
          itemBuilder: ((context, index) => Card(
                semanticContainer: false,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  margin: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          '${context.watch<LocalState>().version.books![index].bookName} ${context.watch<LocalState>().version.books![index].chapter}:${context.watch<LocalState>().version.books![index].verse}',
                          style: const TextStyle(
                              color: Colors.red, fontWeight: FontWeight.bold)),
                      Text(
                          utf8.decode(JsonUtf8Encoder().convert(context
                              .watch<LocalState>()
                              .version
                              .books![index]
                              .text)),
                          softWrap: true,
                          style: const TextStyle(color: Colors.black))
                    ],
                  ),
                ),
              ))),
    );
  }

  void _versions(context) {
    final theme = Theme.of(context);
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    showModalBottomSheet(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(20.0),
              topRight: const Radius.circular(20.0)),
        ),
        context: context,
        builder: (BuildContext bc) {
          return ListView.builder(
              itemCount: Provider.of<LocalState>(context, listen: false)
                  .versions
                  .length,
              shrinkWrap: true,
              itemBuilder: ((context, index) {
                return ListTile(
                  onTap: () {
                    Provider.of<LocalState>(context, listen: false).version =
                        Provider.of<LocalState>(context, listen: false)
                            .versions[index];
                    Navigator.pop(context);
                  },
                  title: Text(Provider.of<LocalState>(context, listen: false)
                      .versions[index]
                      .versionName!),
                  trailing: Icon(Icons.arrow_forward_ios),
                );
              }));
        });
  }

  void _books(context) {
    final theme = Theme.of(context);
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    showModalBottomSheet(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(20.0),
              topRight: const Radius.circular(20.0)),
        ),
        context: context,
        builder: (BuildContext bc) {
          return ListView.builder(
              itemCount: Provider.of<LocalState>(context, listen: false)
                  .version
                  .books!
                  .map((e) => e.bookName)
                  .toSet()
                  .toList()
                  .length,
              shrinkWrap: true,
              itemBuilder: ((context, index) {
                return ListTile(
                  onTap: () {
                    // Provider.of<LocalState>(context, listen: false).version =
                    //     Provider.of<LocalState>(context, listen: false)
                    //         .versions[index];
                    setState(() {
                      _book = Provider.of<LocalState>(context, listen: false)
                          .version
                          .books!
                          .map((e) => e.bookName)
                          .toSet()
                          .toList()[index];
                    });
                    Navigator.pop(context);
                  },
                  title: Text(Provider.of<LocalState>(context, listen: false)
                      .version
                      .books!
                      .map((e) => e.bookName)
                      .toSet()
                      .toList()[index]),
                  trailing: Icon(Icons.arrow_forward_ios),
                );
              }));
        });
  }

  void _chapters(context) {
    final theme = Theme.of(context);
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    showModalBottomSheet(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(20.0),
              topRight: const Radius.circular(20.0)),
        ),
        context: context,
        builder: (BuildContext bc) {
          return GridView.builder(
              padding: const EdgeInsets.only(left: 40, top: 30),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5),
              itemCount: Provider.of<LocalState>(context, listen: false)
                  .version
                  .books!
                  .where((element) => element.bookName == _book)
                  .map((e) => e.chapter)
                  .toSet()
                  .length,
              itemBuilder: ((context, index) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _chapter = index + 1;
                    });
                    Navigator.pop(context);
                  },
                  child: Text(
                    (index + 1).toString(),
                    /* style: const TextStyle(
                        color: Color.fromARGB(255, 196, 211, 255)), */
                  ),
                );
              }));
        });
  }

  void _verses(context) {
    final theme = Theme.of(context);
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    showModalBottomSheet(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(20.0),
              topRight: const Radius.circular(20.0)),
        ),
        context: context,
        builder: (BuildContext bc) {
          return GridView.builder(
              padding: const EdgeInsets.only(left: 40, top: 30),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5),
              itemCount: Provider.of<LocalState>(context, listen: false)
                  .version
                  .books!
                  .where((element) =>
                      element.bookName == _book &&
                      element.chapter == _chapter - 1)
                  .map((e) => e.verse)
                  .toSet()
                  .length,
              itemBuilder: ((context, index) {
                return GestureDetector(
                  onTap: () {
                    //    setState(() {
                    //   _chapter = Provider.of<LocalState>(context, listen: false)
                    //       .version
                    //       .books!
                    //       .map((e) => e.bookName)
                    //       .toSet()
                    //       .toList()[index];
                    // });
                    Navigator.pop(context);
                  },
                  child: Text(
                    (index + 1).toString(),
                    /* style: const TextStyle(
                        color: Color.fromARGB(255, 196, 211, 255)), */
                  ),
                );
              }));
        });
  }
}
