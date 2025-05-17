import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final supabase = Supabase.instance.client;

  // Get current user
  User? get currentUser => supabase.auth.currentUser;

  // Sign in with email and password
  Future<AuthResponse> signIn(String email, String password) async {
    try {
      print("AUTH: Attempting to sign in user: $email");
      final response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      print("AUTH: Sign in successful for user: ${response.user?.email}");
      return response;
    } catch (e) {
      print("AUTH ERROR: Sign in failed: $e");
      rethrow;
    }
  }

  // Register with email and password
  Future<AuthResponse> register(
    String email,
    String password,
    String name,
  ) async {
    try {
      print("AUTH: Starting registration for $email");

      // Check password strength
      if (password.length < 6) {
        print("AUTH ERROR: Password too short (min 6 characters required)");
        throw AuthException("Password must be at least 6 characters long");
      }

      final response = await supabase.auth.signUp(
        email: email,
        password: password,
        data: {'name': name, 'reward_coins': 0},
      );

      print(
        "AUTH: Registration response received: ${response.user != null ? 'User created' : 'No user created'}",
      );

      // Check if email confirmation is required
      if (response.session == null && response.user != null) {
        print("AUTH: Email confirmation required. Check email inbox.");
      }

      if (response.user != null) {
        print(
          "AUTH: Creating profile in database for user ${response.user!.id}",
        );
        try {
          await supabase.from('profiles').insert({
            'id': response.user!.id,
            'name': name,
            'email': email,
            'reward_coins': 0,
          });
          print("AUTH: Profile created successfully");
        } catch (profileError) {
          print("AUTH ERROR: Failed to create profile: $profileError");
        }
      }

      return response;
    } catch (e) {
      print("AUTH ERROR: Registration failed: $e");
      if (e.toString().contains("User already registered")) {
        print("AUTH INFO: This email is already registered");
      }
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      print("AUTH: Signing out user");
      await supabase.auth.signOut();
      print("AUTH: User signed out successfully");
    } catch (e) {
      print("AUTH ERROR: Sign out failed: $e");
      rethrow;
    }
  }
}
