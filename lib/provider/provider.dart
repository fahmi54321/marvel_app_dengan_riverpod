import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:marvel_app_dengan_riverpod/model/configuration.dart';
import 'package:marvel_app_dengan_riverpod/model/home.dart';
import 'package:marvel_app_dengan_riverpod/model/marvel.dart';
import 'package:marvel_app_dengan_riverpod/repository/marvel.dart';
import 'package:marvel_app_dengan_riverpod/utlis/expection.dart';

final configurationsProvider = FutureProvider<Configuration>((_) async {
  final content = json.decode(
    await rootBundle.loadString('assets/configurations.json'),
  ) as Map<String, Object?>;

  return Configuration.fromJson(content);
});

final dioProvider = Provider((ref) => Dio());

final repositoryProvider = Provider(MarvelRepository.new);

final characterPages = FutureProvider.autoDispose
    .family<MarvelListCharactersResponse, CharacterPagination>(
  (ref, meta) async {
    final cancelToken = CancelToken();
    ref.onDispose(cancelToken.cancel);

    await Future<void>.delayed(const Duration(milliseconds: 250));
    if (cancelToken.isCancelled) throw AbortedException();

    final repository = ref.watch(repositoryProvider);
    final charactersResponse = await repository.fetchCharacters(
      offset: meta.page * kCharactersPageLimit,
      limit: kCharactersPageLimit,
      nameStartsWith: meta.name,
      cancelToken: cancelToken,
    );
    return charactersResponse;
  },
);

final charactersCount =
    Provider.autoDispose.family<AsyncValue<int>, String>((ref, name) {
  final meta = CharacterPagination(page: 0, name: name);

  return ref.watch(characterPages(meta)).whenData((value) => value.totalCount);
});

final characterAtIndex = Provider.autoDispose
    .family<AsyncValue<Character>, CharacterOffset>((ref, query) {
  final offsetInPage = query.offset % kCharactersPageLimit;

  final meta = CharacterPagination(
    page: query.offset ~/ kCharactersPageLimit,
    name: query.name,
  );

  return ref.watch(characterPages(meta)).whenData(
        (value) => value.characters[offsetInPage],
      );
});

final characterIndex = Provider<int>((ref) => throw UnimplementedError());

final selectedCharacterId = Provider<String>((ref) {
  throw UnimplementedError();
});

final character =
    FutureProvider.autoDispose.family<Character, String>((ref, id) async {
  // The user used a deep-link to land in the Character page, so we fetch
  // the Character individually.

  // Cancel the HTTP request if the user leaves the detail page before
  // the request completes.
  final cancelToken = CancelToken();
  ref.onDispose(cancelToken.cancel);

  final repository = ref.watch(repositoryProvider);
  final character = await repository.fetchCharacter(
    id,
    cancelToken: cancelToken,
  );

  /// Cache the Character once it was successfully obtained.
  ref.keepAlive();
  return character;
});
