import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showMessage('Please enter your email and password.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (!mounted) return;

      // Firebase authentication state has now changed.
      // Return to the first route where AuthGate will
      // automatically display DashboardPage.
      Navigator.of(context).popUntil((route) => route.isFirst);
    } on FirebaseAuthException catch (error) {
      if (!mounted) return;

      if (error.code == 'invalid-email') {
        _showMessage('Please enter a valid email address.');
      } else if (error.code == 'user-not-found' ||
          error.code == 'wrong-password' ||
          error.code == 'invalid-credential') {
        _showMessage('Incorrect email or password.');
      } else if (error.code == 'user-disabled') {
        _showMessage('This account has been disabled.');
      } else if (error.code == 'too-many-requests') {
        _showMessage('Too many login attempts. Please try again later.');
      } else {
        _showMessage(error.message ?? 'Login failed. Please try again.');
      }
    } catch (_) {
      if (!mounted) return;

      _showMessage('Something went wrong. Please try again.');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Log In')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 30),

              const Icon(Icons.storefront, size: 80, color: Colors.green),

              const SizedBox(height: 20),

              const Text(
                'Welcome Back',
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 10),

              const Text(
                'Log in to continue managing your business.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),

              const SizedBox(height: 30),

              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                autocorrect: false,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  hintText: 'Enter your email',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
              ),

              const SizedBox(height: 16),

              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) {
                  if (!_isLoading) {
                    _login();
                  }
                },
                decoration: InputDecoration(
                  labelText: 'Password',
                  hintText: 'Enter your password',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _isLoading ? null : _login,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: _isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Log In', style: TextStyle(fontSize: 18)),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                'KasiBiz',
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
