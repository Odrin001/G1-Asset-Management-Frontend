import 'package:flutter/material.dart';

import '../models/asset_item.dart';
import 'asset_form_page.dart';
import 'computer_hardware.dart';
import 'furniture.dart';
import 'login_page.dart';
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
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  late List<AssetItem> _computerHardwareAssets;
  late List<AssetItem> _furnitureAssets;
  final List<AssetActivity> _activityLog = [];
  final List<ScanEvent> _scanLog = [];

  void _setAssetType(AssetType type) {
    setState(() {
      _selectedAssetType = type;
    });
  }

  void _setSearchQuery(String query) {
    setState(() {
      _searchQuery = query;
    });
  }

  @override
  void initState() {
    super.initState();

    _computerHardwareAssets = List<AssetItem>.from(AssetData.computerHardware);
    _furnitureAssets = List<AssetItem>.from(AssetData.furniture);

    if (_computerHardwareAssets.isNotEmpty) {
      _activityLog.add(
        AssetActivity(
          timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
          assetId: _computerHardwareAssets.first.id,
          assetName: _computerHardwareAssets.first.name,
          type: AssetActivityType.added,
          details: 'Added ${_computerHardwareAssets.first.name}',
        ),
      );
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<AssetItem> get _allAssets => [..._computerHardwareAssets, ..._furnitureAssets];

  List<AssetItem> get _assetsLeftRoom {
    final now = DateTime.now();
    return _allAssets.where((asset) {
      final removedAt = asset.removedAt;
      if (removedAt == null) return false;
      return removedAt.year == now.year &&
          removedAt.month == now.month &&
          removedAt.day == now.day;
    }).toList();
  }

  List<AssetActivity> get _recentActivity => _activityLog.take(8).toList();
  List<ScanEvent> get _recentScans => _scanLog.take(8).toList();

  void _showLeftRoomNotifications(BuildContext context) {
    final left = _assetsLeftRoom;
    if (left.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No room-leaving alerts')),
      );
      return;
    }

    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Items left room'),
          content: SizedBox(
            width: 320,
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: left.length,
              separatorBuilder: (_, __) => const Divider(height: 12),
              itemBuilder: (context, index) {
                final asset = left[index];
                return ListTile(
                  title: Text(asset.name),
                  subtitle: Text(asset.removedAtText),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _logActivity(AssetActivity activity) {
    setState(() {
      _activityLog.insert(0, activity);
    });
  }

  void _logScanEvent(ScanEvent event) {
    setState(() {
      _scanLog.insert(0, event);
    });
  }

  void _applySavedAsset(AssetItem asset, AssetType type) {
    final existingType = _findAssetTypeById(asset.id);
    final existingIndex = existingType == null
        ? -1
        : _assetsForType(existingType).indexWhere((a) => a.id == asset.id);

    if (existingType == null || existingIndex == -1) {
      // New asset.
      setState(() {
        _assetsForType(type).insert(0, asset);
      });
      _logActivity(AssetActivity(
        timestamp: DateTime.now(),
        assetId: asset.id,
        assetName: asset.name,
        type: AssetActivityType.added,
        details: 'Added ${asset.name} to ${asset.location}',
      ));
      return;
    }

    final oldAsset = _assetsForType(existingType)[existingIndex];
    if (existingType != type) {
      // Moved between categories.
      setState(() {
        _assetsForType(existingType).removeAt(existingIndex);
        _assetsForType(type).insert(0, asset);
      });
      _logActivity(AssetActivity(
        timestamp: DateTime.now(),
        assetId: asset.id,
        assetName: asset.name,
        type: AssetActivityType.moved,
        details: 'Moved ${asset.name} from ${existingType.name} to ${type.name}',
      ));
      return;
    }

    // Same category: update.
    setState(() {
      _assetsForType(type)[existingIndex] = asset;
    });

    final changes = <String>[];
    if (oldAsset.name != asset.name) {
      changes.add('renamed from ${oldAsset.name}');
    }
    if (oldAsset.location != asset.location) {
      changes.add('moved from ${oldAsset.location} to ${asset.location}');
    }
    if (oldAsset.category != asset.category) {
      changes.add('category updated');
    }
    if (oldAsset.dateArrived != asset.dateArrived) {
      changes.add('date registered changed');
    }
    if (oldAsset.dateRemoved != asset.dateRemoved && asset.removedAtText.isNotEmpty) {
      changes.add(asset.removedAtText);
    }

    if (changes.isNotEmpty) {
      _logActivity(AssetActivity(
        timestamp: DateTime.now(),
        assetId: asset.id,
        assetName: asset.name,
        type: AssetActivityType.updated,
        details: changes.join(', '),
      ));
    }
  }

  void _deleteAsset(AssetItem asset, AssetType type) {
    setState(() {
      _assetsForType(type).removeWhere((a) => a.id == asset.id);
    });
    _logActivity(AssetActivity(
      timestamp: DateTime.now(),
      assetId: asset.id,
      assetName: asset.name,
      type: AssetActivityType.removed,
      details: 'Deleted ${asset.name}',
    ));
  }

  Future<void> _openAssetForm({AssetItem? existing, required AssetType type}) async {
    final result = await Navigator.of(context).push<AssetFormResult>(
      MaterialPageRoute(
        builder: (context) => AssetFormPage(
          initialType: type,
          existingAsset: existing,
        ),
      ),
    );

    if (result == null) return;

    if (result.action == AssetFormAction.save && result.asset != null) {
      _applySavedAsset(result.asset!, result.type);
    }

    if (result.action == AssetFormAction.delete && existing != null) {
      _deleteAsset(existing, result.type);
    }
  }

  void _simulateScan() {
    if (_allAssets.isEmpty) return;

    final random = DateTime.now().millisecondsSinceEpoch;
    final asset = _allAssets[random % _allAssets.length];
    final direction = (random % 2 == 0) ? ScanDirection.outwards : ScanDirection.inwards;

    final event = ScanEvent(
      timestamp: DateTime.now(),
      assetId: asset.id,
      assetName: asset.name,
      direction: direction,
      location: asset.location,
    );

    _logScanEvent(event);
    _logActivity(AssetActivity(
      timestamp: event.timestamp,
      assetId: event.assetId,
      assetName: event.assetName,
      type: AssetActivityType.moved,
      details: '${event.assetName} scanned ${direction == ScanDirection.outwards ? 'out' : 'in'} of ${event.location}',
    ));
  }

  AssetType? _findAssetTypeById(String id) {
    if (_computerHardwareAssets.any((a) => a.id == id)) return AssetType.computerHardware;
    if (_furnitureAssets.any((a) => a.id == id)) return AssetType.furniture;
    return null;
  }

  List<AssetItem> _assetsForType(AssetType type) {
    return type == AssetType.computerHardware ? _computerHardwareAssets : _furnitureAssets;
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
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            titleSpacing: 0,
            leading: isMobile
                ? Builder(
                    builder: (context) {
                      return IconButton(
                        icon: const Icon(Icons.menu, color: Colors.black87),
                        onPressed: () => Scaffold.of(context).openDrawer(),
                      );
                    },
                  )
                : null,
            title: const Text(
              'Hello, admin!',
              style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w700),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                child: SizedBox(
                  width: isMobile ? 190 : 320,
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
                            controller: _searchController,
                            onChanged: _setSearchQuery,
                            decoration: const InputDecoration(
                              hintText: 'Search assets…',
                              border: InputBorder.none,
                              isDense: true,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: GestureDetector(
                  onTap: () => _showLeftRoomNotifications(context),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(15),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.notifications_none, color: Colors.grey),
                      ),
                      if (_assetsLeftRoom.isNotEmpty)
                        Positioned(
                          right: 6,
                          top: 6,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              '${_assetsLeftRoom.length}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: IconButton(
                  tooltip: 'Simulate scan',
                  onPressed: _simulateScan,
                  icon: const Icon(Icons.qr_code_scanner, color: Colors.grey),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: PopupMenuButton<String>(
                  tooltip: 'Profile',
                  onSelected: (value) {
                    if (value == 'view') {
                      showDialog<void>(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text('Admin Profile'),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text('Name: Admin'),
                                SizedBox(height: 8),
                                Text('Email: admin@sdca.edu.ph'),
                                SizedBox(height: 8),
                                Text('Role: Administrator'),
                              ],
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text('Close'),
                              ),
                            ],
                          );
                        },
                      );
                    } else if (value == 'signout') {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (_) => const LoginPage(),
                        ),
                      );
                    }
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: 'view', child: Text('View profile')),
                    PopupMenuItem(value: 'signout', child: Text('Sign out')),
                  ],
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: _greenAccent,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(38),
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
                ),
              ),
              const SizedBox(width: 8),
            ],
          ),
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
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final isNarrow = constraints.maxWidth < 1050;
                      if (isNarrow) {
                        return SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _AssetsCard(
                                selectedType: _selectedAssetType,
                                searchQuery: _searchQuery,
                                onTypeChanged: _setAssetType,
                                computerAssets: _computerHardwareAssets,
                                furnitureAssets: _furnitureAssets,
                                onAdd: (type) => _openAssetForm(type: type),
                                onEdit: (asset, type) => _openAssetForm(existing: asset, type: type),
                                onDelete: _deleteAsset,
                              ),
                              const SizedBox(height: 24),
                              _RecentActivityCard(activities: _recentActivity),
                              const SizedBox(height: 24),
                              _ScanLogCard(events: _recentScans),
                            ],
                          ),
                        );
                      }

                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 2,
                            child: _AssetsCard(
                              selectedType: _selectedAssetType,
                              searchQuery: _searchQuery,
                              onTypeChanged: _setAssetType,
                              computerAssets: _computerHardwareAssets,
                              furnitureAssets: _furnitureAssets,
                              onAdd: (type) => _openAssetForm(type: type),
                              onEdit: (asset, type) => _openAssetForm(existing: asset, type: type),
                              onDelete: _deleteAsset,
                            ),
                          ),
                          const SizedBox(width: 24),
                          Expanded(
                            flex: 1,
                            child: Column(
                              children: [
                                Expanded(child: _RecentActivityCard(activities: _recentActivity)),
                                const SizedBox(height: 24),
                                Expanded(child: _ScanLogCard(events: _recentScans)),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
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
    required this.searchQuery,
    required this.computerAssets,
    required this.furnitureAssets,
    required this.onAdd,
    required this.onEdit,
    required this.onDelete,
  });

  final AssetType selectedType;
  final String searchQuery;
  final List<AssetItem> computerAssets;
  final List<AssetItem> furnitureAssets;
  final ValueChanged<AssetType> onTypeChanged;
  final void Function(AssetType type) onAdd;
  final void Function(AssetItem asset, AssetType type) onEdit;
  final void Function(AssetItem asset, AssetType type) onDelete;

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
            color: Colors.black.withAlpha(15),
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
                    searchQuery: widget.searchQuery,
                    assets: widget.computerAssets,
                    onTypeChanged: _onTypeChanged,
                    onAdd: () => widget.onAdd(_currentType),
                    onEdit: (asset) => widget.onEdit(asset, _currentType),
                    onDelete: (asset) => widget.onDelete(asset, _currentType),
                  )
                : FurnitureTable(
                    selectedType: _currentType,
                    searchQuery: widget.searchQuery,
                    assets: widget.furnitureAssets,
                    onTypeChanged: _onTypeChanged,
                    onAdd: () => widget.onAdd(_currentType),
                    onEdit: (asset) => widget.onEdit(asset, _currentType),
                    onDelete: (asset) => widget.onDelete(asset, _currentType),
                  ),
          ),
        ],
      ),
    );
  }
}

class _RecentActivityCard extends StatelessWidget {
  const _RecentActivityCard({required this.activities});

  final List<AssetActivity> activities;

  String _formatTimestamp(DateTime dt) {
    final hour = dt.hour == 0 ? 12 : (dt.hour > 12 ? dt.hour - 12 : dt.hour);
    final minute = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    return '${dt.day}/${dt.month}/${dt.year} $hour:$minute $period';
  }

  IconData _iconForType(AssetActivityType type) {
    switch (type) {
      case AssetActivityType.added:
        return Icons.add_circle_outline;
      case AssetActivityType.moved:
        return Icons.swap_horiz;
      case AssetActivityType.removed:
        return Icons.delete_outline;
      case AssetActivityType.updated:
        return Icons.edit;
    }
  }

  Color _colorForType(AssetActivityType type) {
    switch (type) {
      case AssetActivityType.added:
        return const Color(0xff10b981);
      case AssetActivityType.moved:
        return const Color(0xff3b82f6);
      case AssetActivityType.removed:
        return const Color(0xffef4444);
      case AssetActivityType.updated:
        return const Color(0xfff59e0b);
    }
  }

  Color _backgroundForType(AssetActivityType type) {
    final base = _colorForType(type);
    return Color.fromARGB(
      (0.15 * 255).round(),
      base.r.round(),
      base.g.round(),
      base.b.round(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(15),
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
            'Recent Activity',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 18),
          if (activities.isEmpty)
            Expanded(
              child: Center(
                child: Text(
                  'No recent activity yet.',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ),
            )
          else
            Expanded(
              child: ListView.separated(
                itemCount: activities.length,
                separatorBuilder: (_, __) => const Divider(height: 12),
                itemBuilder: (context, index) {
                  final activity = activities[index];
                  return ListTile(
                    leading: CircleAvatar(
                      radius: 18,
                      backgroundColor: _backgroundForType(activity.type),
                      child: Icon(
                        _iconForType(activity.type),
                        color: _colorForType(activity.type),
                        size: 20,
                      ),
                    ),
                    title: Text(activity.details),
                    subtitle: Text(_formatTimestamp(activity.timestamp)),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _ScanLogCard extends StatelessWidget {
  const _ScanLogCard({required this.events});

  final List<ScanEvent> events;

  String _formatTimestamp(DateTime dt) {
    final hour = dt.hour == 0 ? 12 : (dt.hour > 12 ? dt.hour - 12 : dt.hour);
    final minute = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    return '${dt.day}/${dt.month}/${dt.year} $hour:$minute $period';
  }

  IconData _iconForDirection(ScanDirection direction) {
    return direction == ScanDirection.outwards ? Icons.exit_to_app : Icons.login;
  }

  Color _colorForDirection(ScanDirection direction) {
    return direction == ScanDirection.outwards ? const Color(0xffef4444) : const Color(0xff10b981);
  }

  Color _backgroundForDirection(ScanDirection direction) {
    final base = _colorForDirection(direction);
    return Color.fromARGB(
      (0.15 * 255).round(),
      base.r.round(),
      base.g.round(),
      base.b.round(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(15),
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
            'Live Scan Log',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 18),
          if (events.isEmpty)
            Expanded(
              child: Center(
                child: Text(
                  'No scans yet. Use the scanner to log activity.',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ),
            )
          else
            Expanded(
              child: ListView.separated(
                itemCount: events.length,
                separatorBuilder: (_, __) => const Divider(height: 12),
                itemBuilder: (context, index) {
                  final event = events[index];
                  return ListTile(
                    leading: CircleAvatar(
                      radius: 18,
                      backgroundColor: _backgroundForDirection(event.direction),
                      child: Icon(
                        _iconForDirection(event.direction),
                        color: _colorForDirection(event.direction),
                        size: 20,
                      ),
                    ),
                    title: Text('${event.assetName} ${event.direction == ScanDirection.outwards ? 'exited' : 'entered'}'),
                    subtitle: Text('${event.location} · ${_formatTimestamp(event.timestamp)}'),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
