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
      _genderValue = prefs.getString('ff_genderValue') ?? _genderValue;
    });
    _safeInit(() {
      _ageValue = prefs.getInt('ff_ageValue') ?? _ageValue;
    });
    _safeInit(() {
      _heightValue = prefs.getInt('ff_heightValue') ?? _heightValue;
    });
    _safeInit(() {
      _weightValue = prefs.getInt('ff_weightValue') ?? _weightValue;
    });
    _safeInit(() {
      _userTitle = prefs.getString('ff_userTitle') ?? _userTitle;
    });
    _safeInit(() {
      _userQuery = prefs.getString('ff_userQuery') ?? _userQuery;
    });
  }

  void update(VoidCallback callback) {
    callback();
    notifyListeners();
  }

  late SharedPreferences prefs;

  String _genderValue = '';
  String get genderValue => _genderValue;
  set genderValue(String value) {
    _genderValue = value;
    prefs.setString('ff_genderValue', value);
  }

  int _ageValue = 18;
  int get ageValue => _ageValue;
  set ageValue(int value) {
    _ageValue = value;
    prefs.setInt('ff_ageValue', value);
  }

  int _heightValue = 140;
  int get heightValue => _heightValue;
  set heightValue(int value) {
    _heightValue = value;
    prefs.setInt('ff_heightValue', value);
  }

  int _weightValue = 30;
  int get weightValue => _weightValue;
  set weightValue(int value) {
    _weightValue = value;
    prefs.setInt('ff_weightValue', value);
  }

  bool _isRecording = false;
  bool get isRecording => _isRecording;
  set isRecording(bool value) {
    _isRecording = value;
  }

  int _whatClicked = 0;
  int get whatClicked => _whatClicked;
  set whatClicked(int value) {
    _whatClicked = value;
  }

  String _typedMessage = '';
  String get typedMessage => _typedMessage;
  set typedMessage(String value) {
    _typedMessage = value;
  }

  bool _isTranslate = false;
  bool get isTranslate => _isTranslate;
  set isTranslate(bool value) {
    _isTranslate = value;
  }

  String _userTitle = '';
  String get userTitle => _userTitle;
  set userTitle(String value) {
    _userTitle = value;
    prefs.setString('ff_userTitle', value);
  }

  String _userQuery = '';
  String get userQuery => _userQuery;
  set userQuery(String value) {
    _userQuery = value;
    prefs.setString('ff_userQuery', value);
  }
}

void _safeInit(Function() initializeField) {
  try {
    initializeField();
  } catch (_) {}
}

Future<void> _safeInitAsync(Function() initializeField) async {
  try {
    await initializeField();
  } catch (_) {}
}
