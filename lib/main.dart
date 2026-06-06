import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'data/local_store.dart';
import 'state/app_state.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final store = await LocalStore.create();
  runApp(
    ProviderScope(
      overrides: [
        localStoreProvider.overrideWithValue(store),
      ],
      child: const PregnancyTrackerApp(),
    ),
  );
}
