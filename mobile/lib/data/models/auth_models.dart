class TokenPair {
  const TokenPair({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresIn,
  });

  final String accessToken;
  final String refreshToken;
  final int expiresIn;

  factory TokenPair.fromJson(Map<String, dynamic> json) {
    return TokenPair(
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String,
      expiresIn: json['expires_in'] as int? ?? 900,
    );
  }
}

class AscendUser {
  const AscendUser({
    required this.id,
    required this.email,
    required this.displayName,
    required this.locale,
    required this.roles,
  });

  final String id;
  final String? email;
  final String displayName;
  final String locale;
  final List<String> roles;

  factory AscendUser.fromJson(Map<String, dynamic> json) {
    return AscendUser(
      id: json['id'] as String,
      email: json['email'] as String?,
      displayName: json['display_name'] as String,
      locale: json['locale'] as String? ?? 'ru',
      roles: (json['roles'] as List<dynamic>? ?? const []).cast<String>(),
    );
  }
}

class AuthResult {
  const AuthResult({required this.user, required this.tokens});

  final AscendUser user;
  final TokenPair tokens;

  factory AuthResult.fromJson(Map<String, dynamic> json) {
    return AuthResult(
      user: AscendUser.fromJson(json['user'] as Map<String, dynamic>),
      tokens: TokenPair.fromJson(json['tokens'] as Map<String, dynamic>),
    );
  }
}
