import 'package:flutter/material.dart';
import 'package:move_young/models/event_model.dart';
import 'package:move_young/services/load_events_from_json.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:move_young/theme/tokens.dart';

class HomeScreenNew extends StatefulWidget {
  const HomeScreenNew({super.key});

  @override
  State<HomeScreenNew> createState() => _HomeScreenNewState();
}

class _HomeScreenNewState extends State<HomeScreenNew> {
  List<Event> events = [];

  @override
  void initState() {
    super.initState();
    loadEvents();
  }

  Future<void> loadEvents() async {
    final loaded = await loadEventsFromJson();
    setState(() {
      events = loaded;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: const Icon(Icons.menu),
        title: const Text(
          'SMARTPLAYER',
        ),
        centerTitle: true,
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.language),
            label: Text(
              context.locale.languageCode == 'nl' ? 'EN' : 'NL',
              style: AppTextStyles.body,
            ),
            onPressed: () {
              final curr = context.locale;
              context.setLocale(
                curr.languageCode == 'nl'
                    ? const Locale('en')
                    : const Locale('nl'),
              );
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.blackIcon),
          ),
          IconButton(
            icon: const Icon(Icons.qr_code),
            onPressed: () {
              // TODO: Implement QR code scan
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: AppPaddings.allReg,
          child: Container(
            decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(AppRadius.container),
                boxShadow: AppShadows.md),
            padding: AppPaddings.allBig,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("hello".tr(), style: AppTextStyles.headline),
                const SizedBox(height: AppHeights.huge),

                // Tile to go to Activities Screen
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).pushNamed('/activities');
                  },
                  child: Container(
                    decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(AppRadius.card),
                        boxShadow: AppShadows.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(AppRadius.card),
                            topRight: Radius.circular(AppRadius.card),
                          ),
                          child: Image.asset(
                            'assets/images/general_public.jpg',
                            height: 100,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Padding(
                          padding: AppPaddings.allMedium,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("check_for_fields".tr(),
                                  style: AppTextStyles.cardTitle),
                              SizedBox(height: 1),
                              Text("look_for_fields".tr(),
                                  style: AppTextStyles.bodyMuted),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppHeights.huge),

                // Upcoming Events Tile
                Container(
                  decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(AppRadius.card),
                      boxShadow: AppShadows.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: AppPaddings.allMedium,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("upcoming_events".tr(),
                                style: AppTextStyles.cardTitle),
                            SizedBox(height: AppHeights.small),
                            Text("join_sports_event".tr(),
                                style: AppTextStyles.body),
                          ],
                        ),
                      ),
                      Divider(height: 1, color: AppColors.lightgrey),
                      SizedBox(
                        height: 240,
                        child: ListView.builder(
                          itemCount: events.length,
                          shrinkWrap: true,
                          physics: const BouncingScrollPhysics(),
                          itemBuilder: (context, index) {
                            final event = events[index];

                            return Column(
                              children: [
                                ListTile(
                                  contentPadding:
                                      AppPaddings.symmHorizontalMedium,
                                  leading: const Icon(Icons.event),
                                  title: Text(
                                    event.title,
                                    style: AppTextStyles.cardTitle,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  subtitle: Padding(
                                    padding: AppPaddings.topSuperSmall,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            const Icon(Icons.access_time,
                                                size: 14,
                                                color: AppColors.grey),
                                            const SizedBox(
                                                width: AppWidths.small),
                                            Expanded(
                                              child: Text(
                                                event.dateTime,
                                                style: AppTextStyles.small,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            const Icon(Icons.group,
                                                size: 14,
                                                color: AppColors.grey),
                                            const SizedBox(
                                                width: AppWidths.small),
                                            Expanded(
                                              child: Text(
                                                event.targetGroup,
                                                style: AppTextStyles.small,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            const Icon(Icons.location_on,
                                                size: 14,
                                                color: AppColors.grey),
                                            const SizedBox(
                                                width: AppWidths.small),
                                            Expanded(
                                              child: Text(
                                                event.location,
                                                style: AppTextStyles.small,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            const Icon(Icons.euro,
                                                size: 14,
                                                color: AppColors.grey),
                                            const SizedBox(
                                                width: AppWidths.small),
                                            Expanded(
                                              child: Text(
                                                event.cost,
                                                style: AppTextStyles.smallMuted,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  trailing: const Icon(Icons.chevron_right),
                                  onTap: () {
                                    // TODO: Navigate to full event detail screen if desired
                                  },
                                ),
                                if (index != events.length - 1)
                                  const Padding(
                                    padding: AppPaddings.symmHorizontalMedium,
                                    child: Divider(
                                        height: 1, color: AppColors.grey),
                                  ),
                              ],
                            );
                          },
                        ), // end Column (Upcoming Events Tile)
                      ),
                      const SizedBox(
                          height: AppHeights
                              .superHuge), // end Container (Upcoming Events Tile)
                    ],
                  ), // end main Column
                ),
                const SizedBox(height: AppHeights.huge),
              ], // end main Container
            ), // end Padding
          ),
        ),
      ), // end SingleChildScrollView
    );
  }
}
