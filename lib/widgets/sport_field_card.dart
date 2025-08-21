import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:move_young/theme/tokens.dart';

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
      padding: AppPaddings.symmReg,
      child: Container(
        decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppRadius.card),
            boxShadow: AppShadows.md),
        child: Padding(
          padding: AppPaddings.allReg,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image
              if (imageUrl != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.image),
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
                      color: AppColors.lightgrey,
                      child: const Icon(Icons.broken_image),
                    ),
                  ),
                )
              else
                Container(
                  height: 140,
                  decoration: BoxDecoration(
                    color: AppColors.superlightgrey,
                    borderRadius: BorderRadius.circular(AppRadius.image),
                  ),
                  child: const Center(child: Icon(Icons.image_not_supported)),
                ),
              const SizedBox(height: 2),

              // Title
              FutureBuilder<String>(
                future: getDisplayName(field),
                builder: (context, snapshot) {
                  return Text(snapshot.data ?? 'unnamed_field'.tr(),
                      style: AppTextStyles.cardTitle);
                },
              ),
              const SizedBox(height: AppHeights.small),

              // Distance
              Text(
                distanceText,
                style: TextStyle(color: AppColors.blackopac),
              ),
              const SizedBox(height: 8),

              // Characteristics
              characteristics,
              const SizedBox(height: 6),

              // Action Buttons
              Center(
                child: Padding(
                  padding: AppPaddings.topSuperSmall,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        icon: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color:
                              isFavorite ? AppColors.red : AppColors.blackIcon,
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
