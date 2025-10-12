import 'package:flutter/material.dart';

class QueueSummaryCard extends StatelessWidget {
  final int totalQueue;
  final int nextNumber;

  const QueueSummaryCard({
    Key? key,
    required this.totalQueue,
    required this.nextNumber,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4.0,
      margin: const EdgeInsets.all(16.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildSummaryItem(context, 'Total Antrian', totalQueue.toString()),
            Container(height: 50, width: 1, color: Colors.grey.shade300),
            _buildSummaryItem(
              context,
              'Nomor Berikutnya',
              nextNumber != -1 ? nextNumber.toString() : '-',
              isHighlight: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(
    BuildContext context,
    String title,
    String value, {
    bool isHighlight = false,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: isHighlight ? colorScheme.secondary : colorScheme.primary,
          ),
        ),
      ],
    );
  }
}
