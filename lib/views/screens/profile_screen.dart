import 'package:flutter/material.dart';
import '../../controllers/profile_controller.dart';
import '../../main.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ProfileController _profileController = ProfileController();
  List<Map<String, dynamic>> _recipeHistory = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }
  
  

  Future<void> _loadProfileData() async {
    final history = await _profileController.getHistory();
    if (mounted) {
      setState(() {
        _recipeHistory = history;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator()) 
        : Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // --- The Food Image Banner is Back! ---
          Container(
            height: 150, 
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: NetworkImage('https://images.unsplash.com/photo-1504674900247-0877df9cc836?q=80&w=400&auto=format&fit=crop'), 
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Center(
                    child: ValueListenableBuilder<bool>(
                      valueListenable: isDarkMode,
                      builder: (context, value, child) {
                        return Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.light_mode),
                            Switch(
                              value: value,
                              onChanged: (val) {
                                isDarkMode.value = val;
                              },
                            ),
                            const Icon(Icons.dark_mode),
                          ],
                        );
                      },
                    ),
                  ),
                ),
          // User Profile Header
          Container(
            color: Colors.orange.shade50,
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.green,
                  child: Icon(Icons.person, size: 40, color: Colors.white),
                ),
                const SizedBox(height: 12),
                Text(
                  _profileController.userEmail,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text('Recipe Master', style: TextStyle(fontSize: 14, color: Colors.grey.shade700)),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: () async {
                    await _profileController.logoutUser();
                    if (mounted) {
                      Navigator.pushReplacementNamed(context, '/login');
                    }
                  },
                  icon: const Icon(Icons.logout, size: 18),
                  label: const Text("Log Out"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                )
              ],
            ),
          ),
          
          // Stats Section
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatColumn('Completed', _recipeHistory.length.toString()),
                _buildStatColumn('Favorites', '0'), 
              ],
            ),
          ),
          
          const Divider(thickness: 2),
          
          // Cooking History Title
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text('Cooking History', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          
          // Expanded ListView for the History
          Expanded(
            child: _recipeHistory.isEmpty 
            ? const Center(child: Text("You haven't completed any recipes yet!"))
            : ListView.builder(
              padding: const EdgeInsets.only(top: 0),
              itemCount: _recipeHistory.length,
              itemBuilder: (context, index) {
                final recipe = _recipeHistory[index];
                final name = recipe['name'] ?? 'Unknown Recipe';
                final timeFinished = recipe['completed_at'] ?? 'Unknown Time';
                final duration = recipe['time_taken'] ?? 0;

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  elevation: 2,
                  child: ListTile(
                    leading: const CircleAvatar(backgroundColor: Colors.green, child: Icon(Icons.restaurant, color: Colors.white, size: 20)),
                    title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('Finished: $timeFinished\nTime taken: $duration mins'),
                    trailing: const Icon(Icons.check_circle, color: Colors.green),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Helper widget for the Stats Row
  Widget _buildStatColumn(String label, String count) {
    return Column(
      children: [
        Text(count, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.green)),
        Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
      ],
    );
  }
}