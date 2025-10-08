// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:simple_bible/DAO/locals_state.dart';


class ScriptureScreen extends StatefulWidget {
  // final List<Kjv> kjv;
  const ScriptureScreen({
    super.key,
    /* required this.kjv */
  });

  @override
  State<ScriptureScreen> createState() => ScriptureScreenState();
}

class ScriptureScreenState extends State<ScriptureScreen> {
  // final ScrollController _controller = ScrollController();
  final ItemScrollController itemScrollController = ItemScrollController();
  final ItemPositionsListener itemPositionsListener =
      ItemPositionsListener.create();

  // Define the function that scroll to an item
  // void scrollToIndex(int index) {
  //   _controller.jumpTo(
  //     height *
  //         index
  //             .toDouble(), /*  duration: const Duration(milliseconds: 600), curve: Curves.easeIn */
  //   );
  // }

  @override
  void initState() {
    itemPositionsListener.itemPositions.addListener(() {
      Provider.of<LocalState>(context, listen: false).book =
          Provider.of<LocalState>(context, listen: false)
              .version
              .books![itemPositionsListener.itemPositions.value.last.index];

      Provider.of<LocalState>(context, listen: false).chapter =
          Provider.of<LocalState>(context, listen: false)
              .version
              .books![itemPositionsListener.itemPositions.value.last.index]
              .chapter!;

      // log(itemPositionsListener.itemPositions.value.last.index.toString());
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return Scaffold(
      // backgroundColor: Colors.black,
      appBar: AppBar(
       leading: DrawerButton(),
        automaticallyImplyLeading: false,
        title: Text(
          '${context.watch<LocalState>().version.versionName}',
          style: theme.textTheme.titleLarge,
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
          // showUnselectedLabels: true,
          // backgroundColor: const Color.fromARGB(255, 25, 24, 26),
          // elevation: 0,
          // unselectedItemColor: Color.fromARGB(255, 255, 255, 255),
          // selectedItemColor: primaryColor,
          items: [
            BottomNavigationBarItem(
                icon: Icon(Icons.translate), label: 'Versions'),
            BottomNavigationBarItem(icon: Icon(Icons.menu_book), label: 'Book'),
            BottomNavigationBarItem(
                icon: Icon(Icons.article), label: 'Chapter'),
            BottomNavigationBarItem(icon: Icon(Icons.subject), label: 'Verse'),
            BottomNavigationBarItem(icon: Icon(Icons.note_alt), label: 'Notes')
          ]),
      body: ScrollablePositionedList.builder(
          itemCount: context.watch<LocalState>().version.books!.length,
          itemPositionsListener: itemPositionsListener,
          itemScrollController: itemScrollController,
          itemBuilder: ((context, index) => Card(
            color: theme.cardColor,
                semanticContainer: false,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  margin: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          '${context.watch<LocalState>().version.books![index].bookName} ${context.watch<LocalState>().version.books![index].chapter}:${context.watch<LocalState>().version.books![index].verse}',
                          style:theme.textTheme.bodyMedium  
                          // TextStyle(
                          //     color: primaryColor, fontWeight: FontWeight.bold)
                              ),
                      Text(
                          utf8.decode(JsonUtf8Encoder().convert(context
                              .watch<LocalState>()
                              .version
                              .books![index]
                              .text)),
                          softWrap: true,
                          style: theme.textTheme.bodySmall)
                    ],
                  ),
                ),
              ))),
    );
  }
  



  void _versions(context) {
    final theme = Theme.of(context);
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
                      .versionName!,style: theme.textTheme.bodyMedium!.copyWith(color: theme.primaryColorLight),),
                  trailing: Icon(Icons.arrow_forward_ios, ),
                );
              }));
        });
  }

  void _books(context) {
    final theme = Theme.of(context);
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
                    // context.read<LocalState>().book = context
                    //     .read<LocalState>()
                    //     .version
                    //     .books!
                    //     .firstWhere((element) =>
                    //         element.bookName ==
                    //         context
                    //             .read<LocalState>()
                    //             .version
                    //             .books!
                    //             .map((e) => e.bookName)
                    //             .toSet()
                    //             .toList()[index]);
                    itemScrollController.jumpTo(
                        index: context.read<LocalState>().bookIds[index]
                        // .version
                        // .books!
                        // .indexWhere((element) =>
                        //     element.bookName ==
                        //     context
                        //         .read<LocalState>()
                        //         .version
                        //         .books!
                        //         .map((e) => e.bookName)
                        //         .toSet()
                        //         .toList()[index])
                        );
                    Navigator.pop(context);
                  },
                  title: Text(Provider.of<LocalState>(context, listen: false)
                      .version
                      .books!
                      .map((e) => e.bookName)
                      .toSet()
                      .toList()[index]!,style: theme.textTheme.bodyMedium!.copyWith(color: theme.primaryColorLight),),
                  trailing: Icon(Icons.arrow_forward_ios, ),
                );
              }));
        });
  }

  void _chapters(BuildContext context) {
    final theme = Theme.of(context);

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
                      element.bookName ==
                      context.read<LocalState>().book.bookName)
                  .map((e) => e.chapter)
                  .toSet()
                  .length,
              itemBuilder: ((context, index) {
                return GestureDetector(
                  onTap: () {
                    context.read<LocalState>().chapter = index + 1;

                    itemScrollController.jumpTo(
                        index: context
                            .read<LocalState>()
                            .version
                            .books!
                            .indexWhere((element) =>
                                element.bookName ==
                                    context.read<LocalState>().book.bookName &&
                                element.chapter == index + 1));

                    Navigator.pop(context);
                  },
                  child: Text(
                    (index + 1).toString(),
                     style: theme.textTheme.bodySmall /*const TextStyle(
                        color: Color.fromARGB(255, 196, 211, 255)), */
                  ),
                );
              }));
        });
  }

  void _verses(BuildContext context) {
    final theme = Theme.of(context);
    showModalBottomSheet(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(20.0),
              topRight: const Radius.circular(20.0)),
        ),
        context: context,
        builder: (bc) {
          return GridView.builder(
              padding: const EdgeInsets.only(left: 40, top: 30),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5),
              itemCount: Provider.of<LocalState>(context, listen: false)
                  .version
                  .books!
                  .where((element) =>
                      element.bookName ==
                          context.read<LocalState>().book.bookName &&
                      element.chapter == context.read<LocalState>().chapter)
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
                    itemScrollController.jumpTo(
                        index: context
                            .read<LocalState>()
                            .version
                            .books!
                            .indexWhere((element) =>
                                element.bookName ==
                                    context.read<LocalState>().book.bookName &&
                                element.chapter ==
                                    context.read<LocalState>().chapter &&
                                element.verse == index + 1));
                    Navigator.pop(context);
                  },
                  child: Text(
                    (index + 1).toString(), style: theme.textTheme.bodySmall
                    /* style: const TextStyle(
                        color: Color.fromARGB(255, 196, 211, 255)), */
                  ),
                );
              }));
        });
  }
}
