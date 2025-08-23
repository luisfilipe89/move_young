import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // HapticFeedback
import 'package:easy_localization/easy_localization.dart';
import 'package:move_young/models/event_model.dart';
import 'package:move_young/services/load_events_from_json.dart';
import 'package:move_young/theme/tokens.dart';
import 'package:move_young/screens/main_scaffold.dart'; // MainScaffold & kTabAgenda

// Loading state for events
enum _LoadState { idle, loading, success, error }

class HomeScreenNew extends StatefulWidget {
  const HomeScreenNew({super.key});

  @override
  State<HomeScreenNew> createState() => _HomeScreenNewState();
}

class _HomeScreenNewState extends State<HomeScreenNew> {
  List<Event> events = [];
  _LoadState _state = _LoadState.idle;

  @override
  void initState() {
    super.initState();
    _fetch();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      precacheImage(
          const AssetImage('assets/images/general_public.jpg'), context);
    });
  }

  Future<void> _fetch() async {
    setState(() => _state = _LoadState.loading);
    try {
      final loaded = await loadEventsFromJson();
      if (!mounted) return;
      setState(() {
        events = loaded;
        _state = _LoadState.success;
      });
    } catch (e, st) {
      assert(() {
        debugPrint('Events load failed: $e\n$st');
        return true;
      }());
      if (!mounted) return;
      setState(() => _state = _LoadState.error);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('events_load_failed'.tr())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: const Icon(Icons.menu),
        title: const Text('SMARTPLAYER'),
        centerTitle: true,
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.language),
            label: Text(
              context.locale.languageCode == 'nl' ? 'EN' : 'NL',
              style: AppTextStyles.body,
            ),
            onPressed: () {
              HapticFeedback.lightImpact();
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
            tooltip: 'qr_code'.tr(),
            icon: const Icon(Icons.qr_code),
            onPressed: () {
              // TODO: Implement QR code scan
            },
          ),
        ],
      ),
      body: SafeArea(
        top: false, // AppBar already covers the top inset
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: AppPaddings.allReg,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(AppRadius.container),
                boxShadow: AppShadows.md,
              ),
              padding: AppPaddings.allBig,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('hello'.tr(), style: AppTextStyles.headline),
                  const SizedBox(height: AppHeights.huge),

                  // --- Activities card (ripple + haptic) ---
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(AppRadius.card),
                      boxShadow: AppShadows.md,
                    ),
                    child: Material(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(AppRadius.card),
                      clipBehavior: Clip.antiAlias,
                      elevation: 4,
                      shadowColor: AppColors.blackShadow,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(AppRadius.card),
                        onTap: () {
                          HapticFeedback.lightImpact();
                          Navigator.of(context).pushNamed('/activities');
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Ink.image(
                              image: const AssetImage(
                                  'assets/images/general_public.jpg'),
                              height: 100,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                            Padding(
                              padding: AppPaddings.allMedium,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('check_for_fields'.tr(),
                                      style: AppTextStyles.cardTitle),
                                  const SizedBox(height: 1),
                                  Text('look_for_fields'.tr(),
                                      style: AppTextStyles.bodyMuted),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: AppHeights.huge),

                  // --- Upcoming Events card ---
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(AppRadius.card),
                      boxShadow: AppShadows.md,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header with See all
                        Padding(
                          padding: AppPaddings.allMedium,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('upcoming_events'.tr(),
                                      style: AppTextStyles.cardTitle),
                                  const SizedBox(height: AppHeights.small),
                                  Text('join_sports_event'.tr(),
                                      style: AppTextStyles.body),
                                ],
                              ),
                              if (_state == _LoadState.success &&
                                  events.isNotEmpty)
                                TextButton(
                                  style: TextButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8)),
                                  onPressed: () {
                                    HapticFeedback.selectionClick();
                                    MainScaffold.maybeOf(context)?.switchToTab(
                                        kTabAgenda,
                                        popToRoot: true);
                                  },
                                  child: Text('see_all'.tr(),
                                      style: AppTextStyles.small),
                                ),
                            ],
                          ),
                        ),
                        const Divider(height: 1, color: AppColors.lightgrey),

// State-driven content
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          switchInCurve: Curves.easeOut,
                          switchOutCurve: Curves.easeIn,
                          child: Builder(
                            key: ValueKey(_state),
                            builder: (context) {
                              switch (_state) {
                                case _LoadState.loading:
                                  return const Padding(
                                    padding: AppPaddings.allMedium,
                                    child: _EventsSkeleton(),
                                  );

                                case _LoadState.error:
                                  return Padding(
                                    padding: AppPaddings.allMedium,
                                    child: Row(
                                      children: [
                                        const Icon(Icons.error_outline,
                                            color: AppColors.grey),
                                        const SizedBox(width: AppWidths.small),
                                        Expanded(
                                          child: Text(
                                            'events_load_failed'.tr(),
                                            style: AppTextStyles.bodyMuted,
                                          ),
                                        ),
                                        TextButton(
                                            onPressed: _fetch,
                                            child: Text('retry'.tr())),
                                      ],
                                    ),
                                  );

                                case _LoadState.success:
                                case _LoadState.idle:
                                  if (events.isEmpty) {
                                    return Padding(
                                      padding: AppPaddings.allMedium,
                                      child: Row(
                                        children: [
                                          const Icon(Icons.inbox,
                                              color: AppColors.grey),
                                          const SizedBox(
                                              width: AppWidths.small),
                                          Expanded(
                                            child: Text(
                                              'no_upcoming_events'.tr(),
                                              style: AppTextStyles.bodyMuted,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }

                                  // Finite scroll window + inner pull-to-refresh
                                  return SizedBox(
                                    height: 280,
                                    child: RefreshIndicator(
                                      onRefresh: _fetch,
                                      child: ListView.separated(
                                        physics:
                                            const AlwaysScrollableScrollPhysics(),
                                        itemCount: events.length,
                                        separatorBuilder: (_, __) =>
                                            const Padding(
                                          padding:
                                              AppPaddings.symmHorizontalMedium,
                                          child: Divider(
                                              height: 1, color: AppColors.grey),
                                        ),
                                        itemBuilder: (context, index) {
                                          final e = events[index];
                                          return ListTile(
                                            contentPadding: AppPaddings
                                                .symmHorizontalMedium,
                                            leading: const Icon(Icons.event),
                                            title: Text(
                                              e.title,
                                              style: AppTextStyles.cardTitle,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            subtitle: Padding(
                                              padding:
                                                  AppPaddings.topSuperSmall,
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Row(children: [
                                                    const Icon(
                                                        Icons.access_time,
                                                        size: 14,
                                                        color: AppColors.grey),
                                                    const SizedBox(
                                                        width: AppWidths.small),
                                                    Expanded(
                                                      child: Text(
                                                        e.dateTime, // consider formatting later
                                                        style:
                                                            AppTextStyles.small,
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                  ]),
                                                  Row(children: [
                                                    const Icon(Icons.group,
                                                        size: 14,
                                                        color: AppColors.grey),
                                                    const SizedBox(
                                                        width: AppWidths.small),
                                                    Expanded(
                                                      child: Text(
                                                        e.targetGroup,
                                                        style:
                                                            AppTextStyles.small,
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                  ]),
                                                  Row(children: [
                                                    const Icon(
                                                        Icons.location_on,
                                                        size: 14,
                                                        color: AppColors.grey),
                                                    const SizedBox(
                                                        width: AppWidths.small),
                                                    Expanded(
                                                      child: Text(
                                                        e.location,
                                                        style:
                                                            AppTextStyles.small,
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                  ]),
                                                  Row(children: [
                                                    const Icon(Icons.euro,
                                                        size: 14,
                                                        color: AppColors.grey),
                                                    const SizedBox(
                                                        width: AppWidths.small),
                                                    Expanded(
                                                      child: Text(
                                                        e.cost,
                                                        style: AppTextStyles
                                                            .smallMuted,
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                  ]),
                                                ],
                                              ),
                                            ),
                                            trailing:
                                                const Icon(Icons.chevron_right),
                                            onTap: () =>
                                                HapticFeedback.selectionClick(),
                                            // TODO: Navigate to event detail
                                          );
                                        },
                                      ),
                                    ),
                                  );
                              }
                            },
                          ),
                        ),

                        const SizedBox(height: AppHeights.superHuge),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppHeights.huge),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// --- Skeleton widget for loading state ---
class _EventsSkeleton extends StatelessWidget {
  const _EventsSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
          3,
          (i) => Padding(
                padding: AppPaddings.symmVerticalSmall,
                child: Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: AppColors.superlightgrey,
                        borderRadius: BorderRadius.circular(4),
                        boxShadow: AppShadows.md,
                      ),
                    ),
                    const SizedBox(width: AppWidths.superbig),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                              height: 12, color: AppColors.superlightgrey),
                          const SizedBox(height: 6),
                          Container(
                              height: 10,
                              width: 120,
                              color: AppColors.superlightgrey),
                        ],
                      ),
                    ),
                  ],
                ),
              )),
    );
  }
}
