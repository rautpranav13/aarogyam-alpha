// test/unit/schema_util_test.dart
// Unit tests for Firestore / schema utilities

import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:aarogyam/core/utils/firestore_helpers.dart';

void main() {
  group('castToType', () {
    test('casts int to int', () {
      expect(castToType<int>(42), equals(42));
    });

    test('casts string to string', () {
      expect(castToType<String>('hello'), equals('hello'));
    });

    test('returns null for incompatible type cast', () {
      // A string passed as int should return null
      expect(castToType<int>('not a number'), isNull);
    });

    test('returns null for null input', () {
      expect(castToType<int>(null), isNull);
    });

    test('casts double to double', () {
      expect(castToType<double>(3.14), closeTo(3.14, 0.001));
    });

    test('casts bool to bool', () {
      expect(castToType<bool>(true), isTrue);
    });
  });

  group('Timestamp', () {
    test('Timestamp.fromDate round-trips correctly', () {
      final dt = DateTime(2024, 6, 15, 10, 30, 0);
      final ts = Timestamp.fromDate(dt);
      final back = ts.toDate();
      expect(back.year, equals(2024));
      expect(back.month, equals(6));
      expect(back.day, equals(15));
    });
  });

  group('FakeFirebaseFirestore', () {
    late FakeFirebaseFirestore fakeFirestore;

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
    });

    test('write and read a document', () async {
      await fakeFirestore
          .collection('users')
          .doc('user1')
          .set({'name': 'Aarogyam', 'age': 25});

      final doc =
          await fakeFirestore.collection('users').doc('user1').get();
      expect(doc.exists, isTrue);
      expect(doc.data()?['name'], equals('Aarogyam'));
      expect(doc.data()?['age'], equals(25));
    });

    test('document does not exist before creation', () async {
      final doc =
          await fakeFirestore.collection('users').doc('nonexistent').get();
      expect(doc.exists, isFalse);
    });

    test('collection stream emits documents correctly', () async {
      // Add document first, then read stream
      await fakeFirestore
          .collection('medications')
          .add({'name': 'Paracetamol', 'dosage': '500mg'});
      await fakeFirestore
          .collection('medications')
          .add({'name': 'Ibuprofen', 'dosage': '400mg'});

      final snapshot =
          await fakeFirestore.collection('medications').get();
      expect(snapshot.docs.length, equals(2));
      final names = snapshot.docs.map((d) => d.data()['name']).toList();
      expect(names, containsAll(['Paracetamol', 'Ibuprofen']));
    });

    test('delete removes document', () async {
      await fakeFirestore.collection('test').doc('d1').set({'x': 1});
      await fakeFirestore.collection('test').doc('d1').delete();
      final doc = await fakeFirestore.collection('test').doc('d1').get();
      expect(doc.exists, isFalse);
    });
  });
}
