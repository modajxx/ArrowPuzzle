import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Synchronous SharedPreferences provider. Overridden in `main()` after
/// preloading the instance, so any service depending on prefs can be a
/// regular sync [Provider].
final sharedPreferencesProvider = Provider<SharedPreferences>((_) {
  throw UnimplementedError(
    'sharedPreferencesProvider must be overridden in main() with a '
    'preloaded SharedPreferences instance.',
  );
});
