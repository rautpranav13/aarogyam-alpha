import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppState extends ChangeNotifier {
  static AppState _instance = AppState._internal();

  factory AppState() {
    return _instance;
  }

  AppState._internal();

  static void reset() {
    _instance = AppState._internal();
  }

  Future<void> initializePersistedState() async {
    prefs = await SharedPreferences.getInstance();
    _safeInit(() {
      genderValue = prefs.getString('ff_genderValue') ?? genderValue;
    });
    _safeInit(() {
      ageValue = prefs.getInt('ff_ageValue') ?? ageValue;
    });
    _safeInit(() {
      heightValue = prefs.getInt('ff_heightValue') ?? heightValue;
    });
    _safeInit(() {
      weightValue = prefs.getInt('ff_weightValue') ?? weightValue;
    });
    _safeInit(() {
      userTitle = prefs.getString('ff_userTitle') ?? userTitle;
    });
    _safeInit(() {
      userQuery = prefs.getString('ff_userQuery') ?? userQuery;
    });
  }

  void update(VoidCallback callback) {
    callback();
    notifyListeners();
  }

  late SharedPreferences prefs;

  String genderValue = '';

  int ageValue = 18;

  int heightValue = 140;

  int weightValue = 30;

  bool isRecording = false;

  int whatClicked = 0;

  String typedMessage = '';

  bool isTranslate = false;

  String userTitle = '';

  String userQuery = '';
}

void _safeInit(Function() initializeField) {
  try {
    initializeField();
  } catch (_) {}
}

