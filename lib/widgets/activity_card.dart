import 'package:flutter/material.dart';

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
      margin: const EdgeInsets.only(top: 4, bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: GestureDetector(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
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
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('🔥', style: TextStyle(fontSize: 14)),
                      const SizedBox(width: 4),
                      Text(
                        calories,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.black54,
                          fontWeight: FontWeight.w400,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
