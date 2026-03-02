// ignore_for_file: avoid_print
/// Merges all per-feature ARB files into lib/l10n/app_en.arb.
///
/// Run this script whenever you add or change strings in any feature's
/// l10n/<feature>_en.arb file:
///
///   dart run scripts/merge_l10n.dart && flutter gen-l10n
///
/// The script:
///   1. Finds all lib/features/*/l10n/*_en.arb files.
///   2. Parses each one and collects every non-@@ key.
///   3. Inserts the collected keys into lib/l10n/app_en.arb immediately
///      before the "@@x-mason-anchor" sentinel key (existing keys are
///      updated in-place; new keys are appended before the anchor).
///   4. Writes the updated file back and prints a summary.
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

  final baseFile = File('$projectRoot/lib/l10n/app_en.arb');
  if (!baseFile.existsSync()) {
    print(
      '❌  lib/l10n/app_en.arb not found.\n'
      '   Run the core brick first: mason make core',
    );
    exit(1);
  }

  // ── Load base ARB ──────────────────────────────────────────────────────────
  final Map<String, dynamic> base;
  try {
    base = json.decode(baseFile.readAsStringSync()) as Map<String, dynamic>;
  } catch (e) {
    print('❌  Failed to parse lib/l10n/app_en.arb: $e');
    exit(1);
  }

  const anchorKey = '@@x-mason-anchor';
  if (!base.containsKey(anchorKey)) {
    print(
      '❌  lib/l10n/app_en.arb is missing the "$anchorKey" sentinel.\n'
      '   Add it back: { "@@x-mason-anchor": "__DO_NOT_REMOVE__" }',
    );
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
      .where((f) => f.path.contains('/l10n/') && f.path.endsWith('_en.arb'))
      .toList()
    ..sort((a, b) => a.path.compareTo(b.path));

  if (featureArbs.isEmpty) {
    print('⚠️  No feature *_en.arb files found — nothing to merge.');
    return;
  }

  // ── Collect all feature keys ───────────────────────────────────────────────
  final featureKeys = <String, dynamic>{};
  for (final arbFile in featureArbs) {
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

  if (featureKeys.isEmpty) {
    print('⚠️  Feature ARBs contained no translatable keys — nothing merged.');
    return;
  }

  // ── Merge into base ────────────────────────────────────────────────────────
  // Strategy: rebuild the map preserving order.
  //   1. Keep all existing @@ metadata keys at the top (they come before anchor).
  //   2. Keep any non-@@ keys already in base (update their value if feature
  //      has a newer version).
  //   3. Before the anchor, insert any feature keys not yet in base.
  //   4. Preserve the anchor at its position.
  final existing = Map<String, dynamic>.from(base);
  final merged = <String, dynamic>{};

  // Pass 1 — replay base keys; update values from feature where they match
  for (final entry in existing.entries) {
    if (entry.key == anchorKey) {
      // Before the anchor: flush any NEW feature keys not already seen
      for (final fk in featureKeys.entries) {
        if (!merged.containsKey(fk.key)) {
          merged[fk.key] = fk.value;
        }
      }
    }
    // If this key also came from a feature, use the feature value (fresher)
    merged[entry.key] = featureKeys.containsKey(entry.key)
        ? featureKeys[entry.key]
        : entry.value;
  }

  const encoder = JsonEncoder.withIndent('  ');
  baseFile.writeAsStringSync('${encoder.convert(merged)}\n');

  final mergedCount = featureKeys.length;
  print('✅  Merged $mergedCount key(s) from ${featureArbs.length} '
      'feature ARB(s) into lib/l10n/app_en.arb');
  print('');
  print('Next: flutter gen-l10n');
}

/// Walks up from the current directory looking for pubspec.yaml.
String? _findProjectRoot() {
  var dir = Directory.current;
  while (true) {
    if (File('${dir.path}/pubspec.yaml').existsSync()) return dir.path;
    final parent = dir.parent;
    if (parent.path == dir.path) return null;
    dir = parent;
  }
}
