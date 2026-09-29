import 'package:flutter/material.dart';

import 'pages/login_page.dart';
import 'pages/register_page.dart';

void main() {
  runApp(const KasiBizApp());
}

class KasiBizApp extends StatelessWidget {
  const KasiBizApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'KasiBiz',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const WelcomePage(),
    );
  }
}

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.storefront, size: 100, color: Colors.green),

              const SizedBox(height: 30),

              const Text(
                'KasiBiz',
                style: TextStyle(fontSize: 42, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 12),

              const Text(
                'Run your business. Know your numbers. Grow your hustle.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),

              const SizedBox(height: 50),

              // Get Started Button
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RegisterPage(),
                      ),
                    );
                  },
                  child: const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('Get Started', style: TextStyle(fontSize: 18)),
                  ),
                ),
              ),

              const SizedBox(height: 15),

              // Log In Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginPage(),
                      ),
                    );
                  },
                  child: const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('Log In', style: TextStyle(fontSize: 18)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
