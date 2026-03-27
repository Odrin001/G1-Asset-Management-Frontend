import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

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

  List<AssetItem> _computerHardwareAssets = [];
  List<AssetItem> _furnitureAssets = [];

  final List<AssetActivity> _activityLog = [];
  final List<ScanEvent> _scanLog = [];

  @override
  void initState() {
    super.initState();
    fetchAssets();
  }

  Future<void> fetchAssets() async {
    try {
      final response =
          await http.get(Uri.parse("http://localhost:5000/api/assets"));

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);

        final assets = data.map((e) {
          return AssetItem(
            id: e["_id"],
            name: e["name"],
            category: e["category"] ?? '',
            location: e["location"] ?? '',
            dateArrived:
                e["dateRegistered"]?.toString().split("T")[0] ?? '',
            dateRemoved:
                e["dateRemoved"]?.toString().split("T")[0] ?? '',
          );
        }).toList();

        setState(() {
          _computerHardwareAssets =
              assets.where((a) => a.category.toLowerCase().contains("computer")).toList();

          _furnitureAssets =
              assets.where((a) => a.category.toLowerCase().contains("furniture")).toList();

          _activityLog.clear();
          for (var a in assets.take(8)) {
            _activityLog.add(
              AssetActivity(
                timestamp: DateTime.now(),
                assetId: a.id,
                assetName: a.name,
                type: AssetActivityType.added,
                details: 'Added ${a.name}',
              ),
            );
          }
        });
      }
    } catch (e) {
      print("ERROR: $e");
    }
  }

  void _setAssetType(AssetType type) {
    setState(() => _selectedAssetType = type);
  }

  void _setSearchQuery(String query) {
    setState(() => _searchQuery = query);
  }

  List<AssetItem> get _allAssets =>
      [..._computerHardwareAssets, ..._furnitureAssets];

  List<AssetActivity> get _recentActivity => _activityLog.take(8).toList();
  List<ScanEvent> get _recentScans => _scanLog.take(8).toList();

  void _logScanEvent(ScanEvent event) {
    setState(() {
      _scanLog.insert(0, event);
    });
  }

  void _simulateScan() {
    if (_allAssets.isEmpty) return;

    final asset = _allAssets.first;

    final event = ScanEvent(
      timestamp: DateTime.now(),
      assetId: asset.id,
      assetName: asset.name,
      direction: ScanDirection.outwards,
      location: asset.location,
    );

    _logScanEvent(event);
  }

  Future<void> _openAssetForm({required AssetType type}) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AssetFormPage(initialType: type),
      ),
    );

    fetchAssets();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff3f4f6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Hello, admin!',
          style: TextStyle(color: Colors.black87),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: SizedBox(
              width: 300,
              child: TextField(
                controller: _searchController,
                onChanged: _setSearchQuery,
                decoration: const InputDecoration(
                  hintText: 'Search assets...',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            onPressed: _simulateScan,
          ),
          
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_none),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.qr_code_scanner),
                onPressed: _simulateScan,
              ),
              const SizedBox(width: 10),
              CircleAvatar(
                backgroundColor: Colors.green,
                child: const Text("M", style: TextStyle(color: Colors.white)),
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == "logout") {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginPage()),
                    );
                  }
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(value: "profile", child: Text("View Profile")),
                  PopupMenuItem(value: "logout", child: Text("Logout")),
                ],
              ),
              
            ],
          )
              ],
            ),
      body: Row(
        children: [
          SizedBox(
            width: _sidebarWidth,
            child: Sidebar(
              selectedType: _selectedAssetType,
              onTypeSelected: _setAssetType,
            ),
          ),
          Expanded(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: ComputerHardwareTable(
                      selectedType: _selectedAssetType,
                      searchQuery: _searchQuery,
                      assets: _selectedAssetType == AssetType.computerHardware
                          ? _computerHardwareAssets
                          : _furnitureAssets,
                      onTypeChanged: _setAssetType,
                      onAdd: () =>
                          _openAssetForm(type: _selectedAssetType),
                      onEdit: (_) {},
                      onDelete: (_) {},
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: Column(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: ListView(
                              children: _recentActivity
                                  .map((a) => ListTile(
                                        leading: const Icon(Icons.add),
                                        title: Text(a.details),
                                      ))
                                  .toList(),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: const Center(
                              child: Text(
                                  "No scans yet. Use the scanner to log activity."),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}