// file: widgets/activity_category_page.dart

import 'package:flutter/material.dart';
import 'package:move_young/widgets/activity_card.dart';

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

  @override
  Widget build(BuildContext context) {
    super.build(context); // ⚠️ required!
    return ListView.builder(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      itemCount: widget.activities.length,
      itemBuilder: (context, index) {
        final activity = widget.activities[index];
        return ActivityCard(
          title: activity['title']!,
          imageUrl: activity['image']!,
          calories: activity['calories']!,
          onTap: () => widget.onTapActivity(activity['title']!),
        );
      },
    );
  }
}
