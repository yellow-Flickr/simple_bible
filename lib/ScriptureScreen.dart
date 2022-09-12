import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:simple_bible/KjvModel.dart';

class ScriptureScreen extends StatelessWidget {
  final List<Kjv> kjv;
  const ScriptureScreen({Key? key, required this.kjv}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 20, 6, 46),
        elevation: 0,
        title: Text(
          '${kjv.first.bookName} ${kjv.first.chapter}',
          style: const TextStyle(color: Color.fromARGB(255, 196, 211, 255)),
        ),
      ),
      body: ListView.builder(
          itemCount: kjv.length,
          itemBuilder: ((context, index) => Card(
                semanticContainer: false,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  margin: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          '${kjv[index].bookId} ${kjv[index].chapter}:${kjv[index].verse}',
                          style: const TextStyle(
                              color: Colors.red, fontWeight: FontWeight.bold)),
                      Text(kjv[index].text,
                          softWrap: true,
                          style: const TextStyle(color: Colors.black))
                    ],
                  ),
                ),
              ))),
    );
  }
}
