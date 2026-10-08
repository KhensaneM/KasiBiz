import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ExpenseHistoryPage extends StatelessWidget {
  final FirebaseAuth? auth;
  final FirebaseFirestore? firestore;

  const ExpenseHistoryPage({super.key, this.auth, this.firestore});

  FirebaseAuth get _auth => auth ?? FirebaseAuth.instance;

  FirebaseFirestore get _firestore => firestore ?? FirebaseFirestore.instance;

  String _formatDate(dynamic value) {
    if (value is! Timestamp) {
      return 'Date unavailable';
    }

    final date = value.toDate().toLocal();
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');

    return '$day/$month/${date.year} $hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Please log in to view expense history.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Expense History',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _firestore
            .collection('users')
            .doc(user.uid)
            .collection('expenses')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Could not load expense history.'));
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final expenses = snapshot.data!.docs.toList();

          expenses.sort((a, b) {
            final first = a.data()['createdAt'];
            final second = b.data()['createdAt'];

            final firstDate = first is Timestamp
                ? first.millisecondsSinceEpoch
                : 0;

            final secondDate = second is Timestamp
                ? second.millisecondsSinceEpoch
                : 0;

            return secondDate.compareTo(firstDate);
          });

          if (expenses.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.receipt_long_outlined,
                    size: 70,
                    color: Colors.orange,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No expenses recorded yet',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text('Your recorded expenses will appear here.'),
                ],
              ),
            );
          }

          double totalExpenses = 0;

          for (final expense in expenses) {
            final amount = expense.data()['amount'];

            if (amount is num) {
              totalExpenses += amount.toDouble();
            }
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total Expenses',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'R${totalExpenses.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: expenses.length,
                  itemBuilder: (context, index) {
                    final data = expenses[index].data();

                    final name = data['name']?.toString() ?? 'Unnamed expense';

                    final category = data['category']?.toString() ?? 'Other';

                    final amount = data['amount'] is num
                        ? (data['amount'] as num).toDouble()
                        : 0.0;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(14),
                        leading: CircleAvatar(
                          backgroundColor: Colors.orange.shade50,
                          child: const Icon(
                            Icons.receipt_long,
                            color: Colors.orange,
                          ),
                        ),
                        title: Text(
                          name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          '$category\n'
                          '${_formatDate(data['createdAt'])}',
                        ),
                        isThreeLine: true,
                        trailing: Text(
                          'R${amount.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
