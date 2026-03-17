import 'package:flutter/material.dart';

import '../models/asset_item.dart';

class FurnitureTable extends StatefulWidget {
  const FurnitureTable({
    super.key,
    required this.selectedType,
    required this.onTypeChanged,
  });

  final AssetType selectedType;
  final ValueChanged<AssetType> onTypeChanged;

  @override
  State<FurnitureTable> createState() => _FurnitureTableState();
}

class _FurnitureTableState extends State<FurnitureTable> {
  late AssetType _currentType;

  @override
  void initState() {
    super.initState();
    _currentType = widget.selectedType;
  }

  @override
  void didUpdateWidget(covariant FurnitureTable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedType != widget.selectedType) {
      _currentType = widget.selectedType;
    }
  }

  List<AssetItem> get _items {
    return _currentType == AssetType.computerHardware
        ? AssetData.computerHardware
        : AssetData.furniture;
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
                  'Furniture',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                ),
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
                    dataRowHeight: 52,
                    headingRowColor: MaterialStateProperty.all(const Color(0xfff3f4f6)),
                    columns: const [
                      DataColumn(
                          label: Text('Name', style: TextStyle(fontWeight: FontWeight.w700))),
                      DataColumn(
                          label: Text('Category', style: TextStyle(fontWeight: FontWeight.w700))),
                      DataColumn(
                          label: Text('Date Arrived', style: TextStyle(fontWeight: FontWeight.w700))),
                      DataColumn(
                          label: Text('Date Removed', style: TextStyle(fontWeight: FontWeight.w700))),
                      DataColumn(
                          label: Text('Location', style: TextStyle(fontWeight: FontWeight.w700))),
                    ],
                    rows: _items
                        .map(
                          (asset) => DataRow(
                            cells: [
                              DataCell(Text(asset.name)),
                              DataCell(Text(asset.category)),
                              DataCell(Text(asset.dateArrived)),
                              DataCell(Text(asset.dateRemoved)),
                              DataCell(Text(asset.location)),
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
