class Vehicle {
  final String id;
  final String brand;
  final String model;
  final int year;
  final String color;
  final String? plateNumber;
  final String mono;
  final bool isMain;

  const Vehicle({
    required this.id,
    required this.brand,
    required this.model,
    required this.year,
    required this.color,
    this.plateNumber,
    required this.mono,
    this.isMain = false,
  });

  String get displayName => '$brand $model';
  String get displayNameWithYear => '$brand $model $year';
}
