class Motorcycle {
  final String id, brand, name, category;
  final int? modelYear, price;
  final double? displacement, weight, seatHeight;
  final String? engine, transmission, cooling, power, torque, sourceUrl, updatedAt, imageAsset;

  const Motorcycle({
    required this.id,
    required this.brand,
    required this.name,
    required this.category,
    this.modelYear,
    this.price,
    this.displacement,
    this.weight,
    this.seatHeight,
    this.engine,
    this.transmission,
    this.cooling,
    this.power,
    this.torque,
    this.sourceUrl,
    this.updatedAt,
    this.imageAsset,
  });

  factory Motorcycle.fromJson(Map<String, dynamic> json) => Motorcycle(
        id: json['id'] as String,
        brand: json['brand'] as String,
        name: json['name'] as String,
        category: json['category'] as String,
        modelYear: json['modelYear'] as int?,
        price: json['price'] as int?,
        displacement: (json['displacement'] as num?)?.toDouble(),
        weight: (json['weight'] as num?)?.toDouble(),
        seatHeight: (json['seatHeight'] as num?)?.toDouble(),
        engine: json['engine'] as String?,
        transmission: json['transmission'] as String?,
        cooling: json['cooling'] as String?,
        power: json['power'] as String?,
        torque: json['torque'] as String?,
        sourceUrl: json['sourceUrl'] as String?,
        updatedAt: json['updatedAt'] as String?,
        imageAsset: json['imageAsset'] as String?,
      );

  String get fullName => '$brand $name';
}
