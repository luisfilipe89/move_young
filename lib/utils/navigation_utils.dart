import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

class NavigationUtils {
  static void shareLocation(String name, String lat, String lon) {
    final message = "Meet me at $name! 📍 https://maps.google.com/?q=$lat,$lon";
    Share.share(message);
  }

  static Future<void> openDirections(BuildContext context, String lat, String lon) async {
    final url = 'https://www.google.com/maps/dir/?api=1&destination=$lat,$lon&travelmode=walking';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open Google Maps')),
      );
    }
  }
}
