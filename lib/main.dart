import 'package:flutter/material.dart';
import 'package:flutter_portal/flutter_portal.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:marvel_app_dengan_riverpod/provider/provider.dart';
import 'package:marvel_app_dengan_riverpod/repository/fake_marvel.dart';
import 'package:marvel_app_dengan_riverpod/screens/character_details.dart';
import 'package:marvel_app_dengan_riverpod/screens/home_page.dart';

void main() {
  runApp(
    const ProviderScope(
      // uncomment to mock the HTTP requests

      // overrides: [dioProvider.overrideWithValue(FakeDio(null))],
      child: MyApp(),
    ),
  );
}

class MyApp extends HookConsumerWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      theme: ThemeData(primarySwatch: Colors.red),
      builder: (context, child) {
        return _Unfocus(
          child: child!,
        );
      },
      home: const Portal(child: Home()),
      onGenerateRoute: (settings) {
        if (settings.name == null) {
          return null;
        }
        final split = settings.name!.split('/');
        Widget? result;
        if (settings.name!.startsWith('/characters/') && split.length == 3) {
          result = ProviderScope(
            overrides: [
              selectedCharacterId.overrideWithValue(split.last),
            ],
            child: const CharacterView(),
          );
        }

        if (result == null) {
          return null;
        }
        return MaterialPageRoute<void>(builder: (context) => result!);
      },
      routes: {
        '/character': (c) => const CharacterView(),
      },
    );
  }
}

class _Unfocus extends StatelessWidget {
  const _Unfocus({
    Key? key,
    required this.child,
  }) : super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: child,
    );
  }
}
