import 'package:intl/intl.dart';
import '../../features/sales/models/commissions_state.dart' show PayoutDto;
import '../../features/sales/models/sales_state.dart' show TransactionDto;
import '../../features/stations/models/station_state.dart'
    show BatteryDto, ReviewDto, SwapDto;
import 'web_download.dart';

class ExportHelper {
  static void exportTransactionsToCsv(
      List<TransactionDto> transactions, String fileName) {
    final buffer = StringBuffer();

    // Header
    buffer.writeln(
        'ID,Date,Time,Customer,Phone,Battery ID,Station,Type,Amount,Status,Payment Method');

    // Data
    for (final tx in transactions) {
      final date = DateTime.tryParse(tx.createdAt)?.toLocal() ?? DateTime.now();
      final dateStr = DateFormat('yyyy-MM-dd').format(date);
      final timeStr = DateFormat('HH:mm:ss').format(date);

      final row = [
        'TXN-${tx.id}',
        dateStr,
        timeStr,
        '"${tx.customerName ?? 'N/A'}"',
        tx.customerPhone ?? 'N/A',
        tx.batteryId ?? 'N/A',
        '"${tx.stationName ?? 'N/A'}"',
        tx.transactionType,
        tx.amount.toString(),
        tx.status,
        tx.paymentMethod ?? 'N/A',
      ];

      buffer.writeln(row.join(','));
    }

    triggerWebDownload(buffer.toString(),
        fileName.endsWith('.csv') ? fileName : '$fileName.csv');
  }

  static void exportTransactionsToPdf(
      List<TransactionDto> transactions, String fileName) {
    // For now, since we don't have a PDF package in pubspec,
    // we'll export as a formatted text file that can be printed or saved.
    // In a real production app, we would use 'package:pdf'.

    final buffer = StringBuffer();
    buffer.writeln('TRANSACTION REPORT');
    buffer.writeln(
        'Generated on: ${DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now())}');
    buffer.writeln('=' * 80);
    buffer.writeln('');

    for (final tx in transactions) {
      buffer.writeln('TXN ID: TXN-${tx.id}');
      buffer.writeln('Date: ${tx.createdAt}');
      buffer.writeln('Customer: ${tx.customerName} (${tx.customerPhone})');
      buffer.writeln('Station: ${tx.stationName} | Slot: ${tx.terminalNumber}');
      buffer.writeln('Type: ${tx.transactionType} | Amount: ₹${tx.amount}');
      buffer.writeln('Status: ${tx.status}');
      buffer.writeln('-' * 40);
    }

    triggerWebDownload(buffer.toString(),
        fileName.endsWith('.pdf') ? fileName : '$fileName.pdf');
  }

  static void exportBatteriesToCsv(
      List<BatteryDto> batteries, String fileName) {
    final buffer = StringBuffer();
    buffer.writeln(
        'Serial Number,Status,Charge %,Health %,Cycles,Type,Current Customer,Days Idle,Fault,Created');
    for (final b in batteries) {
      final row = [
        b.serialNumber,
        b.status,
        b.chargePercentage.toStringAsFixed(1),
        b.healthPercentage.toStringAsFixed(1),
        b.cycleCount.toString(),
        b.batteryType,
        '"${b.currentCustomer ?? ''}"',
        b.daysIdle.toString(),
        '"${b.faultDescription ?? ''}"',
        b.createdAt ?? '',
      ];
      buffer.writeln(row.join(','));
    }
    triggerWebDownload(buffer.toString(),
        fileName.endsWith('.csv') ? fileName : '$fileName.csv');
  }

  static void exportReviewsToCsv(List<ReviewDto> reviews, String fileName) {
    final buffer = StringBuffer();
    buffer.writeln(
        'ID,Date,Station,Customer,Rating,Review,Dealer Reply,Verified Rental');
    for (final r in reviews) {
      final row = [
        r.id.toString(),
        r.createdAt,
        '"${r.stationName}"',
        '"${r.customerName}"',
        r.rating.toString(),
        '"${r.reviewText ?? ''}"',
        '"${r.dealerReply ?? ''}"',
        r.isVerifiedRental ? 'Yes' : 'No',
      ];
      buffer.writeln(row.join(','));
    }
    triggerWebDownload(
      buffer.toString(),
      fileName.endsWith('.csv') ? fileName : '$fileName.csv',
    );
  }

  static void exportSwapsToCsv(List<SwapDto> swaps, String fileName) {
    final buffer = StringBuffer();
    buffer.writeln(
      'ID,Date,Customer,Station,Returned Battery,Returned SOC,Received Battery,Received SOC,Amount,Status,Payment',
    );
    for (final s in swaps) {
      final row = [
        s.id.toString(),
        s.createdAt,
        '"${s.customerName}"',
        '"${s.stationName}"',
        s.oldBatteryCode,
        s.oldBatterySoc.toStringAsFixed(0),
        s.newBatteryCode,
        s.newBatterySoc.toStringAsFixed(0),
        s.swapAmount.toStringAsFixed(2),
        s.status,
        s.paymentStatus,
      ];
      buffer.writeln(row.join(','));
    }
    triggerWebDownload(
      buffer.toString(),
      fileName.endsWith('.csv') ? fileName : '$fileName.csv',
    );
  }

  static void exportPayoutToCsv(PayoutDto payout, String fileName) {
    final buffer = StringBuffer();
    buffer.writeln('ID,Date,Amount,Status,Bank,Account,IFSC');

    final date = DateTime.tryParse(payout.date)?.toLocal() ?? DateTime.now();
    final dateStr = DateFormat('yyyy-MM-dd HH:mm').format(date);

    final row = [
      'PAY-${payout.id}',
      dateStr,
      payout.amount.toString(),
      payout.status,
      '"${payout.bankName ?? 'N/A'}"',
      payout.accountMask ?? 'N/A',
      payout.ifsc ?? 'N/A',
    ];

    buffer.writeln(row.join(','));
    triggerWebDownload(buffer.toString(),
        fileName.endsWith('.csv') ? fileName : '$fileName.csv');
  }
}
