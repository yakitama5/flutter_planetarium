import 'package:app_planetarium/sun.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Ticker ticker;
  double elapsedSeconds = 0;

  @override
  void initState() {
    ticker = Ticker((elapsed) {
      setState(() {
        elapsedSeconds = elapsed.inMilliseconds.toDouble() / 1000;
      });
    });
    ticker.start();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Scene Examples',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text('Planetarium'),
        ),
        body: ExampleSun(elapsedSeconds: elapsedSeconds),
      ),
    );
  }
}
