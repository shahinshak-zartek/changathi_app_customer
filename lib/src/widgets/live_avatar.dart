import 'package:flutter/material.dart';

/// The signed-in user's own avatar: circular, **uncached**, and safe when the
/// object behind the URL is missing.
///
/// Uncached on purpose — this is the avatar the user can change, and it must
/// never lag behind a change they just made. Everything else (agent tiles, chat,
/// the avatar picker) keeps `cachedAvatarProvider`, where caching pays and
/// staleness does not matter.
///
/// Built on `Image.network` + `errorBuilder` rather than
/// `CircleAvatar(backgroundImage:)`. A `DecorationImage` has nowhere to put a
/// fallback and reports load failures as uncaught framework errors, so a 404 on
/// a deleted storage object becomes a crash report instead of a placeholder —
/// which is exactly what happened when this avatar was a bare `NetworkImage`.
class LiveAvatar extends StatelessWidget {
  const LiveAvatar({super.key, required this.url, required this.radius});

  final String? url;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final trimmedUrl = url?.trim();

    final fallback = CircleAvatar(
      radius: radius,
      backgroundColor: Colors.transparent,
      child: Icon(Icons.person, color: Colors.grey.shade600),
    );

    if (trimmedUrl == null || trimmedUrl.isEmpty) return fallback;

    return ClipOval(
      child: Image.network(
        trimmedUrl,
        width: radius * 2,
        height: radius * 2,
        fit: BoxFit.cover,
        // Supplying this is what keeps a failed load out of Crashlytics: with an
        // errorBuilder, Image treats the failure as handled instead of passing
        // it to FlutterError.reportError.
        errorBuilder: (context, error, stackTrace) => fallback,
      ),
    );
  }
}
