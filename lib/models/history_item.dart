// lib/models/history_item.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class HistoryItem {
  final String id;
  final String name;
  final String service;
  final int queueNumber;
  final Timestamp createdAt; // Waktu dibuat
  final Timestamp servedAt; // Waktu dilayani

  HistoryItem({
    required this.id,
    required this.name,
    required this.service,
    required this.queueNumber,
    required this.createdAt,
    required this.servedAt,
  });

  factory HistoryItem.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return HistoryItem(
      id: doc.id,
      name: data['name'] ?? '',
      service: data['service'] ?? 'Lainnya',
      queueNumber: data['queueNumber'] ?? 0,
      // Gunakan 'timestamp' dari data lama sebagai 'createdAt'
      createdAt: data['createdAt'] ?? Timestamp.now(),
      servedAt: data['servedAt'] ?? Timestamp.now(),
    );
  }
}
