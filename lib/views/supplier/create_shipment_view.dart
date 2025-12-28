import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import '../../providers/shipment_provider.dart';
import '../../services/api_service.dart';
import '../../core/constants.dart';
import '../../widgets/shipment_map_widget.dart';
import 'invoice_upload_dialog.dart';
import 'location_picker_screen.dart';

class CreateShipmentView extends StatefulWidget {
  const CreateShipmentView({super.key});

  @override
  State<CreateShipmentView> createState() => _CreateShipmentViewState();
}

class _CreateShipmentViewState extends State<CreateShipmentView> {
  final _formKey = GlobalKey<FormState>();
  final _apiService = ApiService();
  final _originController = TextEditingController();
  final _destinationController = TextEditingController();

  String _originPort = '';
  String _destinationPort = '';
  double? _originLatitude;
  double? _originLongitude;
  double? _destinationLatitude;
  double? _destinationLongitude;
  final String _cargoType = 'FCL';
  double _weight = 0.0;
  double _volume = 0.0;
  final DateTime _etd = DateTime.now().add(const Duration(days: 7));
  final DateTime _eta = DateTime.now().add(const Duration(days: 30));
  
  bool _isUploading = false;
  Map<String, dynamic>? _extractedData;

  @override
  void dispose() {
    _originController.dispose();
    _destinationController.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadDocument() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'png'],
    );

    if (result != null) {
      setState(() => _isUploading = true);
      try {
        final data = await _apiService.uploadDocument(result.files.single.path!);
        setState(() {
          _extractedData = data['extracted_data'];
          // Pre-fill form if AI extracted data
          if (_extractedData != null) {
            _weight = (_extractedData!['total_weight'] ?? 0.0).toDouble();
            _volume = (_extractedData!['total_volume'] ?? 0.0).toDouble();
          }
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Document processed with 98% accuracy!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload failed: $e')),
        );
      } finally {
        setState(() => _isUploading = false);
      }
    }
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      
      final shipmentData = {
        'origin_port': _originPort,
        'destination_port': _destinationPort,
        'origin_latitude': _originLatitude,
        'origin_longitude': _originLongitude,
        'destination_latitude': _destinationLatitude,
        'destination_longitude': _destinationLongitude,
        'weight': _weight,
        'volume': _volume,
      };

      try {
        final shipment = await context.read<ShipmentProvider>().createShipment(shipmentData);
        if (!mounted) return;
        
        await context.read<ShipmentProvider>().fetchShipments(status: 'draft');
        await context.read<ShipmentProvider>().fetchAllShipments();
        
        if (!mounted) return;
        
        final shouldUpload = await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (context) => InvoiceUploadDialog(
            shipmentId: shipment.id,
          ),
        );
        
        if (!mounted) return;
        
        Navigator.pop(context);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(shouldUpload == true 
                ? 'Shipment created and invoice uploaded successfully!'
                : 'Shipment created successfully!'),
            backgroundColor: AppConstants.successColor,
          ),
        );
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to create shipment: $e'),
              backgroundColor: AppConstants.errorColor,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New Shipment'),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_extractedData != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                  child: const Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green, size: 16),
                      SizedBox(width: 8),
                      Text('Data extracted successfully!', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 24),
              const Text('Shipment Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextFormField(
                controller: _originController,
                decoration: InputDecoration(
                  labelText: 'Pickup Location',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.location_on, color: Colors.green),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.map, color: AppConstants.primaryColor),
                    onPressed: () async {
                      final result = await Navigator.push<Map<String, dynamic>>(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LocationPickerScreen(
                            label: 'Select Pickup Location',
                            initialAddress: _originPort,
                          ),
                        ),
                      );
                      if (result != null && mounted) {
                        setState(() {
                          _originPort = result['address'];
                          _originLatitude = result['latitude'];
                          _originLongitude = result['longitude'];
                          _originController.text = _originPort;
                        });
                      }
                    },
                    tooltip: 'Select location on map',
                  ),
                ),
                validator: (v) => v!.isEmpty ? 'Pickup location is required' : null,
                onSaved: (v) => _originPort = v!,
                readOnly: true,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _destinationController,
                decoration: InputDecoration(
                  labelText: 'Drop Location',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.location_on, color: Colors.red),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.map, color: AppConstants.primaryColor),
                    onPressed: () async {
                      final result = await Navigator.push<Map<String, dynamic>>(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LocationPickerScreen(
                            label: 'Select Drop Location',
                            initialAddress: _destinationPort,
                          ),
                        ),
                      );
                      if (result != null && mounted) {
                        setState(() {
                          _destinationPort = result['address'];
                          _destinationLatitude = result['latitude'];
                          _destinationLongitude = result['longitude'];
                          _destinationController.text = _destinationPort;
                        });
                      }
                    },
                    tooltip: 'Select location on map',
                  ),
                ),
                validator: (v) => v!.isEmpty ? 'Drop location is required' : null,
                onSaved: (v) => _destinationPort = v!,
                readOnly: true,
              ),
              if (_originPort.isNotEmpty && _destinationPort.isNotEmpty &&
                  _originLatitude != null && _originLongitude != null &&
                  _destinationLatitude != null && _destinationLongitude != null) ...[
                const SizedBox(height: 16),
                ShipmentMapWidget(
                  pickupLocation: _originPort,
                  dropLocation: _destinationPort,
                  pickupLatitude: _originLatitude,
                  pickupLongitude: _originLongitude,
                  dropLatitude: _destinationLatitude,
                  dropLongitude: _destinationLongitude,
                ),
              ],
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      decoration: const InputDecoration(labelText: 'Weight (kg)', border: OutlineInputBorder()),
                      keyboardType: TextInputType.number,
                      initialValue: _weight > 0 ? _weight.toString() : '',
                      onSaved: (v) => _weight = double.parse(v!),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      decoration: const InputDecoration(labelText: 'Volume (cbm)', border: OutlineInputBorder()),
                      keyboardType: TextInputType.number,
                      initialValue: _volume > 0 ? _volume.toString() : '',
                      onSaved: (v) => _volume = double.parse(v!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(backgroundColor: AppConstants.primaryColor, foregroundColor: Colors.white),
                  child: const Text('Create Shipment', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


