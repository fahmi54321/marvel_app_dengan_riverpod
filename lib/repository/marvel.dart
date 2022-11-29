import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:crypto/crypto.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:marvel_app_dengan_riverpod/model/marvel.dart';
import 'package:marvel_app_dengan_riverpod/provider/provider.dart';

class MarvelRepository {
  MarvelRepository(
    this.ref, {
    int Function()? getCurrentTimestamp,
  }) : _getCurrentTimestamp = getCurrentTimestamp ??
            (() => DateTime.now().millisecondsSinceEpoch);

  final Ref ref;
  final int Function() _getCurrentTimestamp;
  final _characterCache = <String, Character>{};

  Future<MarvelListCharactersResponse> fetchCharacters({
    required int offset,
    int? limit,
    String? nameStartsWith,
    CancelToken? cancelToken,
  }) async {
    final cleanNameFilter = nameStartsWith?.trim();

    final response = await _get(
      'characters',
      queryParameters: <String, Object?>{
        'offset': offset,
        if (limit != null) 'limit': limit,
        if (cleanNameFilter != null && cleanNameFilter.isNotEmpty)
          'nameStartsWith': cleanNameFilter,
      },
      cancelToken: cancelToken,
    );

    final result = MarvelListCharactersResponse(
      characters: response.data.results.map((e) {
        return Character.fromJson(e);
      }).toList(growable: false),
      totalCount: response.data.total,
    );

    for (final character in result.characters) {
      _characterCache[character.id.toString()] = character;
    }

    return result;
  }

  Future<Character> fetchCharacter(
    String id, {
    CancelToken? cancelToken,
  }) async {
    if (_characterCache.containsKey(id)) {
      return _characterCache[id]!;
    }

    final response = await _get(
      'characters/$id',
      cancelToken: cancelToken,
    );
    return Character.fromJson(
      response.data.results.single,
    );
  }

  Future<MarvelResponse> _get(
    String path, {
    Map<String, Object?>? queryParameters,
    CancelToken? cancelToken,
  }) async {
    final configs = await ref.read(
      configurationsProvider.future,
    );

    final timestamp = _getCurrentTimestamp();
    final hash = md5
        .convert(
          utf8.encode('$timestamp${configs.privateKey}${configs.publicKey}'),
        )
        .toString();

    final result = await ref.read(dioProvider).get<Map<String, Object?>>(
      'https://gateway.marvel.com/v1/public/$path',
      cancelToken: cancelToken,
      queryParameters: <String, Object?>{
        'apikey': configs.publicKey,
        'ts': timestamp,
        'hash': hash,
        ...?queryParameters,
      },
    );
    return MarvelResponse.fromJson(
      Map<String, Object>.from(
        result.data!,
      ),
    );
  }
}
