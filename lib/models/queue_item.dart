import 'package:cloud_firestore/cloud_firestore.dart';

class QueueItem {
  final String id;
  final String name;
  final String service;
  final int queueNumber;
  final Timestamp timestamp;

  QueueItem({
    required this.id,
    required this.name,
    required this.service,
    required this.queueNumber,
    required this.timestamp,
  });

  // Factory constructor untuk membuat instance dari Firestore document
  factory QueueItem.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return QueueItem(
      id: doc.id,
      name: data['name'] ?? '',
      service: data['service'] ?? 'Lainnya',
      queueNumber: data['queueNumber'] ?? 0,
      timestamp: data['timestamp'] ?? Timestamp.now(),
    );
  }

  // Method untuk mengubah instance menjadi Map untuk disimpan ke Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'service': service,
      'queueNumber': queueNumber,
      'timestamp': timestamp,
    };
  }
}
