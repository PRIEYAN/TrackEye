import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../core/constants.dart';
import '../../widgets/shipment_map_widget.dart';
import 'quote_comparison_view.dart';

class ShipmentDetailView extends StatelessWidget {
  final Shipment shipment;

  const ShipmentDetailView({super.key, required this.shipment});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Shipment Details', style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatusHeader(),
            const SizedBox(height: 24),
            _buildInfoSection('Route Information', [
              _buildInfoRow(Icons.location_on_outlined, 'Origin', shipment.originPort),
              _buildInfoRow(Icons.location_on, 'Destination', shipment.destinationPort),
              if (shipment.preferredEtd != null)
                _buildInfoRow(Icons.calendar_today, 'Preferred ETD', shipment.preferredEtd!.toLocal().toString().split(' ')[0]),
              if (shipment.preferredEta != null)
                _buildInfoRow(Icons.calendar_month, 'Preferred ETA', shipment.preferredEta!.toLocal().toString().split(' ')[0]),
              if (shipment.actualEtd != null)
                _buildInfoRow(Icons.flight_takeoff, 'Actual ETD', shipment.actualEtd!.toLocal().toString().split(' ')[0]),
              if (shipment.actualEta != null)
                _buildInfoRow(Icons.flight_land, 'Actual ETA', shipment.actualEta!.toLocal().toString().split(' ')[0]),
            ]),
            if (shipment.originLatitude != null &&
                shipment.originLongitude != null &&
                shipment.destinationLatitude != null &&
                shipment.destinationLongitude != null) ...[
              const SizedBox(height: 16),
              ShipmentMapWidget(
                pickupLocation: shipment.originPort,
                dropLocation: shipment.destinationPort,
                pickupLatitude: shipment.originLatitude,
                pickupLongitude: shipment.originLongitude,
                dropLatitude: shipment.destinationLatitude,
                dropLongitude: shipment.destinationLongitude,
              ),
            ],
            const SizedBox(height: 16),
            _buildInfoSection('Cargo Details', [
              if (shipment.cargoType != null)
                _buildInfoRow(Icons.inventory_2_outlined, 'Type', shipment.cargoType!),
              if (shipment.grossWeightKg != null)
                _buildInfoRow(Icons.monitor_weight_outlined, 'Weight', '${shipment.grossWeightKg!.toStringAsFixed(1)} kg'),
              if (shipment.volumeCbm != null)
                _buildInfoRow(Icons.square_foot, 'Volume', '${shipment.volumeCbm!.toStringAsFixed(1)} cbm'),
              if (shipment.packageType != null)
                _buildInfoRow(Icons.inventory, 'Package Type', shipment.packageType!),
              if (shipment.totalPackages != null)
                _buildInfoRow(Icons.numbers, 'Total Packages', shipment.totalPackages!.toString()),
            ]),
            const SizedBox(height: 32),
            if (shipment.status == 'pending_quote' || shipment.status == 'draft')
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => QuoteComparisonView(shipmentId: shipment.id)),
                    );
                  },
                  icon: const Icon(Icons.compare_arrows),
                  label: const Text('Compare Quotes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstants.accentColor,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppConstants.primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppConstants.primaryColor.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          const Text('CURRENT STATUS', style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(shipment.status.toUpperCase(), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppConstants.primaryColor)),
        ],
      ),
    );
  }

  Widget _buildInfoSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(children: children),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(color: Colors.grey)),
          const Spacer(),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

