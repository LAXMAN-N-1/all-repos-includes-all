// test/wallet_withdrawal_test.dart
//
// Unit tests for:
//   • WithdrawToBankViewModel — validation rules & canSubmit guard
//   • WalletViewModel        — applyWithdrawal, syncBalance, resetForLogout

import 'package:flutter_test/flutter_test.dart';
import 'package:wezu_delivery_app/screens/wallet/withdraw_to_bank_view_model.dart';
import 'package:wezu_delivery_app/screens/wallet/wallet_view_model.dart';
import 'package:wezu_delivery_app/repositories/wallet_repository.dart';

// ─── Minimal fake repository (no HTTP) ───────────────────────────────────────

class _FakeWalletRepository extends WalletRepository {
  _FakeWalletRepository() : super();

  @override
  Future<String?> lookupBankName(String ifsc) async => null;
}

void main() {
  // ── WithdrawToBankViewModel ─────────────────────────────────────────────────

  group('WithdrawToBankViewModel.canSubmit', () {
    late WithdrawToBankViewModel vm;

    setUp(() {
      vm = WithdrawToBankViewModel(walletRepository: _FakeWalletRepository());
    });

    test('returns error when amount is 0', () {
      expect(vm.canSubmit(0, 500), isNotNull);
    });

    test('returns error when amount is below minimum (₹100)', () {
      expect(vm.canSubmit(50, 500), isNotNull);
    });

    test('returns error when amount exceeds maximum (₹50000)', () {
      expect(vm.canSubmit(60000, 100000), isNotNull);
    });

    test('returns error when amount exceeds wallet balance', () {
      expect(vm.canSubmit(1500, 1000), isNotNull);
    });

    test('returns null (ok) for valid amount within balance', () {
      expect(vm.canSubmit(500, 2000), isNull);
    });

    test('returns null when amount equals balance exactly', () {
      expect(vm.canSubmit(2000, 2000), isNull);
    });
  });

  // ── Amount validation ───────────────────────────────────────────────────────

  group('WithdrawToBankViewModel.validateAmount', () {
    late WithdrawToBankViewModel vm;
    const balance = 5000.0;

    setUp(() {
      vm = WithdrawToBankViewModel(walletRepository: _FakeWalletRepository());
    });

    test('null input returns error', () {
      expect(vm.validateAmount(null, balance), isNotNull);
    });

    test('empty string returns error', () {
      expect(vm.validateAmount('', balance), isNotNull);
    });

    test('non-numeric returns error', () {
      expect(vm.validateAmount('abc', balance), isNotNull);
    });

    test('below minimum returns error', () {
      expect(vm.validateAmount('50', balance), isNotNull);
    });

    test('above maximum returns error', () {
      expect(vm.validateAmount('100000', balance), isNotNull);
    });

    test('above balance returns insufficient balance error', () {
      expect(vm.validateAmount('9999', 500), isNotNull);
    });

    test('valid amount within balance returns null', () {
      expect(vm.validateAmount('1000', balance), isNull);
    });
  });

  // ── IFSC validation ─────────────────────────────────────────────────────────

  group('WithdrawToBankViewModel.validateIFSC', () {
    late WithdrawToBankViewModel vm;

    setUp(() {
      vm = WithdrawToBankViewModel(walletRepository: _FakeWalletRepository());
    });

    test('null/empty returns error', () {
      expect(vm.validateIFSC(null), isNotNull);
      expect(vm.validateIFSC(''), isNotNull);
    });

    test('too short returns error', () {
      expect(vm.validateIFSC('HDFC001'), isNotNull);
    });

    test('bad format (5th char not 0) returns error', () {
      expect(vm.validateIFSC('HDFC1001234'), isNotNull);
    });

    test('valid IFSC returns null', () {
      expect(vm.validateIFSC('HDFC0001234'), isNull);
    });

    test('valid IFSC — SBI format', () {
      expect(vm.validateIFSC('SBIN0005678'), isNull);
    });
  });

  // ── UPI validation ──────────────────────────────────────────────────────────

  group('WithdrawToBankViewModel.validateUPI', () {
    late WithdrawToBankViewModel vm;

    setUp(() {
      vm = WithdrawToBankViewModel(walletRepository: _FakeWalletRepository());
    });

    test('null/empty returns error', () {
      expect(vm.validateUPI(null), isNotNull);
      expect(vm.validateUPI(''), isNotNull);
    });

    test('bad format (no @) returns error', () {
      expect(vm.validateUPI('userupi'), isNotNull);
    });

    test('valid format but unverified returns error', () {
      // _upiVerifyStatus defaults to idle → requires verification
      expect(vm.validateUPI('user@upi'), isNotNull);
    });
  });

  // ── WalletViewModel — applyWithdrawal ───────────────────────────────────────

  group('WalletViewModel.applyWithdrawal', () {
    late WalletViewModel wallet;

    setUp(() => wallet = WalletViewModel());

    test('balance decrements optimistically when no server balance given', () {
      final before = wallet.balance;
      wallet.applyWithdrawal(amount: 200, method: 'bank');
      expect(wallet.balance, closeTo(before - 200, 0.01));
    });

    test(
      'balance set to server value when serverRemainingBalance provided',
      () {
        wallet.applyWithdrawal(
          amount: 200,
          method: 'bank',
          serverRemainingBalance: 1750.00,
        );
        expect(wallet.balance, closeTo(1750.00, 0.01));
      },
    );

    test('new transaction inserted at index 0', () {
      final countBefore = wallet.transactions.length;
      wallet.applyWithdrawal(amount: 300, method: 'upi');
      expect(wallet.transactions.length, countBefore + 1);
      expect(wallet.transactions.first.isWithdrawal, isTrue);
    });

    test('withdrawal transaction has correct method title', () {
      wallet.applyWithdrawal(amount: 300, method: 'bank');
      expect(wallet.transactions.first.title, 'Withdraw to Bank');
    });

    test('withdrawal status defaults to pending', () {
      wallet.applyWithdrawal(amount: 300, method: 'bank');
      expect(wallet.transactions.first.status, TransactionStatus.pending);
    });

    test('amount above balance is rejected (safety guard)', () {
      final before = wallet.balance;
      wallet.applyWithdrawal(amount: before + 9999, method: 'bank');
      expect(wallet.balance, before); // unchanged
    });
  });

  // ── WalletViewModel — syncBalance ───────────────────────────────────────────

  group('WalletViewModel.syncBalance', () {
    late WalletViewModel wallet;

    setUp(() => wallet = WalletViewModel());

    test('balance is updated to server value', () {
      wallet.syncBalance(999.99);
      expect(wallet.balance, closeTo(999.99, 0.001));
    });

    test('no-op when balance already matches', () {
      wallet.syncBalance(wallet.balance); // should not throw or crash
      expect(wallet.balance, isA<double>());
    });
  });

  // ── WalletViewModel — resetForLogout ────────────────────────────────────────

  group('WalletViewModel.resetForLogout', () {
    late WalletViewModel wallet;

    setUp(() => wallet = WalletViewModel());

    test('balance resets to zero', () {
      wallet.resetForLogout();
      expect(wallet.balance, 0.0);
    });

    test('transactions cleared', () {
      wallet.resetForLogout();
      expect(wallet.transactions, isEmpty);
    });

    test('filter reset to all', () {
      wallet.setFilter(TransactionFilter.pending);
      wallet.resetForLogout();
      expect(wallet.activeFilter, TransactionFilter.all);
    });
  });

  // ── TransactionFilter ───────────────────────────────────────────────────────

  group('WalletViewModel.filteredTransactions', () {
    late WalletViewModel wallet;

    setUp(() => wallet = WalletViewModel());

    test('pending filter returns only pending transactions', () {
      wallet.setFilter(TransactionFilter.pending);
      final result = wallet.filteredTransactions;
      expect(
        result.every((t) => t.status == TransactionStatus.pending),
        isTrue,
      );
    });

    test('rejected filter returns only rejected transactions', () {
      wallet.setFilter(TransactionFilter.rejected);
      final result = wallet.filteredTransactions;
      expect(
        result.every((t) => t.status == TransactionStatus.rejected),
        isTrue,
      );
    });

    test('credits filter returns only credit-type transactions', () {
      wallet.setFilter(TransactionFilter.credits);
      final result = wallet.filteredTransactions;
      expect(result.every((t) => t.type == TransactionType.credit), isTrue);
    });
  });
}
