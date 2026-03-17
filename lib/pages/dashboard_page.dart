import 'package:flutter/material.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  static const _sidebarWidth = 280.0;
  static const _greenAccent = Color(0xff10b981);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 900;

        return Scaffold(
          backgroundColor: const Color(0xfff3f4f6),
          drawer: isMobile ? Drawer(child: _DashboardSidebar()) : null,
          body: Row(
            children: [
              if (!isMobile)
                SizedBox(
                  width: _sidebarWidth,
                  child: _DashboardSidebar(),
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
                                    child: _AssetsCard(),
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

class _DashboardSidebar extends StatelessWidget {
  const _DashboardSidebar();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xff0f766e),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xff34d399), Color(0xff059669)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.widgets_outlined, color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'AssetsDigital',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Central Section
            _SidebarSection(label: 'CENTRAL'),
            _SidebarItem(
              icon: Icons.dashboard,
              label: 'Dashboard',
              active: true,
            ),
            _SidebarItem(
              icon: Icons.notifications_none,
              label: 'Notifications',
            ),
            _SidebarItem(
              icon: Icons.chat_bubble_outline,
              label: 'Chat',
            ),
            const SizedBox(height: 24),

            // Workspace Section
            _SidebarSection(label: 'WORKSPACE'),
            _SidebarItem(
              icon: Icons.folder_open,
              label: 'Assets',
              expandable: true,
              children: const [
                _SidebarSubItem(label: 'Computer Hardware'),
                _SidebarSubItem(label: 'Furniture'),
              ],
            ),
            const Spacer(),

            // Bottom support button
            Padding(
              padding: const EdgeInsets.all(20),
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xff0f766e),
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                onPressed: () {},
                icon: const Icon(Icons.support_agent_outlined),
                label: const Text('Contact Support'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SidebarSection extends StatelessWidget {
  final String label;

  const _SidebarSection({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 6),
      child: Text(
        label,
        style: TextStyle(
          color: Colors.white.withOpacity(0.65),
          fontSize: 12,
          letterSpacing: 0.5,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final bool expandable;
  final List<Widget>? children;

  const _SidebarItem({
    required this.icon,
    required this.label,
    this.active = false,
    this.expandable = false,
    this.children,
  });

  @override
  Widget build(BuildContext context) {
    final tile = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Icon(icon, size: 22, color: active ? Colors.white : Colors.white70),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: active ? Colors.white : Colors.white70,
                fontWeight: active ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
          if (expandable)
            const Icon(
              Icons.keyboard_arrow_down,
              color: Colors.white70,
            ),
        ],
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: active ? Colors.white.withOpacity(0.14) : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
          ),
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            title: tile,
            onTap: () {},
          ),
        ),
        if (expandable && children != null) ...children!,
      ],
    );
  }
}

class _SidebarSubItem extends StatelessWidget {
  final String label;

  const _SidebarSubItem({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 54, top: 6, bottom: 6),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: Colors.white54,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

class _AssetsCard extends StatelessWidget {
  const _AssetsCard();

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
          Container(
            decoration: BoxDecoration(
              color: const Color(0xfff3f4f6),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                _TabButton(label: 'Recently added', active: true),
                _TabButton(label: 'Computer Hardware'),
                _TabButton(label: 'Furnitures'),
              ],
            ),
          ),
          const SizedBox(height: 18),
          const Expanded(child: _AssetsTable()),
        ],
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final bool active;

  const _TabButton({required this.label, this.active = false});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: active ? const Color(0xff10b981) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: active ? Colors.white : Colors.grey.shade700,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class _AssetsTable extends StatelessWidget {
  const _AssetsTable();

  @override
  Widget build(BuildContext context) {
    final rows = [
      ['Conveyor belt', 'Machinery', '10/02/2023', 'KES 320,500', 'Classroom 1'],
      ['Company bus', 'Vehicles', '07/02/2023', 'KES 3,200,500', 'Classroom 2'],
      ['Limans trademark', 'Intangible assets', '02/02/2023', 'KES 32,500', 'Classroom 3'],
      ['Apparel warehouse', 'Fixed assets', '28/01/2023', 'KES 7,255,500', 'Classroom 4'],
      ['Sanguine Apparel', 'Contracts', '15/01/2023', 'KES 85,500', 'Classroom 5'],
    ];

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Material(
        color: Colors.white,
        child: ListView.separated(
          itemCount: rows.length + 1,
          separatorBuilder: (context, index) {
            return const Divider(height: 1, indent: 16, endIndent: 16); 
          },
          itemBuilder: (context, index) {
            if (index == 0) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: const [
                    Expanded(child: Text('Name', style: TextStyle(fontWeight: FontWeight.w600))),
                    Expanded(child: Text('Section', style: TextStyle(fontWeight: FontWeight.w600))),
                    Expanded(child: Text('Date registered', style: TextStyle(fontWeight: FontWeight.w600))),
                    Expanded(child: Text('Value', style: TextStyle(fontWeight: FontWeight.w600))),
                    Expanded(child: Text('Location', style: TextStyle(fontWeight: FontWeight.w600))),
                  ],
                ),
              );
            }

            final row = rows[index - 1];
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Expanded(child: Text(row[0], style: const TextStyle(fontWeight: FontWeight.w600))),
                  Expanded(child: Text(row[1], style: const TextStyle(color: Colors.grey))),
                  Expanded(child: Text(row[2], style: const TextStyle(color: Colors.grey))),
                  Expanded(child: Text(row[3], style: const TextStyle(color: Colors.grey))),
                  Expanded(child: Text(row[4], style: const TextStyle(color: Colors.grey))),
                ],
              ),
            );
          },
        ),
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
