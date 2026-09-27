// test/unit/base_model_test.dart
// Unit tests for BaseModel lifecycle

import 'package:flutter_test/flutter_test.dart';
import 'package:aarogyam/flutter_flow/flutter_flow_util.dart';

// Concrete implementation for testing
class _TestModel extends BaseModel<StatefulWidget> {
  bool initCalled = false;
  bool disposeCalled = false;
  String? _value;

  @override
  void initState(BuildContext context) {
    initCalled = true;
    _value = 'initialized';
  }

  @override
  void dispose() {
    disposeCalled = true;
    super.dispose();
  }

  String? get value => _value;
  set value(String? v) {
    _value = v;
    notifyListeners();
  }
}

void main() {
  group('BaseModel lifecycle', () {
    testWidgets('createModel returns correct model type',
        (WidgetTester tester) async {
      late _TestModel model;
      await tester.pumpWidget(
        Builder(builder: (ctx) {
          model = createModel(ctx, () => _TestModel());
          return const MaterialApp(home: SizedBox());
        }),
      );
      expect(model, isA<_TestModel>());
    });

    testWidgets('initState is called during createModel',
        (WidgetTester tester) async {
      late _TestModel model;
      await tester.pumpWidget(
        Builder(builder: (ctx) {
          model = createModel(ctx, () => _TestModel());
          return const MaterialApp(home: SizedBox());
        }),
      );
      expect(model.initCalled, isTrue);
    });

    testWidgets('model notifies listeners on value change',
        (WidgetTester tester) async {
      late _TestModel model;
      var notified = false;
      await tester.pumpWidget(
        Builder(builder: (ctx) {
          model = createModel(ctx, () => _TestModel());
          return const MaterialApp(home: SizedBox());
        }),
      );
      model.addListener(() => notified = true);
      model.value = 'changed';
      expect(notified, isTrue);
    });

    test('dispose sets disposeCalled flag', () {
      final model = _TestModel()..initCalled = false;
      model.dispose();
      expect(model.disposeCalled, isTrue);
    });

    test('maybeDispose does not throw when called multiple times', () {
      final model = _TestModel();
      expect(() {
        model.maybeDispose();
        model.maybeDispose();
      }, returnsNormally);
    });
  });
}
