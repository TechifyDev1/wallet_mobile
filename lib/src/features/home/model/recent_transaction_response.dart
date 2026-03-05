import 'package:decimal/decimal.dart';

enum EntryType { credit, debit }

enum TransactionStatus { pending, completed, failed, success }

class RecentTransactionResponse {
  final String systemDescription;
  final Decimal amount;
  final DateTime time;
  final EntryType entryType;
  final TransactionStatus status;
  final String reference;
  final String note;

  RecentTransactionResponse({
    required this.systemDescription,
    required this.amount,
    required this.time,
    required this.entryType,
    required this.status,
    required this.reference,
    required this.note,
  });

  factory RecentTransactionResponse.fromJson(Map<String, dynamic> json) {
    return RecentTransactionResponse(
      systemDescription: json['systemDescription'] ?? '',
      amount: Decimal.parse(json['amount'].toString()),
      time: DateTime.parse(json['time']),
      entryType: _parseEntryType(json['entryType']),
      status: _parseStatus(json['status']),
      reference: json['reference'] ?? '',
      note: json['note'] ?? '',
    );
  }

  static EntryType _parseEntryType(String value) {
    return EntryType.values.firstWhere(
      (e) => e.name.toUpperCase() == value.toUpperCase(),
      orElse: () => EntryType.debit,
    );
  }

  static TransactionStatus _parseStatus(String value) {
    return TransactionStatus.values.firstWhere(
      (e) => e.name.toUpperCase() == value.toUpperCase(),
      orElse: () => TransactionStatus.failed,
    );
  }
}
