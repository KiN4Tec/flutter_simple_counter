import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:simple_counter/settings.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<SettingsManager>(
      create: (context) => SettingsManager(),
      child: MaterialApp(
        title: 'Simple Counter',
        themeMode: ThemeMode.system,
        theme: ThemeData.light(useMaterial3: true),
        darkTheme: ThemeData.dark(useMaterial3: true),
        home: const HomePage(),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _counter = 1;

  void _incrementCounter() {
    setState(() {
      _counter < 9 ? _counter++ : _counter = 1;
    });
  }

  void _resetCounter() {
    setState(() {
      _counter = 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
      floatingActionButton: FloatingActionButton(
        foregroundColor: Provider.of<SettingsManager>(context).getColor(SettingsItemKey.foregroundColor),
        backgroundColor: Provider.of<SettingsManager>(context).getColor(SettingsItemKey.backgroundColor),
        elevation: 0,
        child: const Icon(Icons.settings),
        onPressed: () => Navigator.of(context).push<void>(
          MaterialPageRoute<void>(
            builder: (BuildContext context) => const SettingsPage(),
          ),
        ),
      ),
      body: InkWell(
        onTap: _incrementCounter,
        onLongPress: _resetCounter,
        child: ColoredBox(
          color: Provider.of<SettingsManager>(context).getColor(SettingsItemKey.backgroundColor),
          child: Center(
            child: Text(
              '$_counter',
              style: TextStyle(
                color: Provider.of<SettingsManager>(context).getColor(SettingsItemKey.foregroundColor),
                fontWeight: FontWeight.w400,
                fontSize: 600,
                height: 0.65,
              ),
              textScaler: TextScaler.noScaling,
              maxLines: 1,
              textDirection: TextDirection.ltr,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
