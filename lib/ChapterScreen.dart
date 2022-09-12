import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:simple_bible/KjvModel.dart';
import 'package:simple_bible/ScriptureScreen.dart';

class Chapter extends StatelessWidget {
  final List<Kjv> kjv;

  const Chapter({Key? key, required this.kjv}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 20, 6, 46),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 20, 6, 46),
        elevation: 0,
        title: Text(kjv.first.bookName),
      ),
      body: GridView.builder(
          padding: const EdgeInsets.only(left: 40, top: 30),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5),
          itemCount: kjv.map((e) => e.chapter).toSet().length,
          itemBuilder: ((context, index) {
            return GestureDetector(
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: ((context) => ScriptureScreen(
                            kjv: kjv
                                .where(
                                    (element) => element.chapter == (index + 1))
                                .toList(),
                          )))),
              child: Text(
                (index + 1).toString(),
                style:
                    const TextStyle(color: Color.fromARGB(255, 196, 211, 255)),
              ),
            );
          })),
    );
  }
}
