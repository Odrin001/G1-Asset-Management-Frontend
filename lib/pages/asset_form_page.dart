import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/asset_item.dart';

enum AssetFormAction { save, delete, cancel }

class AssetFormResult {
  final AssetFormAction action;
  final AssetType type;
  final AssetItem? asset;

  const AssetFormResult._(this.action, this.type, [this.asset]);
  const AssetFormResult.save(AssetItem asset, AssetType type)
      : this._(AssetFormAction.save, type, asset);
  const AssetFormResult.delete(AssetType type) : this._(AssetFormAction.delete, type);
  const AssetFormResult.cancel(AssetType type) : this._(AssetFormAction.cancel, type);
}

class AssetFormPage extends StatefulWidget {
  const AssetFormPage({
    super.key,
    required this.initialType,
    this.existingAsset,
  });

  final AssetType initialType;
  final AssetItem? existingAsset;

  @override
  State<AssetFormPage> createState() => _AssetFormPageState();
}

class _AssetFormPageState extends State<AssetFormPage> {
  late AssetType _type;
  late TextEditingController _nameController;
  late TextEditingController _categoryController;
  late TextEditingController _locationController;
  late TextEditingController _dateArrivedController;
  late TextEditingController _dateRemovedController;
  late TextEditingController _uidController;

  bool get _isEditing => widget.existingAsset != null;

  @override
  void initState() {
    super.initState();

    _type = widget.initialType;

    _nameController = TextEditingController(text: widget.existingAsset?.name ?? '');
    _categoryController = TextEditingController(text: widget.existingAsset?.category ?? '');
    _locationController = TextEditingController(text: widget.existingAsset?.location ?? '');
    _dateArrivedController = TextEditingController(text: widget.existingAsset?.dateArrived ?? '');
    _dateRemovedController = TextEditingController(text: widget.existingAsset?.dateRemoved ?? '');
    _uidController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _categoryController.dispose();
    _locationController.dispose();
    _dateArrivedController.dispose();
    _dateRemovedController.dispose();
    _uidController.dispose();
    super.dispose();
  }

  void _save() async {
    final name = _nameController.text.trim();
    final category = _categoryController.text.trim();
    final location = _locationController.text.trim();
    final dateArrived = _dateArrivedController.text.trim();
    final dateRemoved = _dateRemovedController.text.trim();
    final uid = _uidController.text.trim();

    if (name.isEmpty || category.isEmpty || location.isEmpty || dateArrived.isEmpty || uid.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields including UID.')),
      );
      return;
    }

    try {
      final response = await http.post(
        Uri.parse("http://localhost:5000/api/assets"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "name": name,
          "category": category,
          "location": location,
          "dateRegistered": dateArrived,
          "dateRemoved": dateRemoved,
          "uid": uid,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Asset registered successfully")),
        );

        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data["message"] ?? "Error")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Connection error: $e")),
      );
    }
  }

  void _confirmDelete() async {
    final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Delete asset'),
              content: const Text('Are you sure you want to delete this asset? This cannot be undone.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Delete', style: TextStyle(color: Colors.red)),
                ),
              ],
            );
          },
        ) ??
        false;

    if (!mounted) return;

    if (confirmed) {
      Navigator.of(context).pop(AssetFormResult.delete(_type));
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = _isEditing ? 'Edit Asset' : 'Register Asset';

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Delete',
              onPressed: _confirmDelete,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            const Text('Asset Type', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            DropdownButton<AssetType>(
              value: _type,
              items: const [
                DropdownMenuItem(value: AssetType.computerHardware, child: Text('Computer Hardware')),
                DropdownMenuItem(value: AssetType.furniture, child: Text('Furniture')),
              ],
              onChanged: (value) {
                if (value == null) return;
                setState(() => _type = value);
              },
            ),
            const SizedBox(height: 18),
            _buildTextField(controller: _nameController, label: 'Name'),
            const SizedBox(height: 12),
            _buildTextField(controller: _categoryController, label: 'Category'),
            const SizedBox(height: 12),
            _buildTextField(controller: _locationController, label: 'Location'),
            const SizedBox(height: 12),
            _buildTextField(
              controller: _dateArrivedController,
              label: 'Date Registered',
              hint: 'dd-MM-yyyy',
            ),
            const SizedBox(height: 12),
            _buildTextField(
              controller: _dateRemovedController,
              label: 'Date Removed (optional)',
              hint: 'dd-MM-yyyy or dd-MM-yyyy hh:mma',
            ),
            const SizedBox(height: 12),

            // ✅ UID FIELD (NEW)
            _buildTextField(
              controller: _uidController,
              label: 'RFID UID',
              hint: 'Scan or enter UID',
            ),

            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff10b981),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: Text(_isEditing ? 'Save changes' : 'Register asset'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
      ],
    );
  }
}