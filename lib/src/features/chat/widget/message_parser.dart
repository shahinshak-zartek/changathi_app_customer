import 'package:flutter/material.dart';

class VibetalkMessageParser {
  static Widget parse(String html, {TextStyle? style}) {
    // 1. First, decode Zulip-style standard emojis from spans with hex codes
    // Format: <span class="emoji emoji-1f600" title="smile">:smile:</span>
    // Also handles multi-code point emojis like 1f1f2-1f1fe
    final emojiRegex = RegExp(
        r'<span[^>]*class="[^"]*emoji-([a-f0-9-]+)"[^>]*>.*?</span>',
        caseSensitive: false);

    String decoded = html.replaceAllMapped(emojiRegex, (match) {
      final hexString = match.group(1);
      if (hexString != null) {
        try {
          final parts = hexString.split('-');
          return parts.map((hex) {
            final charCode = int.parse(hex, radix: 16);
            return String.fromCharCode(charCode);
          }).join();
        } catch (_) {}
      }
      return match.group(0)!;
    });

    // 2. Extract title from custom emoji images
    // Format: <img src="..." class="emoji" title="custom_emoji">
    final customEmojiRegex = RegExp(r'<img[^>]*class="[^"]*emoji"[^>]*title="([^"]+)"[^>]*>', caseSensitive: false);
    decoded = decoded.replaceAllMapped(customEmojiRegex, (match) {
      final title = match.group(1);
      return title != null ? ":$title:" : match.group(0)!;
    });

    // 3. Strip all remaining HTML tags
    final text = decoded.replaceAll(RegExp(r'<[^>]*>'), '').trim();

    return Text(
      text.isEmpty ? ' ' : text,
      style: style,
    );
  }
}
