import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Global Recipe Book'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Food Image Banner
          Container(
            height: 200,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: NetworkImage('https://images.unsplash.com/photo-1504674900247-0877df9cc836?q=80&w=400&auto=format&fit=crop'), 
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 30),
          
          // Login Prompt Buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: ElevatedButton(
              onPressed: () {
                // Navigate to Login Screen
                Navigator.pushNamed(context, '/login');
              },
              child: const Text('Log In / Sign Up'),
            ),
          ),
          
          const Spacer(),
          
          // Navigation to other screens
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: const Icon(Icons.search, size: 32),
                onPressed: () { /* Future: Navigate to Recipe List */ },
              ),
              IconButton(
                icon: const Icon(Icons.shopping_cart, size: 32),
                onPressed: () { /* Future: Navigate to Cart */ },
              ),
            ],
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}