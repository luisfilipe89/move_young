import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';

class SportFieldCard extends StatelessWidget {
  final Map<String, dynamic> field;
  final bool isFavorite;
  final String distanceText;
  final Future<String> Function(Map<String, dynamic>) getDisplayName;
  final Widget characteristics;
  final VoidCallback onToggleFavorite;
  final VoidCallback onShare;
  final VoidCallback onDirections;

  const SportFieldCard({
    super.key,
    required this.field,
    required this.isFavorite,
    required this.distanceText,
    required this.getDisplayName,
    required this.characteristics,
    required this.onToggleFavorite,
    required this.onShare,
    required this.onDirections,
  });

  @override
  Widget build(BuildContext context) {
    final imageUrl = field['tags']?['image'];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image
              if (imageUrl != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CachedNetworkImage(
                    imageUrl: imageUrl,
                    height: 140,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    fadeInDuration: const Duration(milliseconds: 300),
                    placeholder: (context, url) => const SizedBox(
                      height: 140,
                      child: Center(child: CircularProgressIndicator()),
                    ),
                    errorWidget: (context, url, error) => Container(
                      height: 140,
                      color: Colors.grey[300],
                      child: const Icon(Icons.broken_image),
                    ),
                  ),
                )
              else
                Container(
                  height: 140,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(child: Icon(Icons.image_not_supported)),
                ),
              const SizedBox(height: 2),

              // Title
              FutureBuilder<String>(
                future: getDisplayName(field),
                builder: (context, snapshot) {
                  return Text(
                    snapshot.data ?? 'unnamed_field'.tr(),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
                    ),
                  );
                },
              ),
              const SizedBox(height: 4),

              // Distance
              Text(
                distanceText,
                style: const TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 8),

              // Characteristics
              characteristics,
              const SizedBox(height: 6),

              // Action Buttons
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        icon: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: isFavorite ? Colors.red : Colors.black,
                          size: 24,
                        ),
                        tooltip: 'favorite'.tr(),
                        onPressed: onToggleFavorite,
                      ),
                      IconButton(
                        icon: Icon(Icons.share, size: 24),
                        tooltip: 'share_location'.tr(),
                        onPressed: onShare,
                      ),
                      IconButton(
                        icon: Icon(Icons.directions, size: 24),
                        tooltip: 'directions'.tr(),
                        onPressed: onDirections,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
