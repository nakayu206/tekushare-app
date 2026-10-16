import 'dart:async';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tekushare/screens/providers/auth_provider.dart';

/// Firebase Storage 上の写真かどうか（`users/` から始まるパスはStorageのパス）
bool isStoragePath(String path) => path.startsWith('users/');

/// Storage のパスから写真のバイト列を取得する関数。
/// 実装は firebase_providers.dart で注入する（Firebase 非対応環境のテストを壊さないため）。
final storagePhotoLoaderProvider =
    Provider<Future<Uint8List?> Function(String path)>((ref) {
  return (_) async => null;
});

/// 取得した写真をメモリに保持する時間。共有OFF・連携解除が反映されるまでの上限になる。
const storagePhotoCacheTtl = Duration(minutes: 5);

class _CacheEntry {
  _CacheEntry(this.future, this.cachedAt);
  final Future<Uint8List?> future;
  final DateTime cachedAt;
}

/// 写真のメモリキャッシュ。ログインユーザーごとに作り直されるため、
/// ログアウト・アカウント切り替えで破棄される。
final storagePhotoCacheProvider = Provider<Map<String, _CacheEntry>>((ref) {
  ref.watch(authStateProvider.select((a) => a.valueOrNull?.uid));
  return {};
});

/// 写真を表示する。
/// - `users/...` : Storage のパス。ログイン中のユーザー権限で取得するため、
///   連携解除・共有OFFが即座に反映される（長期有効なダウンロードURLを使わない）。
/// - `https://...` : 旧仕様で保存されたダウンロードURL（移行完了までの互換用）
class StoragePhoto extends ConsumerStatefulWidget {
  const StoragePhoto({
    super.key,
    required this.path,
    this.width,
    this.height,
    this.fit,
    this.placeholder,
    this.errorWidget,
  });

  final String path;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final Widget Function(BuildContext, String)? placeholder;
  final Widget Function(BuildContext, String, Object)? errorWidget;

  @override
  ConsumerState<StoragePhoto> createState() => _StoragePhotoState();
}

class _StoragePhotoState extends ConsumerState<StoragePhoto> {
  Future<Uint8List?>? _future;
  Map<String, _CacheEntry>? _cacheMap;
  Timer? _expiryTimer;

  /// ユーザーが切り替わるたびに増やし、FutureBuilder の状態（旧ユーザーの画像）を破棄する
  int _generation = 0;

  @override
  void dispose() {
    _expiryTimer?.cancel();
    super.dispose();
  }

  /// 写真を取得し直し、保持期限が来たら再取得するタイマーを張り直す。
  /// [force] のときはキャッシュを使わず認証付きで取得し直す（権限の再確認）。
  void _refresh({bool force = false}) {
    _future = _load(widget.path, force: force);
    _expiryTimer?.cancel();
    _expiryTimer = Timer(storagePhotoCacheTtl, () {
      if (mounted) setState(() => _refresh(force: true));
    });
  }

  Future<Uint8List?> _load(String path, {bool force = false}) {
    final loader = ref.read(storagePhotoLoaderProvider);
    final cache = ref.read(storagePhotoCacheProvider);
    final cached = cache[path];
    if (!force &&
        cached != null &&
        DateTime.now().difference(cached.cachedAt) < storagePhotoCacheTtl) {
      return cached.future;
    }
    final future = loader(path);
    cache[path] = _CacheEntry(future, DateTime.now());
    // 失敗は再試行できるようにキャッシュしない
    future.then<void>((_) {}, onError: (_) => cache.remove(path));
    return future;
  }

  @override
  void didUpdateWidget(StoragePhoto old) {
    super.didUpdateWidget(old);
    if (old.path != widget.path && isStoragePath(widget.path)) {
      _refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!isStoragePath(widget.path)) {
      return CachedNetworkImage(
        imageUrl: widget.path,
        width: widget.width,
        height: widget.height,
        fit: widget.fit,
        placeholder: widget.placeholder,
        errorWidget: widget.errorWidget,
      );
    }
    // ログインユーザーが変わるとキャッシュが作り直されるので、表示中でも取得し直す
    final cacheMap = ref.watch(storagePhotoCacheProvider);
    if (!identical(cacheMap, _cacheMap)) {
      // 最初の構築では世代を進めない（以降の切り替え時のみ旧画像を破棄する）
      if (_cacheMap != null) _generation++;
      _cacheMap = cacheMap;
      _refresh();
    }
    return FutureBuilder<Uint8List?>(
      key: ValueKey(_generation),
      future: _future,
      builder: (context, snap) {
        if (snap.hasError ||
            (snap.connectionState == ConnectionState.done &&
                snap.data == null)) {
          return widget.errorWidget
                  ?.call(context, widget.path, snap.error ?? '') ??
              const SizedBox.shrink();
        }
        final bytes = snap.data;
        if (bytes == null) {
          return widget.placeholder?.call(context, widget.path) ??
              const SizedBox.shrink();
        }
        return Image.memory(
          bytes,
          width: widget.width,
          height: widget.height,
          fit: widget.fit,
        );
      },
    );
  }
}
