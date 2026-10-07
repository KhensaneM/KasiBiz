import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'products_page.dart';
import 'record_sale_page.dart';

class DashboardPage extends StatelessWidget {
  final FirebaseAuth? auth;

  const DashboardPage({super.key, this.auth});

  FirebaseAuth get _auth => auth ?? FirebaseAuth.instance;

  Future<void> _logout(BuildContext context) async {
    await _auth.signOut();

    if (!context.mounted) return;

    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final User? user = _auth.currentUser;

    final String name = user?.displayName?.trim() ?? '';
    final String email = user?.email ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'KasiBiz Dashboard',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            tooltip: 'Log Out',
            onPressed: () => _logout(context),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name.isNotEmpty ? 'Welcome, $name!' : 'Welcome to KasiBiz!',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (email.isNotEmpty) ...[
                const SizedBox(height: 5),
                Text(
                  email,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
              const SizedBox(height: 10),
              const Text(
                'Here is your business overview.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 30),

              // Business summary
              const Row(
                children: [
                  Expanded(
                    child: _SummaryCard(
                      title: 'Sales',
                      value: 'R0.00',
                      icon: Icons.trending_up,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: _SummaryCard(
                      title: 'Expenses',
                      value: 'R0.00',
                      icon: Icons.trending_down,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              const SizedBox(
                width: double.infinity,
                child: _SummaryCard(
                  title: 'Profit',
                  value: 'R0.00',
                  icon: Icons.account_balance_wallet,
                ),
              ),

              const SizedBox(height: 32),

              const Text(
                'Manage Business',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 16),

              // Products & Services
              _MenuButton(
                title: 'Products & Services',
                subtitle: 'Add and manage what you sell',
                icon: Icons.inventory_2,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ProductsPage(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 12),

              // Record Sale
              _MenuButton(
                title: 'Record Sale',
                subtitle: 'Record money coming into your business',
                icon: Icons.point_of_sale,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RecordSalePage(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 12),

              // Record Expense
              _MenuButton(
                title: 'Record Expense',
                subtitle: 'Track your business spending',
                icon: Icons.receipt_long,
                onTap: () {
                  _showComingSoon(context, 'Record Expense');
                },
              ),

              const SizedBox(height: 30),

              // Logout
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _logout(context),
                  icon: const Icon(Icons.logout),
                  label: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 14),
                    child: Text('Log Out', style: TextStyle(fontSize: 16)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('$feature is coming next.')));
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 30, color: Colors.green),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 5),
            Text(
              value,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _MenuButton({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        leading: Icon(icon, size: 32, color: Colors.green),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 18),
        onTap: onTap,
      ),
    );
  }
}
