import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/error_handler.dart';
import 'data/local_store.dart';
import 'services/notification_service.dart';
import 'state/app_state.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setupErrorHandlers();

  ErrorWidget.builder = (details) =>
      AppErrorWidget(message: details.exceptionAsString());

  final store = await LocalStore.create();
  await NotificationService.instance.init();
  runApp(
    ProviderScope(
      overrides: [
        localStoreProvider.overrideWithValue(store),
      ],
      child: const PregnancyTrackerApp(),
    ),
  );
}
