import 'package:bayland_review/bayland_review.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final t0 = DateTime.utc(2026, 11, 1);
  final calls = <String>[];

  setUp(() {
    SharedPreferencesAsyncPlatform.instance = InMemorySharedPreferencesAsync.empty();
    calls.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
        const MethodChannel('dev.britannio.in_app_review'), (call) async {
      calls.add(call.method);
      return call.method == 'isAvailable' ? true : null;
    });
  });

  test('noteGoodMoment keeps the state and asks once the rules allow', () async {
    final review = StoreReview(store: InAppReview.instance);
    final prefs = SharedPreferencesAsync();
    for (var i = 0; i < 5; i++) {
      await review.noteGoodMoment(prefs: prefs, now: t0);
    }
    expect(calls, isEmpty, reason: 'not on the first day');
    await review.noteGoodMoment(prefs: prefs, now: t0.add(const Duration(days: 3)));
    expect(calls, contains('requestReview'));
    final state = await prefs.getString(StoreReview.prefsKey);
    expect(state, contains('"asks":1'));
    expect(state, contains('"moments":0'));
  });
}
