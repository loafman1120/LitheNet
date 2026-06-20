class SubscriptionErrorCodes {
  const SubscriptionErrorCodes._();

  static const invalidUrl = 'SUB-URL-001';
  static const network = 'SUB-NET-001';
  static const auth = 'SUB-AUTH-001';
  static const notModified = 'SUB-HTTP-304';
  static const format = 'SUB-FMT-001';
  static const parse = 'SUB-PARSE-001';
  static const store = 'SUB-STORE-001';
  static const safe = 'SUB-SAFE-001';
}

class SubscriptionException implements Exception {
  const SubscriptionException(this.code, this.message);

  final String code;
  final String message;

  @override
  String toString() => '$code: $message';
}
