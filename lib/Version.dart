import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:simple_bible/KjvModel.dart';
import 'package:simple_bible/main.dart';

class Version extends StatelessWidget {
  Map<String, List<Kjv>> versions;
  Version({Key? key, required this.versions}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 20, 6, 46),
        body: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              GestureDetector(
                onTap: (() {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: ((context) =>
                              MyHomePage(kjv: versions['Akuapem'] ?? []))));
                }),
                child: Container(
                  width: width * 0.4,
                  height: width * 0.4,
                  decoration: BoxDecoration(
                    border: Border.all(
                        width: 5, color: const Color.fromARGB(214, 218, 16, 2)),
                    borderRadius: BorderRadius.circular(10),
                    shape: BoxShape.rectangle,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'AK',
                        textScaleFactor: 5,
                        style:
                            TextStyle(color: Color.fromARGB(214, 218, 16, 2)),
                      ),
                      Text(
                        Utf8Decoder(allowMalformed: true).convert("\u025b".codeUnits
                          // Utf8Encoder()
                          //   .convert('Akuampem Twi Twerɛ Kronkron')
                            ),
                        style: const TextStyle(
                            color: Color.fromARGB(255, 196, 211, 255),
                            fontSize: 20),
                      )
                    ],
                  ),
                ),
              ),
              GestureDetector(
                onTap: (() {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: ((context) =>
                              MyHomePage(kjv: versions['KJV'] ?? []))));
                }),
                child: Container(
                  width: width * 0.4,
                  height: width * 0.4,
                  decoration: BoxDecoration(
                    border: Border.all(
                        width: 5, color: const Color.fromARGB(214, 218, 16, 2)),
                    borderRadius: BorderRadius.circular(10),
                    shape: BoxShape.rectangle,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text(
                        'KJV',
                        textScaleFactor: 5,
                        style:
                            TextStyle(color: Color.fromARGB(214, 218, 16, 2)),
                      ),
                      Text(
                        'King James Version',
                        softWrap: true,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Color.fromARGB(255, 196, 211, 255),
                            fontSize: 20),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
