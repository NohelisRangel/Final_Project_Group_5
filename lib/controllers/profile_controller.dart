import '../services/database_service.dart';

class ProfileController {
  final DatabaseService _db = DatabaseService.instance;

  // Handle Login
  Future<Map<String, dynamic>?> loginUser(String email, String password) async {
    return await _db.authenticateUser(email, password);
  }

  // Handle Logout
  Future<void> logoutUser() async {
    await _db.logout();
  }

  // Fetch the logged-in user's history
  Future<List<Map<String, dynamic>>> getHistory() async {
    final userId = _db.currentUserId;
    if (userId != null) {
      return await _db.getUserHistory(userId);
    }
    return []; 
  }

  // Get current user's email
  String get userEmail => _db.currentUserEmail ?? "Guest";
}