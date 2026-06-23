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

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    final brand = json['brand'] as String? ?? '';
    return Vehicle(
      id: json['id'] as String,
      brand: brand,
      model: json['model'] as String? ?? '',
      year: json['year'] as int? ?? 0,
      color: json['color'] as String? ?? '',
      plateNumber: json['plateNumber'] as String?,
      mono: brand.isNotEmpty ? brand[0] : '?',
      isMain: false,
    );
  }

  String get displayName => '$brand $model';
  String get displayNameWithYear => '$brand $model $year';
}
