import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'wallet_view_model.dart';

class BankAccountsScreen extends StatefulWidget {
  const BankAccountsScreen({super.key});

  @override
  State<BankAccountsScreen> createState() => _BankAccountsScreenState();
}

class _BankAccountsScreenState extends State<BankAccountsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _bankNameController = TextEditingController();
  final _accountNumberController = TextEditingController();
  final _holderNameController = TextEditingController();

  void _showAddAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Bank Account'),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _holderNameController,
                decoration: const InputDecoration(
                  labelText: 'Account Holder Name',
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter holder name' : null,
              ),
              TextFormField(
                controller: _bankNameController,
                decoration: const InputDecoration(labelText: 'Bank Name'),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter bank name' : null,
              ),
              TextFormField(
                controller: _accountNumberController,
                decoration: const InputDecoration(labelText: 'Account Number'),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value!.isEmpty ? 'Please enter account number' : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                final viewModel = Provider.of<WalletViewModel>(
                  context,
                  listen: false,
                );
                viewModel.addBankAccount(
                  BankAccount(
                    id: DateTime.now().toString(),
                    bankName: _bankNameController.text,
                    accountNumber: _accountNumberController.text,
                    accountHolderName: _holderNameController.text,
                  ),
                );

                // Clear controllers
                _bankNameController.clear();
                _accountNumberController.clear();
                _holderNameController.clear();

                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<WalletViewModel>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Manage Bank Accounts')),
      body: viewModel.bankAccounts.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.account_balance,
                    size: 64,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 16),
                  const Text('No bank accounts added yet.'),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: viewModel.bankAccounts.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final account = viewModel.bankAccounts[index];
                return ListTile(
                  tileColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.grey[200]!),
                  ),
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFE0F7FA),
                    child: Icon(
                      Icons.account_balance,
                      color: Color(0xFF006064),
                    ),
                  ),
                  title: Text(account.bankName),
                  subtitle: Text(account.accountNumber),
                  trailing: account.isPrimary
                      ? const Chip(
                          label: Text(
                            'PRIMARY',
                            style: TextStyle(fontSize: 10, color: Colors.white),
                          ),
                          backgroundColor: Colors.green,
                        )
                      : null,
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddAccountDialog,
        backgroundColor: const Color(0xFFFD802E),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
