import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'products_page.dart';
import 'record_sale_page.dart';
import 'record_expense_page.dart';

class DashboardPage extends StatefulWidget {
  final FirebaseAuth? auth;
  final FirebaseFirestore? firestore;

  const DashboardPage({super.key, this.auth, this.firestore});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  FirebaseAuth get _auth => widget.auth ?? FirebaseAuth.instance;

  FirebaseFirestore get _firestore =>
      widget.firestore ?? FirebaseFirestore.instance;

  Stream<QuerySnapshot<Map<String, dynamic>>>? _sales;
  Stream<QuerySnapshot<Map<String, dynamic>>>? _expenses;
  String? _streamUserId;

  void _initializeStreams(String userId) {
    if (_streamUserId == userId) return;

    _streamUserId = userId;

    _sales = _firestore
        .collection('users')
        .doc(userId)
        .collection('sales')
        .snapshots();

    _expenses = _firestore
        .collection('users')
        .doc(userId)
        .collection('expenses')
        .snapshots();
  }

  double _calculateTotal(
    QuerySnapshot<Map<String, dynamic>> snapshot,
    String field,
  ) {
    double total = 0;

    for (final document in snapshot.docs) {
      final value = document.data()[field];

      if (value is num) {
        total += value.toDouble();
      }
    }

    return total;
  }

  Future<void> _logout(BuildContext context) async {
    try {
      await _auth.signOut();

      if (!context.mounted) return;

      Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (_) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not log out. Please try again.')),
      );
    }
  }

  void _openProducts(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductsPage(auth: _auth, firestore: _firestore),
      ),
    );
  }

  void _openRecordSale(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            RecordSalePage(auth: _auth, firestore: _firestore),
      ),
    );
  }

  void _openRecordExpense(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            RecordExpensePage(auth: _auth, firestore: _firestore),
      ),
    );
  }

  Widget _buildBusinessSummary(String userId) {
    _initializeStreams(userId);

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _sales,
      builder: (context, salesSnapshot) {
        if (salesSnapshot.hasError) {
          return _buildSummaryError();
        }

        if (!salesSnapshot.hasData) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(),
            ),
          );
        }

        return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: _expenses,
          builder: (context, expensesSnapshot) {
            if (expensesSnapshot.hasError) {
              return _buildSummaryError();
            }

            if (!expensesSnapshot.hasData) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(),
                ),
              );
            }

            final sales = _calculateTotal(salesSnapshot.data!, 'total');

            final expenses = _calculateTotal(expensesSnapshot.data!, 'amount');

            final profit = sales - expenses;

            return Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _SummaryCard(
                        title: 'Sales',
                        value: 'R${sales.toStringAsFixed(2)}',
                        icon: Icons.trending_up,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _SummaryCard(
                        title: 'Expenses',
                        value: 'R${expenses.toStringAsFixed(2)}',
                        icon: Icons.trending_down,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: _SummaryCard(
                    title: 'Profit',
                    value: 'R${profit.toStringAsFixed(2)}',
                    icon: Icons.account_balance_wallet,
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildSummaryError() {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Row(
          children: [
            Icon(Icons.error_outline),
            SizedBox(width: 12),
            Expanded(child: Text('Could not load your business summary.')),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final User? user = _auth.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Please log in to view your dashboard.')),
      );
    }

    final name = user.displayName?.trim() ?? '';
    final email = user.email ?? '';

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

              _buildBusinessSummary(user.uid),

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
                onTap: () => _openProducts(context),
              ),

              const SizedBox(height: 12),

              _MenuButton(
                title: 'Record Sale',
                subtitle: 'Record money coming into your business',
                icon: Icons.point_of_sale,
                onTap: () => _openRecordSale(context),
              ),

              const SizedBox(height: 12),

              _MenuButton(
                title: 'Record Expense',
                subtitle: 'Track your business spending',
                icon: Icons.receipt_long,
                onTap: () => _openRecordExpense(context),
              ),

              const SizedBox(height: 30),

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
