import 'package:flutter/material.dart';
import '../../core/constants.dart';

class HistoryView extends StatelessWidget {
  const HistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        title: const Text('History', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: AppConstants.primaryColor,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Static History Card 1
          _buildHistoryCard(
            title: 'Shipment Completed',
            description: 'SH12345678 - Mumbai to New York',
            date: '2024-12-15',
            status: 'Delivered',
            statusColor: AppConstants.successColor,
          ),
          const SizedBox(height: 12),
          // Static History Card 2
          _buildHistoryCard(
            title: 'Quote Accepted',
            description: 'SH87654321 - Chennai to Singapore',
            date: '2024-12-10',
            status: 'In Transit',
            statusColor: AppConstants.primaryColor,
          ),
          const SizedBox(height: 12),
          // Static History Card 3
          _buildHistoryCard(
            title: 'Shipment Created',
            description: 'SH11223344 - Delhi to Dubai',
            date: '2024-12-05',
            status: 'Booked',
            statusColor: AppConstants.accentColor,
          ),
          const SizedBox(height: 12),
          // Static History Card 4
          _buildHistoryCard(
            title: 'Quote Submitted',
            description: 'SH55667788 - Kolkata to Bangkok',
            date: '2024-11-28',
            status: 'Quoted',
            statusColor: Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard({
    required String title,
    required String description,
    required String date,
    required String status,
    required Color statusColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 60,
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      date,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: statusColor),
                      ),
                      child: Text(
                        status,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

