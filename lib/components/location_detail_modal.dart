import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Add this import for clipboard functionality
import 'package:emergency_app/models/emergency_location.dart';
import 'package:url_launcher/url_launcher.dart';

class LocationDetailModal extends StatelessWidget {
  final EmergencyLocation location;

  const LocationDetailModal({super.key, required this.location});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 40), // Added bottom margin to avoid nav bar overlap
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            spreadRadius: 5,
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(context),
            const Divider(thickness: 1.5),
            const SizedBox(height: 8),
            _buildInfoSection(),
            const SizedBox(height: 16),
            _buildCoordinatesCard(),
            if (location.description.isNotEmpty) ...[  
              const SizedBox(height: 16),
              _buildDescriptionSection(),
            ],
            const SizedBox(height: 20),
            _buildActionButtons(context),
            const SizedBox(height: 16), // Added extra bottom padding
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        _buildTypeIcon(),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            location.name,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }

  Widget _buildInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoRow(Icons.phone, 'Hotline', location.phone),
        if (location.address.isNotEmpty)
          _buildInfoRow(Icons.location_on, 'Location', location.address),
        if (location.operatingHours.isNotEmpty)
          _buildInfoRow(Icons.access_time, 'Hours', location.operatingHours),
        if (location.website.isNotEmpty)
          _buildInfoRow(Icons.language, 'Website', location.website, isLink: true),
      ],
    );
  }

  Widget _buildCoordinatesCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Coordinates',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildCoordinateItem('Latitude', location.latitude.toStringAsFixed(6)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildCoordinateItem('Longitude', location.longitude.toStringAsFixed(6)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCoordinateItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
        const SizedBox(height: 4),
        SelectableText(
          value,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildDescriptionSection() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.info_outline, size: 18),
              SizedBox(width: 8),
              Text(
                'About',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            location.description,
            style: const TextStyle(height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildActionButton(
          context,
          Icons.phone,
          'Call',
          Colors.green,
          () => _launchUrl('tel:${location.phone.replaceAll(RegExp(r'\D'), '')}'),
        ),
        _buildActionButton(
          context,
          Icons.directions,
          'Directions',
          Colors.red,
          () => _launchUrl('https://www.google.com/maps/dir/?api=1&destination=${location.latitude},${location.longitude}'),
        ),
        _buildActionButton(
          context,
          Icons.copy,  // Changed from share to copy icon
          'Copy',     // Changed label from Share to Copy
          Colors.orange,
          () => _shareLocation(context),  // Pass context to the method
        ),
      ],
    );
  }

  Widget _buildTypeIcon() {
    IconData icon;
    Color color;

    switch (location.type) {
      case EmergencyLocationType.hospital:
        icon = Icons.local_hospital;
        color = Colors.red;
        break;
      case EmergencyLocationType.police:
        icon = Icons.local_police;
        color = Colors.blue;
        break;
      case EmergencyLocationType.fireStation:
        icon = Icons.fire_truck;
        color = Colors.orange;
        break;
      default:
        icon = Icons.emergency;
        color = Colors.purple;
    }

    return Container(
      padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
      child: Icon(icon, color: color, size: 24),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, {bool isLink = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                const SizedBox(height: 2),
                isLink
                    ? GestureDetector(
                        onTap: () => _launchUrl(value),
                        child: Text(
                          value,
                          style: const TextStyle(
                            color: Colors.blue,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      )
                    : SelectableText(value),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, IconData icon, String label, Color color, VoidCallback onPressed) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: ElevatedButton.icon(
          onPressed: onPressed,
          icon: Icon(icon, color: Colors.white, size: 18),
          label: Text(label),
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }

  void _shareLocation(BuildContext context) {  // Add context parameter
    // Format coordinates with 6 decimal places for precision
    final String coordinates = "${location.latitude.toStringAsFixed(6)}, ${location.longitude.toStringAsFixed(6)}";
    
    // Copy to clipboard
    Clipboard.setData(ClipboardData(text: coordinates));
    
    // Show a confirmation message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Coordinates copied to clipboard'),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}