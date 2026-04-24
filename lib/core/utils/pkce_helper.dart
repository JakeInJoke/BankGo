import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';

/// PKCE (Proof Key for Code Exchange) helper for OAuth2 flows.
/// Generates and validates code verifier and challenge pairs.
class PkceHelper {
  /// Generates a random code_verifier (43-128 characters, URL-safe).
  /// RFC 7636 recommends 43 characters for security.
  static String generateCodeVerifier({int length = 43}) {
    final random = Random.secure();
    final values = List<int>.generate(length, (i) => random.nextInt(256));
    return base64Url
        .encode(values)
        .replaceAll('=', '') // Remove padding
        .replaceAll('+', '-')
        .replaceAll('/', '_')
        .substring(0, length);
  }

  /// Derives code_challenge from code_verifier using SHA-256 hash.
  /// Method: S256 (SHA-256)
  static String generateCodeChallenge(String codeVerifier) {
    final bytes = utf8.encode(codeVerifier);
    final digest = sha256.convert(bytes);
    return base64Url.encode(digest.bytes).replaceAll('=', '');
  }

  /// Validates that the code_verifier matches the code_challenge.
  /// Returns true if valid, false otherwise.
  static bool validateChallenge(
    String codeVerifier,
    String codeChallenge,
  ) {
    final derived = generateCodeChallenge(codeVerifier);
    return derived == codeChallenge;
  }

  /// Generates both code_verifier and code_challenge.
  /// Returns a map with 'verifier' and 'challenge' keys.
  static Map<String, String> generatePkceCodePair() {
    final verifier = generateCodeVerifier();
    final challenge = generateCodeChallenge(verifier);
    return {
      'verifier': verifier,
      'challenge': challenge,
    };
  }
}
