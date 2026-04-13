import '../models/user.dart';
import '../services/auth_service.dart';
import '../providers/auth_provider.dart';

class AuthController {
  final AuthService _authService = AuthService();

  // Sign up
  Future<void> signUp(
    String email,
    String password,
    AuthProvider authProvider,
  ) async {
    authProvider.setLoading(true);

    User? user = await _authService.signUp(email, password);
    if (user != null) {
      authProvider.setUser(user);
      authProvider.setLoggedIn(true);
    } else {
      authProvider.setError("Sign up failed");
    }

    authProvider.setLoading(false);
  }

  // Sign in
  Future<void> signIn(
    String email,
    String password,
    AuthProvider authProvider,
  ) async {
    authProvider.setLoading(true);

    User? user = await _authService.signIn(email, password);
    if (user != null) {
      authProvider.setUser(user);
      authProvider.setLoggedIn(true);
    } else {
      authProvider.setError("Invalid credentials");
    }

    authProvider.setLoading(false);
  }

  // Logout
  Future<void> signOut(AuthProvider authProvider) async {
    await _authService.signOut();
    authProvider.setUser(null);
    authProvider.setLoggedIn(false);
  }

  // Reset Password
  Future<bool> resetPassword(String email, AuthProvider authProvider) async {
    authProvider.setLoading(true);
    try {
      bool result = await _authService.sendPasswordResetEmail(email);
      authProvider.setLoading(false);
      return result;
    } catch (e) {
      authProvider.setError("Failed to send reset email: $e");
      authProvider.setLoading(false);
      return false;
    }
  }
}
