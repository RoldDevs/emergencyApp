import 'package:flutter/material.dart';

class UserLocationMarker extends StatelessWidget {
  const UserLocationMarker({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        // Increased opacity for better visibility
        color: Color.fromRGBO(33, 150, 243, 0.7),
        shape: BoxShape.circle,
      ),
      child: const Padding(
        padding: EdgeInsets.all(6.0), // Increased padding
        child: Icon(
          Icons.my_location,
          color: Colors.white,
          size: 24, // Increased size
        ),
      ),
    );
  }
}
