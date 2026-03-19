import 'package:flutter/material.dart';

import '../models/asset_item.dart';

class ComputerHardwareTable extends StatefulWidget {
  const ComputerHardwareTable({
    super.key,
    required this.selectedType,
    required this.searchQuery,
    required this.onTypeChanged,
    required this.assets,
    required this.onAdd,
    required this.onEdit,
    required this.onDelete,
  });

  final AssetType selectedType;
  final String searchQuery;
  final List<AssetItem> assets;
  final ValueChanged<AssetType> onTypeChanged;
  final VoidCallback onAdd;
  final ValueChanged<AssetItem> onEdit;
  final ValueChanged<AssetItem> onDelete;

  @override
  State<ComputerHardwareTable> createState() => _ComputerHardwareTableState();
}

class _ComputerHardwareTableState extends State<ComputerHardwareTable> {
  late AssetType _currentType;

  @override
  void initState() {
    super.initState();
    _currentType = widget.selectedType;
  }

  @override
  void didUpdateWidget(covariant ComputerHardwareTable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedType != widget.selectedType) {
      _currentType = widget.selectedType;
    }
  }

  List<AssetItem> get _items {
    final base = widget.assets;

    final query = widget.searchQuery.trim().toLowerCase();
    if (query.isEmpty) return base;

    return base.where((asset) {
      final name = asset.name.toLowerCase();
      final category = asset.category.toLowerCase();
      final location = asset.location.toLowerCase();
      return name.contains(query) || category.contains(query) || location.contains(query);
    }).toList();
  }

  Future<void> _confirmDelete(AssetItem asset) async {
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

    if (confirmed) {
      widget.onDelete(asset);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 22),
          child: Row(
            children: [
              const Expanded(
                child: Text(
                  'Computer Hardware',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(width: 12),
              TextButton.icon(
                onPressed: widget.onAdd,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add'),
              ),
              const SizedBox(width: 12),
              DropdownButton<AssetType>(
                value: _currentType,
                items: const [
                  DropdownMenuItem(
                    value: AssetType.computerHardware,
                    child: Text('Computer Hardware'),
                  ),
                  DropdownMenuItem(
                    value: AssetType.furniture,
                    child: Text('Furniture'),
                  ),
                ],
                onChanged: (value) {
                  if (value == null) return;
                  setState(() => _currentType = value);
                  widget.onTypeChanged(value);
                },
              ),
            ],
          ),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Material(
              color: Colors.white,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(vertical: 16),
                scrollDirection: Axis.horizontal,
                child: SingleChildScrollView(
                  child: DataTable(
                    headingRowHeight: 52,
                    dataRowMinHeight: 52,
                    dataRowMaxHeight: 52,
                    headingRowColor: WidgetStateProperty.all(const Color(0xfff3f4f6)),
                    columns: const [
                      DataColumn(
                          label: Text('Name', style: TextStyle(fontWeight: FontWeight.w700))),
                      DataColumn(
                          label: Text('Category', style: TextStyle(fontWeight: FontWeight.w700))),
                      DataColumn(
                          label: Text('Date Registered', style: TextStyle(fontWeight: FontWeight.w700))),
                      DataColumn(
                          label: Text('Date Removed', style: TextStyle(fontWeight: FontWeight.w700))),
                      DataColumn(
                          label: Text('Removed at', style: TextStyle(fontWeight: FontWeight.w700))),
                      DataColumn(
                          label: Text('Location', style: TextStyle(fontWeight: FontWeight.w700))),
                      DataColumn(
                          label: Text('Actions', style: TextStyle(fontWeight: FontWeight.w700))),
                    ],
                    rows: _items
                        .map(
                          (asset) => DataRow(
                            cells: [
                              DataCell(Text(asset.name)),
                              DataCell(Text(asset.category)),
                              DataCell(Text(asset.dateArrived)),
                              DataCell(Text(asset.dateRemoved)),
                              DataCell(Text(asset.removedAtText)),
                              DataCell(Text(asset.location)),
                              DataCell(Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit, size: 18),
                                    tooltip: 'Edit',
                                    onPressed: () => widget.onEdit(asset),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, size: 18),
                                    tooltip: 'Delete',
                                    onPressed: () => _confirmDelete(asset),
                                  ),
                                ],
                              )),
                            ],
                          ),
                        )
                        .toList(),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
