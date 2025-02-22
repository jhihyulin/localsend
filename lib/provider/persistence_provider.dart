import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localsend_app/constants.dart';
import 'package:localsend_app/gen/strings.g.dart';
import 'package:localsend_app/model/receive_history_entry.dart';
import 'package:localsend_app/util/alias_generator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

final persistenceProvider = Provider<PersistenceService>((ref) {
  throw Exception('persistenceProvider not initialized');
});

// Version of the storage
const _version = 'ls_version';

// Received file history
const _receiveHistory = 'ls_receive_history';

// Settings
const _showToken = 'ls_show_token';
const _aliasKey = 'ls_alias';
const _themeKey = 'ls_theme';
const _localeKey = 'ls_locale';
const _portKey = 'ls_port';
const _multicastGroupKey = 'ls_multicast_group';
const _destinationKey = 'ls_destination';
const _saveToGallery = 'ls_save_to_gallery';
const _quickSave = 'ls_quick_save';
const _minimizeToTray = 'ls_minimize_to_tray';
const _autoStartLaunchMinimized = 'ls_auto_start_launch_minimized';
const _https = 'ls_https';

/// This service abstracts the persistence layer.
class PersistenceService {
  final SharedPreferences _prefs;

  PersistenceService._(this._prefs);

  static Future<PersistenceService> initialize() async {
    final prefs = await SharedPreferences.getInstance();

    if (prefs.getInt(_version) == null) {
      await prefs.setInt(_version, 1);
    }

    if (prefs.getString(_showToken) == null) {
      await prefs.setString(_showToken, const Uuid().v4());
    }

    if (prefs.getString(_aliasKey) == null) {
      await prefs.setString(_aliasKey, generateRandomAlias());
    }

    if (prefs.getString(_themeKey) == null) {
      await prefs.setString(_themeKey, ThemeMode.system.name);
    }

    return PersistenceService._(prefs);
  }

  List<ReceiveHistoryEntry> getReceiveHistory() {
    final historyRaw = _prefs.getStringList(_receiveHistory) ?? [];
    return historyRaw.map((entry) => ReceiveHistoryEntry.fromJson(jsonDecode(entry))).toList();
  }

  Future<void> setReceiveHistory(List<ReceiveHistoryEntry> entries) async {
    final historyRaw = entries.map((entry) => jsonEncode(entry.toJson())).toList();
    await _prefs.setStringList(_receiveHistory, historyRaw);
  }

  String getShowToken() {
    return _prefs.getString(_showToken)!;
  }

  String getAlias() {
    return _prefs.getString(_aliasKey) ?? generateRandomAlias();
  }

  Future<void> setAlias(String alias) async {
    await _prefs.setString(_aliasKey, alias);
  }

  ThemeMode getTheme() {
    final value = _prefs.getString(_themeKey);
    if (value == null) {
      return ThemeMode.system;
    }
    return ThemeMode.values.firstWhereOrNull((theme) => theme.name == value) ?? ThemeMode.system;
  }

  Future<void> setTheme(ThemeMode theme) async {
    await _prefs.setString(_themeKey, theme.name);
  }

  AppLocale? getLocale() {
    final value = _prefs.getString(_localeKey);
    if (value == null) {
      return null;
    }
    return AppLocale.values.firstWhereOrNull((locale) => locale.languageTag == value);
  }

  Future<void> setLocale(AppLocale? locale) async {
    if (locale == null) {
      await _prefs.remove(_localeKey);
    } else {
      await _prefs.setString(_localeKey, locale.languageTag);
    }
  }

  int getPort() {
    return _prefs.getInt(_portKey) ?? defaultPort;
  }

  Future<void> setPort(int port) async {
    await _prefs.setInt(_portKey, port);
  }

  String getMulticastGroup() {
    return _prefs.getString(_multicastGroupKey) ?? defaultMulticastGroup;
  }

  Future<void> setMulticastGroup(String group) async {
    await _prefs.setString(_multicastGroupKey, group);
  }

  String? getDestination() {
    return _prefs.getString(_destinationKey);
  }

  Future<void> setDestination(String? destination) async {
    if (destination == null) {
      await _prefs.remove(_destinationKey);
    } else {
      await _prefs.setString(_destinationKey, destination);
    }
  }

  bool isSaveToGallery() {
    return _prefs.getBool(_saveToGallery) ?? true;
  }

  Future<void> setSaveToGallery(bool saveToGallery) async {
    await _prefs.setBool(_saveToGallery, saveToGallery);
  }

  bool isQuickSave() {
    return _prefs.getBool(_quickSave) ?? false;
  }

  Future<void> setQuickSave(bool quickSave) async {
    await _prefs.setBool(_quickSave, quickSave);
  }

  bool isMinimizeToTray() {
    return _prefs.getBool(_minimizeToTray) ?? false;
  }

  Future<void> setMinimizeToTray(bool minimizeToTray) async {
    await _prefs.setBool(_minimizeToTray, minimizeToTray);
  }

  bool isAutoStartLaunchMinimized() {
    return _prefs.getBool(_autoStartLaunchMinimized) ?? true;
  }

  Future<void> setAutoStartLaunchMinimized(bool launchMinimized) async {
    await _prefs.setBool(_autoStartLaunchMinimized, launchMinimized);
  }

  bool isHttps() {
    return _prefs.getBool(_https) ?? true;
  }

  Future<void> setHttps(bool https) async {
    await _prefs.setBool(_https, https);
  }
}
