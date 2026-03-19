enum AssetType { computerHardware, furniture }

enum AssetActivityType { added, moved, removed, updated }

class AssetActivity {
  final DateTime timestamp;
  final String assetId;
  final String assetName;
  final AssetActivityType type;
  final String details;

  const AssetActivity({
    required this.timestamp,
    required this.assetId,
    required this.assetName,
    required this.type,
    required this.details,
  });
}

enum ScanDirection { inwards, outwards }

class ScanEvent {
  final DateTime timestamp;
  final String assetId;
  final String assetName;
  final ScanDirection direction;
  final String location;

  const ScanEvent({
    required this.timestamp,
    required this.assetId,
    required this.assetName,
    required this.direction,
    required this.location,
  });
}

class AssetItem {
  final String id;
  final String name;
  final String category;
  final String dateArrived;
  final String dateRemoved;
  final String location;

  const AssetItem({
    required this.id,
    required this.name,
    required this.category,
    required this.dateArrived,
    required this.dateRemoved,
    required this.location,
  });

  AssetItem copyWith({
    String? id,
    String? name,
    String? category,
    String? dateArrived,
    String? dateRemoved,
    String? location,
  }) {
    return AssetItem(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      dateArrived: dateArrived ?? this.dateArrived,
      dateRemoved: dateRemoved ?? this.dateRemoved,
      location: location ?? this.location,
    );
  }

  DateTime? _parseDateTime(String value) {
    // Supported formats:
    // - "dd-MM-yyyy"
    // - "dd-MM-yyyy HH:mm"
    // - "dd-MM-yyyy hh:mma" (e.g. 01-01-2024 3:43pm)
    final parts = value.trim().split(' ');
    if (parts.isEmpty) return null;

    final dateParts = parts[0].split('-');
    if (dateParts.length != 3) return null;

    final day = int.tryParse(dateParts[0]);
    final month = int.tryParse(dateParts[1]);
    final year = int.tryParse(dateParts[2]);
    if (day == null || month == null || year == null) return null;

    if (parts.length == 1) {
      return DateTime(year, month, day);
    }

    final timePart = parts[1];
    final timeParts = timePart.split(':');
    if (timeParts.length != 2) return DateTime(year, month, day);

    final rawHour = timeParts[0];
    final rawMinute = timeParts[1];

    var hour = int.tryParse(rawHour);
    final minute = int.tryParse(rawMinute.replaceAll(RegExp(r'[^0-9]'), ''));
    if (hour == null || minute == null) return DateTime(year, month, day);

    // Handle am/pm suffix if present
    final suffixMatch = RegExp(r'([ap]m)\b', caseSensitive: false).firstMatch(rawMinute);
    if (suffixMatch != null) {
      final suffix = suffixMatch.group(1)!.toLowerCase();
      if (suffix == 'pm' && hour < 12) hour += 12;
      if (suffix == 'am' && hour == 12) hour = 0;
    }

    return DateTime(year, month, day, hour, minute);
  }

  /// Parsed `dateRemoved` as a `DateTime`, or `null` if unable.
  DateTime? get removedAt => _parseDateTime(dateRemoved);

  /// Duration between arrival and removal, shown as a simple "X days" string.
  String get timeInRoom {
    final start = _parseDateTime(dateArrived);
    final end = removedAt;
    if (start == null || end == null) return '';

    final days = end.difference(start).inDays;
    if (days < 0) return '${-days} days (invalid dates)';
    return '$days day${days == 1 ? '' : 's'}';
  }

  /// Returns a friendly human-readable removal time phrase.
  /// Example: "Removed at 3:43 PM".
  String get removedAtText {
    final dt = removedAt;
    if (dt == null) return '';

    final hour = dt.hour == 0 ? 12 : (dt.hour > 12 ? dt.hour - 12 : dt.hour);
    final minute = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    return 'Removed at $hour:$minute $period';
  }
}


class AssetData {
  static const computerHardware = <AssetItem>[
    AssetItem(
      id: 'comp-1',
      name: 'Desktop Computer',
      category: 'Computers',
      dateArrived: '10-10-2010',
      dateRemoved: '10-10-2010',
      location: 'Classroom 1',
    ),
    AssetItem(
      id: 'comp-2',
      name: 'Laptop',
      category: 'Computers',
      dateArrived: '15-02-2012',
      dateRemoved: '15-02-2012',
      location: 'Classroom 2',
    ),
    AssetItem(
      id: 'comp-3',
      name: 'Monitor',
      category: 'Peripherals',
      dateArrived: '05-06-2005',
      dateRemoved: '05-06-2005',
      location: 'Classroom 3',
    ),
    AssetItem(
      id: 'comp-4',
      name: 'Printer',
      category: 'Peripherals',
      dateArrived: '01-01-2022',
      dateRemoved: '01-01-2022',
      location: 'Classroom 4',
    ),
    AssetItem(
      id: 'comp-5',
      name: 'Router',
      category: 'Network',
      dateArrived: '04-05-2022',
      dateRemoved: '04-05-2022',
      location: 'Classroom 5',
    ),
    AssetItem(
      id: 'comp-6',
      name: 'Network Switch',
      category: 'Network',
      dateArrived: '01-01-2023',
      dateRemoved: '01-01-2023',
      location: 'Classroom 6',
    ),
    AssetItem(
      id: 'comp-7',
      name: 'External Hard Drive',
      category: 'Storage',
      dateArrived: '10-10-2007',
      dateRemoved: '10-10-2007',
      location: 'Classroom 7',
    ),
    AssetItem(
      id: 'comp-8',
      name: 'UPS (Uninterruptible Power Supply)',
      category: 'Power',
      dateArrived: '08-12-2020',
      dateRemoved: '08-12-2020',
      location: 'Classroom 8',
    ),
  ];

  static const furniture = <AssetItem>[
    AssetItem(
      id: 'furn-1',
      name: 'Ergonomic Chair',
      category: 'Furniture',
      dateArrived: '12-03-2018',
      dateRemoved: '12-03-2018',
      location: 'Classroom 1',
    ),
    AssetItem(
      id: 'furn-2',
      name: 'Standing Desk',
      category: 'Furniture',
      dateArrived: '22-07-2019',
      dateRemoved: '22-07-2019',
      location: 'Classroom 2',
    ),
    AssetItem(
      id: 'furn-3',
      name: 'Filing Cabinet',
      category: 'Furniture',
      dateArrived: '05-11-2020',
      dateRemoved: '05-11-2020',
      location: 'Classroom 3',
    ),
    AssetItem(
      id: 'furn-4',
      name: 'Conference Table',
      category: 'Furniture',
      dateArrived: '01-02-2021',
      dateRemoved: '01-02-2021',
      location: 'Classroom 4',
    ),
    AssetItem(
      id: 'furn-5',
      name: 'Bookshelf',
      category: 'Furniture',
      dateArrived: '15-09-2021',
      dateRemoved: '15-09-2021',
      location: 'Classroom 5',
    ),
  ];
}
