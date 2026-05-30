import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:arrow_puzzle/main.dart';
import 'package:arrow_puzzle/services/prefs_provider.dart';

void main() {
  testWidgets('Menu screen renders title and Play button', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
        child: const ArrowPuzzleApp(),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('ARROW PUZZLE'), findsOneWidget);
    expect(find.text('PLAY'), findsOneWidget);
    expect(find.text('LEVELS'), findsOneWidget);
    expect(find.text('DAILY'), findsOneWidget);
  });
}
