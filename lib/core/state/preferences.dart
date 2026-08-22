import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers.dart';
import '../mock/db.dart';

enum ThemeModePref { light, dark, system }

class PreferencesState {
  const PreferencesState({this.language = 'en', this.themeMode = ThemeModePref.system});

  final String language;
  final ThemeModePref themeMode;

  PreferencesState copyWith({String? language, ThemeModePref? themeMode}) =>
      PreferencesState(language: language ?? this.language, themeMode: themeMode ?? this.themeMode);

  Map<String, dynamic> toJson() => {'language': language, 'themeMode': themeMode.name};

  static PreferencesState fromJson(Map<String, dynamic>? j) => PreferencesState(
        language: (j?['language'] as String?) ?? 'en',
        themeMode: switch (j?['themeMode'] as String?) {
          'light' => ThemeModePref.light,
          'dark' => ThemeModePref.dark,
          _ => ThemeModePref.system,
        },
      );
}

ThemeMode flutterThemeMode(ThemeModePref pref) => switch (pref) {
      ThemeModePref.light => ThemeMode.light,
      ThemeModePref.dark => ThemeMode.dark,
      ThemeModePref.system => ThemeMode.system,
    };

const _prefsKey = 'finovault.prefs.v1';

/// Preloaded in main() before runApp so the first frame already has the
/// user's language/theme.
final initialPreferencesProvider = Provider<PreferencesState>((ref) => const PreferencesState());

class PreferencesController extends Notifier<PreferencesState> {
  @override
  PreferencesState build() => ref.read(initialPreferencesProvider);

  Future<void> _persist() async {
    await ref.read(kvStoreProvider).setString(_prefsKey, jsonEncode(state.toJson()));
  }

  Future<void> setLanguage(String language) async {
    state = state.copyWith(language: language);
    await _persist();
  }

  Future<void> setThemeMode(ThemeModePref mode) async {
    state = state.copyWith(themeMode: mode);
    await _persist();
  }
}

final preferencesProvider =
    NotifierProvider<PreferencesController, PreferencesState>(PreferencesController.new);

PreferencesState loadInitialPreferences(KvStore store) {
  try {
    final raw = store.getString(_prefsKey);
    return PreferencesState.fromJson(
        raw == null ? null : jsonDecode(raw) as Map<String, dynamic>);
  } catch (_) {
    return const PreferencesState();
  }
}
