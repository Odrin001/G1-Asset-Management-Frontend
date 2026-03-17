enum AssetType { computerHardware, furniture }

class AssetItem {
  final String name;
  final String category;
  final String dateArrived;
  final String dateRemoved;
  final String location;

  const AssetItem({
    required this.name,
    required this.category,
    required this.dateArrived,
    required this.dateRemoved,
    required this.location,
  });
}

class AssetData {
  static const computerHardware = <AssetItem>[
    AssetItem(
      name: 'Desktop Computer',
      category: 'Computers',
      dateArrived: '10-10-2010',
      dateRemoved: '10-10-2010',
      location: 'Classroom 1',
    ),
    AssetItem(
      name: 'Laptop',
      category: 'Computers',
      dateArrived: '15-02-2012',
      dateRemoved: '15-02-2012',
      location: 'Classroom 2',
    ),
    AssetItem(
      name: 'Monitor',
      category: 'Peripherals',
      dateArrived: '05-06-2005',
      dateRemoved: '05-06-2005',
      location: 'Classroom 3',
    ),
    AssetItem(
      name: 'Printer',
      category: 'Peripherals',
      dateArrived: '01-01-2022',
      dateRemoved: '01-01-2022',
      location: 'Classroom 4',
    ),
    AssetItem(
      name: 'Router',
      category: 'Network',
      dateArrived: '04-05-2022',
      dateRemoved: '04-05-2022',
      location: 'Classroom 5',
    ),
    AssetItem(
      name: 'Network Switch',
      category: 'Network',
      dateArrived: '01-01-2023',
      dateRemoved: '01-01-2023',
      location: 'Classroom 6',
    ),
    AssetItem(
      name: 'External Hard Drive',
      category: 'Storage',
      dateArrived: '10-10-2007',
      dateRemoved: '10-10-2007',
      location: 'Classroom 7',
    ),
    AssetItem(
      name: 'UPS (Uninterruptible Power Supply)',
      category: 'Power',
      dateArrived: '08-12-2020',
      dateRemoved: '08-12-2020',
      location: 'Classroom 8',
    ),
  ];

  static const furniture = <AssetItem>[
    AssetItem(
      name: 'Ergonomic Chair',
      category: 'Furniture',
      dateArrived: '12-03-2018',
      dateRemoved: '12-03-2018',
      location: 'Classroom 1',
    ),
    AssetItem(
      name: 'Standing Desk',
      category: 'Furniture',
      dateArrived: '22-07-2019',
      dateRemoved: '22-07-2019',
      location: 'Classroom 2',
    ),
    AssetItem(
      name: 'Filing Cabinet',
      category: 'Furniture',
      dateArrived: '05-11-2020',
      dateRemoved: '05-11-2020',
      location: 'Classroom 3',
    ),
    AssetItem(
      name: 'Conference Table',
      category: 'Furniture',
      dateArrived: '01-02-2021',
      dateRemoved: '01-02-2021',
      location: 'Classroom 4',
    ),
    AssetItem(
      name: 'Bookshelf',
      category: 'Furniture',
      dateArrived: '15-09-2021',
      dateRemoved: '15-09-2021',
      location: 'Classroom 5',
    ),
  ];
}
