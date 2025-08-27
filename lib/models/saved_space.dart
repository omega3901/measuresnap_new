// lib/models/saved_space.dart

class SavedSpace {
  final String id;
  final String name;
  final SpaceType type;
  final Map<String, double> dimensions; // width, height, depth in mm
  final DateTime createdAt;
  final String? notes;
  final List<String>? photoIds; // References to measurements
  
  SavedSpace({
    String? id,
    required this.name,
    required this.type,
    required this.dimensions,
    DateTime? createdAt,
    this.notes,
    this.photoIds,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();
  
  bool willFitItem(double width, double height, double depth) {
    return width <= (dimensions['width'] ?? 0) &&
           height <= (dimensions['height'] ?? 0) &&
           depth <= (dimensions['depth'] ?? 0);
  }
}

enum SpaceType {
  doorway,
  room,
  closet,
  trunk,
  elevator,
  stairway,
  custom,
}