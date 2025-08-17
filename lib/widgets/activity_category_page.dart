// file: widgets/activity_category_page.dart

import 'package:flutter/material.dart';
import 'package:move_young/widgets/activity_card.dart';
import 'package:easy_localization/easy_localization.dart';

class ActivityCategoryPage extends StatefulWidget {
  final List<Map<String, String>> activities;
  final Function(String title) onTapActivity;

  const ActivityCategoryPage({
    super.key,
    required this.activities,
    required this.onTapActivity,
  });

  @override
  State<ActivityCategoryPage> createState() => _ActivityCategoryPageState();
}

class _ActivityCategoryPageState extends State<ActivityCategoryPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  Alignment _parseAlignment(String? v) {
    switch (v) {
      case 'top':
        return Alignment.topCenter;
      case 'bottom':
        return Alignment.bottomCenter;
      case 'left':
        return Alignment.centerLeft;
      case 'right':
        return Alignment.centerRight;
      case 'center':
        return Alignment.center;
      default:
        if (v == null || !v.contains(',')) return Alignment.center;
        final parts = v.split(',');
        final dx = double.tryParse(parts[0].trim()) ?? 0.0;
        final dy = double.tryParse(parts[1].trim()) ?? 0.0;
        return Alignment(dx, dy); // e.g. "0,-0.6"
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // ⚠️ required!
    return ListView.builder(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      itemCount: widget.activities.length,
      itemBuilder: (context, index) {
        final activity = widget.activities[index];
        final Alignment imageAlignment = _parseAlignment(activity['align']);

        return ActivityCard(
          title: activity['title']!.tr(),
          imageUrl: activity['image'] ?? '',
          calories: activity['calories'] ?? '',
          imageAlignment: imageAlignment,
          onTap: () => widget.onTapActivity(activity['title']!),
        );
      },
    );
  }
}
