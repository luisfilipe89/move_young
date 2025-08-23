import 'package:flutter/material.dart';
import 'package:move_young/theme/tokens.dart';

class ActivityCard extends StatelessWidget {
  final String title;
  final String imageUrl;
  final String calories;
  final VoidCallback onTap;
  final Alignment imageAlignment;

  const ActivityCard({
    super.key,
    required this.title,
    required this.imageUrl,
    required this.calories,
    required this.onTap,
    this.imageAlignment = Alignment.center, // default
  });

  @override
  Widget build(BuildContext context) {
    final isNetworkImage = imageUrl.startsWith('http');

    return Container(
      margin: AppPaddings.topBottom,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.card),
        boxShadow: AppShadows.md,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadius.card),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: AppPaddings.allSmall,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.image),
                  child: isNetworkImage
                      ? Image.network(
                          imageUrl,
                          height: 100,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          alignment: imageAlignment,
                        )
                      : Image.asset(
                          imageUrl,
                          height: 100,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          alignment: imageAlignment,
                        ),
                ),
                const SizedBox(height: AppHeights.reg),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(title, style: AppTextStyles.cardTitle),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('🔥', style: AppTextStyles.small),
                        const SizedBox(width: AppWidths.small),
                        Text(calories, style: AppTextStyles.small),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
