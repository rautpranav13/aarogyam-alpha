// random_data_util.dart — compatibility shim.
// Provides random data generators used by FF-generated code.

import 'dart:math';

final _random = Random();

/// Returns a random integer between [min] and [max] (inclusive).
int randomInteger(int min, int max) =>
    min + _random.nextInt(max - min + 1);

/// Returns a random double between [min] and [max].
double randomDouble(double min, double max) =>
    min + _random.nextDouble() * (max - min);

/// Returns a random boolean.
bool randomBool() => _random.nextBool();

/// Returns a random string of [length] characters.
String randomString(int min, int max,
    {bool lowercaseActive = true,
    bool uppercaseActive = false,
    bool numbersActive = false}) {
  final length = randomInteger(min, max);
  const lower = 'abcdefghijklmnopqrstuvwxyz';
  const upper = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  const numbers = '0123456789';
  var chars = lowercaseActive ? lower : '';
  if (uppercaseActive) chars += upper;
  if (numbersActive) chars += numbers;
  if (chars.isEmpty) chars = lower;
  return List.generate(length, (_) => chars[_random.nextInt(chars.length)])
      .join();
}
