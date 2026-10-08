import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RecordExpensePage extends StatefulWidget {
  final FirebaseAuth? auth;
  final FirebaseFirestore? firestore;

  const RecordExpensePage({super.key, this.auth, this.firestore});

  @override
  State<RecordExpensePage> createState() => _RecordExpensePageState();
}

class _RecordExpensePageState extends State<RecordExpensePage> {
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();

  String _category = 'Stock';
  bool _isSaving = false;

  FirebaseAuth get _auth => widget.auth ?? FirebaseAuth.instance;

  FirebaseFirestore get _firestore =>
      widget.firestore ?? FirebaseFirestore.instance;

  Future<void> _saveExpense() async {
    final name = _nameController.text.trim();
    final amount = double.tryParse(_amountController.text.trim());

    if (name.isEmpty || amount == null || !amount.isFinite || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid expense name and amount.')),
      );
      return;
    }

    final user = _auth.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please log in first.')));
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('expenses')
          .add({
            'name': name,
            'category': _category,
            'amount': amount,
            'createdAt': FieldValue.serverTimestamp(),
          });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Expense saved successfully!')),
      );

      Navigator.of(context).pop();
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not save expense. Please try again.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Record Expense')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Add Business Expense',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text('Keep track of where your business money goes.'),
              const SizedBox(height: 24),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Expense Name',
                  hintText: 'e.g. Electricity',
                  prefixIcon: Icon(Icons.receipt_long),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _category,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'Stock', child: Text('Stock')),
                  DropdownMenuItem(value: 'Rent', child: Text('Rent')),
                  DropdownMenuItem(
                    value: 'Electricity',
                    child: Text('Electricity'),
                  ),
                  DropdownMenuItem(
                    value: 'Transport',
                    child: Text('Transport'),
                  ),
                  DropdownMenuItem(value: 'Other', child: Text('Other')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _category = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Amount (R)',
                  hintText: 'e.g. 150.00',
                  prefixIcon: Icon(Icons.payments),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _isSaving ? null : _saveExpense,
                  icon: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save),
                  label: const Padding(
                    padding: EdgeInsets.all(14),
                    child: Text('Save Expense'),
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
