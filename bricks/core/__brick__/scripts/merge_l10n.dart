// ignore_for_file: avoid_print
/// Merges all per-feature ARB files into lib/l10n/app_{locale}.arb.
///
/// Run this script whenever you add or change strings in any feature's
/// l10n/<feature>_{locale}.arb file:
///
///   dart run scripts/merge_l10n.dart && flutter gen-l10n
///
/// The script:
///   1. Finds all lib/features/*/l10n/*_{locale}.arb files.
///   2. Parses each one and groups them by locale.
///   3. Inserts the collected keys into lib/l10n/app_{locale}.arb immediately
///      before the "@@x-mason-anchor" sentinel key (existing keys are
///      updated in-place; new keys are appended before the anchor).
///   4. Writes the updated files back and prints a summary.
///
/// Safe to re-run — existing keys are updated, not duplicated.
library;

import 'dart:convert';
import 'dart:io';

void main() {
  final projectRoot = _findProjectRoot();
  if (projectRoot == null) {
    print('❌  Could not find project root (no pubspec.yaml found).');
    exit(1);
  }

  // ── Scan feature ARBs ──────────────────────────────────────────────────────
  final featuresDir = Directory('$projectRoot/lib/features');
  if (!featuresDir.existsSync()) {
    print('⚠️  lib/features/ not found — nothing to merge.');
    return;
  }

  final featureArbs = featuresDir
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.contains('/l10n/') && f.path.endsWith('.arb'))
      .toList()
    ..sort((a, b) => a.path.compareTo(b.path));

  if (featureArbs.isEmpty) {
    print('⚠️  No feature *.arb files found — nothing to merge.');
    return;
  }

  final localeRegex = RegExp(r'_([a-z]{2,3}(_[a-zA-Z0-9_]+)*)\.arb$');
  final arbsByLocale = <String, List<File>>{};

  for (final arb in featureArbs) {
    final filename = arb.uri.pathSegments.last;
    final match = localeRegex.firstMatch(filename);
    if (match != null) {
      final locale = match.group(1)!;
      arbsByLocale.putIfAbsent(locale, () => []).add(arb);
    } else {
      print('⚠️  Could not extract locale from ${arb.path}, skipping.');
    }
  }

  if (arbsByLocale.isEmpty) {
    print('⚠️  No translatable keys found to merge.');
    return;
  }

  final l10nDir = Directory('$projectRoot/lib/l10n');
  if (!l10nDir.existsSync()) {
    l10nDir.createSync(recursive: true);
  }

  const anchorKey = '@@x-mason-anchor';
  const encoder = JsonEncoder.withIndent('  ');

  for (final entry in arbsByLocale.entries) {
    final locale = entry.key;
    final files = entry.value;

    final baseFile = File('${l10nDir.path}/app_$locale.arb');
    Map<String, dynamic> base = {};

    if (baseFile.existsSync()) {
      try {
        base = json.decode(baseFile.readAsStringSync()) as Map<String, dynamic>;
      } catch (e) {
        print('❌  Failed to parse ${baseFile.path}: $e');
        exit(1);
      }
    }

    if (!base.containsKey(anchorKey)) {
      if (base.isEmpty) {
        base['@@locale'] = locale;
        base[anchorKey] = '__DO_NOT_REMOVE__';
      } else {
        print('❌  ${baseFile.path} is missing the "$anchorKey" sentinel.\n'
            '   Add it back: { "@@x-mason-anchor": "__DO_NOT_REMOVE__" }');
        exit(1);
      }
    }

    // Collect all feature keys for this locale
    final featureKeys = <String, dynamic>{};
    for (final arbFile in files) {
      try {
        final decoded =
            json.decode(arbFile.readAsStringSync()) as Map<String, dynamic>;
        for (final entry in decoded.entries) {
          if (!entry.key.startsWith('@@')) {
            featureKeys[entry.key] = entry.value;
          }
        }
      } catch (e) {
        print('⚠️  Skipping ${arbFile.path}: $e');
      }
    }

    if (featureKeys.isEmpty) continue;

    final existing = Map<String, dynamic>.from(base);
    final merged = <String, dynamic>{};

    for (final baseEntry in existing.entries) {
      if (baseEntry.key == anchorKey) {
        for (final fk in featureKeys.entries) {
          if (!merged.containsKey(fk.key)) {
            merged[fk.key] = fk.value;
          }
        }
      }
      merged[baseEntry.key] = featureKeys.containsKey(baseEntry.key)
          ? featureKeys[baseEntry.key]
          : baseEntry.value;
    }

    baseFile.writeAsStringSync('${encoder.convert(merged)}\n');
    print('✅  Merged ${featureKeys.length} key(s) from ${files.length} '
        'feature ARB(s) into app_$locale.arb');
  }

  print('');
  print('Next: flutter gen-l10n');
}

/// Walks up from the current directory looking for pubspec.yaml.
String? _findProjectRoot() {
  var dir = Directory.current;
  while (true) {
    if (File('\${dir.path}/pubspec.yaml').existsSync()) return dir.path;
    final parent = dir.parent;
    if (parent.path == dir.path) return null;
    dir = parent;
  }
}
