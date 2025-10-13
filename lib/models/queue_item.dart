import 'package:cloud_firestore/cloud_firestore.dart';

class QueueItem {
  final String id;
  final String name;
  final String service;
  final int queueNumber;
  final Timestamp timestamp;
  final String userId; // BARU: ID pengguna yang membuat antrian
  final Timestamp appointmentDate; // BARU: Tanggal janji temu yang dipilih

  QueueItem({
    required this.id,
    required this.name,
    required this.service,
    required this.queueNumber,
    required this.timestamp,
    required this.userId, // BARU
    required this.appointmentDate, // BARU
  });

  factory QueueItem.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return QueueItem(
      id: doc.id,
      name: data['name'] ?? '',
      service: data['service'] ?? 'Lainnya',
      queueNumber: data['queueNumber'] ?? 0,
      timestamp: data['timestamp'] ?? Timestamp.now(),
      // Baca data baru dari Firestore, berikan nilai default jika tidak ada
      userId: data['userId'] ?? '',
      appointmentDate: data['appointmentDate'] ?? Timestamp.now(),
    );
  }

  // Method ini opsional tapi baik untuk dilengkapi
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'service': service,
      'queueNumber': queueNumber,
      'timestamp': timestamp,
      'userId': userId,
      'appointmentDate': appointmentDate,
    };
  }
}
