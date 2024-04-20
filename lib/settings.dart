import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

enum SettingsItemType {
  color,
}

enum SettingsItemKey {
  foregroundColor,
  backgroundColor
}

class SettingsItem extends StatelessWidget {
  final SettingsItemType itemType;
  final SettingsItemKey itemKey;
  final String caption;

  const SettingsItem({super.key, required this.itemType, required this.itemKey, required this.caption});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(23),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(caption),
          SettingsItemActuator(
            itemType: itemType,
            itemKey: itemKey,
          ),
        ],
      ),
    );
  }
}

class SettingsItemActuator extends StatelessWidget {
  final SettingsItemType itemType;
  final SettingsItemKey itemKey;

  const SettingsItemActuator({super.key, required this.itemType, required this.itemKey});

  @override
  Widget build(BuildContext context) {
    switch (itemType) {
      case SettingsItemType.color:
        return MaterialButton(
          color: Provider.of<SettingsManager>(context).getColor(itemKey),
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15.0))),
          onPressed: () => showDialog(
            context: context,
            builder: (BuildContext dialogContext) {
              Color tempColor = Provider.of<SettingsManager>(dialogContext, listen: false).getColor(itemKey);
              return AlertDialog(
                title: const Text('Pick a color!'),
                content: MaterialPicker(
                  pickerColor: tempColor,
                  onColorChanged: (Color newColor) {
                    tempColor = newColor;
                  },
                ),
                actions: <Widget>[
                  ElevatedButton(
                    child: const Text('Cancel'),
                    onPressed: () {
                      Navigator.of(dialogContext).pop();
                    },
                  ),
                  ElevatedButton(
                    child: const Text('Confirm'),
                    onPressed: () {
                      Provider.of<SettingsManager>(dialogContext, listen: false).setColor(dialogContext, itemKey, tempColor);
                      Navigator.of(dialogContext).pop();
                    },
                  )
                ],
              );
            },
          ),
        );
    }
  }
}

class SettingsManager extends ChangeNotifier {
  SettingsManager({
    Color fallbackForegroundColor = Colors.white,
    Color fallbackBackgroundColor = Colors.black,
  }) {
    foregroundColor = fallbackForegroundColor;
    backgroundColor = fallbackBackgroundColor;
    SharedPreferences.getInstance().then((instance) {
      settingsStorage = instance;
      foregroundColor = Color(settingsStorage.getInt(SettingsItemKey.foregroundColor.toString()) ?? fallbackForegroundColor.value);
      backgroundColor = Color(settingsStorage.getInt(SettingsItemKey.backgroundColor.toString()) ?? fallbackBackgroundColor.value);
      isLoaded = true;
      notifyListeners();
    });
  }

  late final SharedPreferences settingsStorage;
  bool isLoaded = false;

  late Color foregroundColor;
  late Color backgroundColor;

  Color getColor(SettingsItemKey colorKey) {
    switch (colorKey) {
      case SettingsItemKey.foregroundColor:
        return foregroundColor;
      case SettingsItemKey.backgroundColor:
        return backgroundColor;
    }
  }

  void setColor(BuildContext? context, SettingsItemKey colorKey, Color colorValue) {
    final String key = colorKey.toString();

    settingsStorage.setInt(key, colorValue.value).onError(
      (error, stackTrace) {
        if (context != null) {
          showDialog(
            context: context,
            builder: (BuildContext newContext) => AlertDialog(
              title: const Text("Sorry"),
              content: const Text("We could not save your preferences!"),
              actions: <Widget>[
                ElevatedButton(
                  child: const Text('Got it'),
                  onPressed: () {
                    Navigator.of(newContext).pop();
                  },
                ),
              ],
            ),
          );
        }

        debugPrint("Error:\n${error.toString()}\n\n\n");
        debugPrint("Stack Trace:\n${stackTrace.toString()}\n\n\n");

        return true;
      },
    );

    switch (colorKey) {
      case SettingsItemKey.foregroundColor:
        foregroundColor = colorValue;
        break;
      case SettingsItemKey.backgroundColor:
        backgroundColor = colorValue;
        break;
    }

    notifyListeners();
  }
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
      ),
      body: ListView(
        children: const <SettingsItem>[
          SettingsItem(
            itemType: SettingsItemType.color,
            itemKey: SettingsItemKey.foregroundColor,
            caption: "Text Color",
          ),
          SettingsItem(
            itemType: SettingsItemType.color,
            itemKey: SettingsItemKey.backgroundColor,
            caption: "Background Color",
          ),
        ],
      ),
    );
  }
}
