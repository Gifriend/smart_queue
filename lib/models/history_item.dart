import 'package:cloud_firestore/cloud_firestore.dart';

class HistoryItem {
  final String id;
  final String name;
  final String service;
  final int queueNumber;
  final Timestamp createdAt;
  final Timestamp servedAt;

  // BARU: Field tambahan untuk slip detail
  final String userId;
  final String tellerId;
  final Timestamp appointmentDate;
  final double transactionAmount;
  final String transactionNotes;

  HistoryItem({
    required this.id,
    required this.name,
    required this.service,
    required this.queueNumber,
    required this.createdAt,
    required this.servedAt,
    // BARU
    required this.userId,
    required this.tellerId,
    required this.appointmentDate,
    required this.transactionAmount,
    required this.transactionNotes,
  });

  factory HistoryItem.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return HistoryItem(
      id: doc.id,
      name: data['name'] ?? '',
      service: data['service'] ?? 'Lainnya',
      queueNumber: data['queueNumber'] ?? 0,
      createdAt: data['createdAt'] ?? Timestamp.now(),
      servedAt: data['servedAt'] ?? Timestamp.now(),
      // BARU: Baca data tambahan dari Firestore dengan nilai default
      userId: data['userId'] ?? '',
      tellerId: data['tellerId'] ?? 'N/A',
      appointmentDate: data['appointmentDate'] ?? Timestamp.now(),
      transactionAmount: (data['transactionAmount'] ?? 0.0).toDouble(),
      transactionNotes: data['transactionNotes'] ?? '',
    );
  }
}
