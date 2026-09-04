import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/widgets.dart';

final Set<String> _precachedAvatarUrls = <String>{};

ImageProvider? cachedAvatarProvider(String? url) {
  final normalizedUrl = _normalizeAvatarUrl(url);
  if (normalizedUrl == null) return null;
  return CachedNetworkImageProvider(normalizedUrl);
}

// The signed-in user's own (uncached) avatar lives in `widgets/live_avatar.dart`
// as a widget, not here as an ImageProvider.
//
// It was briefly a bare `NetworkImage` returned from this file. That throws on
// any non-200, and as a `CircleAvatar(backgroundImage:)` there is nowhere to
// route the error — so a 404 on a deleted storage object became an uncaught
// framework error and thousands of Crashlytics reports. An ImageProvider cannot
// carry a fallback; a widget with `errorBuilder` can.

void precacheAvatarUrls(BuildContext context, Iterable<String?> urls) {
  final pendingUrls = urls
      .map(_normalizeAvatarUrl)
      .whereType<String>()
      .where((url) => !_precachedAvatarUrls.contains(url))
      .toSet();

  if (pendingUrls.isEmpty) return;

  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (!context.mounted) return;
    for (final url in pendingUrls) {
      _precachedAvatarUrls.add(url);
      precacheImage(CachedNetworkImageProvider(url), context).catchError(
        (Object error, StackTrace stackTrace) {
          _precachedAvatarUrls.remove(url);
          log('Avatar cache failed for $url', error: error, stackTrace: stackTrace);
        },
      );
    }
  });
}

String? _normalizeAvatarUrl(String? url) {
  final trimmedUrl = url?.trim();
  if (trimmedUrl == null || trimmedUrl.isEmpty) return null;
  return trimmedUrl;
}
