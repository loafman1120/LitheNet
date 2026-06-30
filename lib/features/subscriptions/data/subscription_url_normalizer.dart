class SubscriptionUrlNormalizer {
  const SubscriptionUrlNormalizer();

  String? normalize(String input) {
    final trimmed = _stripDecorations(input);
    if (trimmed.isEmpty) {
      return null;
    }

    final direct = Uri.tryParse(trimmed);
    if (_isHttpSubscriptionUrl(direct)) {
      return direct.toString();
    }

    final extracted = _extractNestedUrl(direct);
    if (extracted != null) {
      return extracted;
    }

    final embedded = _extractEmbeddedHttpUrl(trimmed);
    if (embedded != null) {
      return embedded;
    }

    return null;
  }

  bool isValid(String input) => normalize(input) != null;

  String? _extractNestedUrl(Uri? uri) {
    if (uri == null) {
      return null;
    }

    for (final key in const [
      'url',
      'uri',
      'link',
      'subscription',
      'sub',
      'subscribe',
      'remote-resource',
      'config',
      'target',
      'u',
    ]) {
      final value = uri.queryParameters[key];
      final normalized = value == null ? null : normalize(value);
      if (normalized != null) {
        return normalized;
      }
    }

    final fragment = uri.fragment;
    if (fragment.isNotEmpty) {
      final normalized = normalize(Uri.decodeComponent(fragment));
      if (normalized != null) {
        return normalized;
      }
    }

    return null;
  }

  String? _extractEmbeddedHttpUrl(String value) {
    var current = value;
    for (var i = 0; i < 3; i += 1) {
      final match =
          RegExp(r'https?%3A%2F%2F[^\s&?#]+(?:[^\s]*)', caseSensitive: false)
              .firstMatch(current);
      if (match != null) {
        final normalized = normalize(Uri.decodeFull(match.group(0)!));
        if (normalized != null) {
          return normalized;
        }
      }

      final plain = RegExp(r'https?://[^\s<>"' '`]+', caseSensitive: false)
          .firstMatch(current);
      if (plain != null) {
        final candidate = plain.group(0)!.replaceAll(RegExp(r'[),.;]+$'), '');
        final uri = Uri.tryParse(candidate);
        if (_isHttpSubscriptionUrl(uri)) {
          return uri.toString();
        }
      }

      final decoded = Uri.decodeFull(current);
      if (decoded == current) {
        break;
      }
      current = decoded;
    }
    return null;
  }

  String _stripDecorations(String input) {
    return input.trim().replaceAll(RegExp(r'^<+|>+$'), '');
  }

  bool _isHttpSubscriptionUrl(Uri? uri) {
    return uri != null &&
        (uri.scheme == 'https' || uri.scheme == 'http') &&
        uri.host.isNotEmpty;
  }
}
