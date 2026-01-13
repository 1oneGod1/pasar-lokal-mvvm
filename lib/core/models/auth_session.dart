import 'user.dart';

enum AuthProviderType { password, google }

class AuthSession {
  const AuthSession({
    required this.user,
    required this.provider,
    this.sessionToken,
  });

  final User user;
  final AuthProviderType provider;

  /// Demo token for password login, or Google `idToken`/`accessToken` for OAuth.
  final String? sessionToken;
}
