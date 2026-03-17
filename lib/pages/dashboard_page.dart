import 'package:flutter/material.dart';

import '../models/asset_item.dart';
import 'computer_hardware.dart';
import 'furniture.dart';
import 'sidebar.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  static const _sidebarWidth = 280.0;
  static const _greenAccent = Color(0xff10b981);

  AssetType _selectedAssetType = AssetType.computerHardware;

  void _setAssetType(AssetType type) {
    setState(() {
      _selectedAssetType = type;
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 900;

        return Scaffold(
          backgroundColor: const Color(0xfff3f4f6),
          drawer: isMobile
              ? Drawer(
                  child: Sidebar(
                    selectedType: _selectedAssetType,
                    onTypeSelected: _setAssetType,
                  ),
                )
              : null,
          body: Row(
            children: [
              if (!isMobile)
                SizedBox(
                  width: _sidebarWidth,
                  child: Sidebar(
                    selectedType: _selectedAssetType,
                    onTypeSelected: _setAssetType,
                  ),
                ),
              // Main content area
              Expanded(
                child: SafeArea(
                  child: Column(
                    children: [
                      // Top header
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                        child: Row(
                          children: [
                            if (isMobile)
                              Builder(
                                builder: (context) {
                                  return IconButton(
                                    icon: const Icon(Icons.menu, size: 28, color: Colors.black87),
                                    onPressed: () => Scaffold.of(context).openDrawer(),
                                  );
                                },
                              ),
                            const Expanded(
                              child: Text(
                                'Hello, Mark',
                                style: TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Expanded(
                                    child: Container(
                                      height: 44,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(14),
                                        border: Border.all(color: Colors.grey.shade200),
                                      ),
                                      padding: const EdgeInsets.symmetric(horizontal: 14),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.search, color: Colors.grey),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: TextField(
                                              decoration: InputDecoration(
                                                hintText: 'Search asset, file, user',
                                                border: InputBorder.none,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(14),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.06),
                                          blurRadius: 12,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: IconButton(
                                      icon: const Icon(Icons.notifications_none, color: Colors.grey),
                                      onPressed: () {},
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: _greenAccent,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.15),
                                          blurRadius: 12,
                                          offset: const Offset(0, 6),
                                        ),
                                      ],
                                    ),
                                    child: const Center(
                                      child: Text(
                                        'M',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Main content cards
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              final isNarrow = constraints.maxWidth < 1050;
                              return Flex(
                                direction: isNarrow ? Axis.vertical : Axis.horizontal,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    flex: isNarrow ? 0 : 2,
                                    child: _AssetsCard(
                                      selectedType: _selectedAssetType,
                                      onTypeChanged: _setAssetType,
                                    ),
                                  ),
                                  SizedBox(width: isNarrow ? 0 : 24, height: isNarrow ? 24 : 0),
                                  Expanded(
                                    flex: 1,
                                    child: _ScheduleCard(),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _AssetsCard extends StatefulWidget {
  const _AssetsCard({
    required this.selectedType,
    required this.onTypeChanged,
  });

  final AssetType selectedType;
  final ValueChanged<AssetType> onTypeChanged;

  @override
  State<_AssetsCard> createState() => _AssetsCardState();
}

class _AssetsCardState extends State<_AssetsCard> {
  late AssetType _currentType;

  @override
  void initState() {
    super.initState();
    _currentType = widget.selectedType;
  }

  @override
  void didUpdateWidget(covariant _AssetsCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedType != widget.selectedType) {
      _currentType = widget.selectedType;
    }
  }

  void _onTypeChanged(AssetType type) {
    setState(() {
      _currentType = type;
    });
    widget.onTypeChanged(type);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Assets',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 18),
          Expanded(
            child: _currentType == AssetType.computerHardware
                ? ComputerHardwareTable(
                    selectedType: _currentType,
                    onTypeChanged: _onTypeChanged,
                  )
                : FurnitureTable(
                    selectedType: _currentType,
                    onTypeChanged: _onTypeChanged,
                  ),
          ),
        ],
      ),
    );
  }
}

class _ScheduleCard extends StatelessWidget {
  const _ScheduleCard();

  @override
  Widget build(BuildContext context) {
    final daysOfWeek = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final dates = List.generate(30, (index) => index + 1);

    // Sample highlighted dates
    final assetDates = {5, 11, 16, 22};
    final meetingDates = {8, 14, 20, 26};

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Schedule and Alerts',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 18),
          const Text(
            'September 2023',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 18),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: daysOfWeek.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 1.2,
            ),
            itemBuilder: (context, index) {
              return Center(
                child: Text(
                  daysOfWeek[index],
                  style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w600),
                ),
              );
            },
          ),
          const SizedBox(height: 10),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: dates.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 1.1,
            ),
            itemBuilder: (context, index) {
              final date = dates[index];
              final isAsset = assetDates.contains(date);
              final isMeeting = meetingDates.contains(date);

              Color? bg;
              if (isAsset) bg = const Color(0xffd1fae5);
              if (isMeeting) bg = const Color(0xffdbeafe);

              return Container(
                decoration: BoxDecoration(
                  color: bg ?? Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Center(
                  child: Text(
                    '$date',
                    style: TextStyle(
                      color: isAsset
                          ? const Color(0xff065f46)
                          : isMeeting
                              ? const Color(0xff1e3a8a)
                              : Colors.grey.shade700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              _LegendItem(color: const Color(0xff10b981), label: 'Green = Assets'),
              const SizedBox(width: 14),
              _LegendItem(color: const Color(0xff3b82f6), label: 'Blue = Meetings'),
            ],
          ),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4)),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black54),
        ),
      ],
    );
  }
}
