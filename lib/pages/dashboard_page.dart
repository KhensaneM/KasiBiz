import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final name = user?.displayName?.trim();

    return Scaffold(
      appBar: AppBar(
        title: const Text('KasiBiz Dashboard'),
        actions: [
          IconButton(
            tooltip: 'Log Out',
            onPressed: () async {
              await FirebaseAuth.instance.signOut();

              if (!context.mounted) return;

              Navigator.of(context).popUntil((route) => route.isFirst);
            },
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
                name != null && name.isNotEmpty
                    ? 'Welcome, $name!'
                    : 'Welcome to KasiBiz!',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'Here is your business overview.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),

              const SizedBox(height: 30),

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

              const _SummaryCard(
                title: 'Profit',
                value: 'R0.00',
                icon: Icons.account_balance_wallet,
              ),

              const SizedBox(height: 32),

              const Text(
                'Manage Business',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 16),

              _MenuButton(
                title: 'Products & Services',
                subtitle: 'Add and manage what you sell',
                icon: Icons.inventory_2,
                onTap: () {},
              ),

              const SizedBox(height: 12),

              _MenuButton(
                title: 'Record Sale',
                subtitle: 'Record money coming into your business',
                icon: Icons.point_of_sale,
                onTap: () {},
              ),

              const SizedBox(height: 12),

              _MenuButton(
                title: 'Record Expense',
                subtitle: 'Track your business spending',
                icon: Icons.receipt_long,
                onTap: () {},
              ),
            ],
          ),
        ),
      ),
    );
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
            Icon(icon, size: 30),
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
        leading: Icon(icon, size: 32),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }
}
