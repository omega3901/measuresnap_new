// lib/models/reference_object.dart

class ReferenceObject {
  final String id;
  final String name;
  final double widthMm;
  final double heightMm;
  final String iconPath;
  final String detectionKeyword;
  
  const ReferenceObject({
    required this.id,
    required this.name,
    required this.widthMm,
    required this.heightMm,
    required this.iconPath,
    required this.detectionKeyword,
  });
  
  static const List<ReferenceObject> standardObjects = [
    ReferenceObject(
      id: 'credit_card',
      name: 'Credit Card',
      widthMm: 85.6,
      heightMm: 53.98,
      iconPath: 'assets/images/credit_card.png',
      detectionKeyword: 'credit card',
    ),
    ReferenceObject(
      id: 'us_quarter',
      name: 'US Quarter',
      widthMm: 24.26,
      heightMm: 24.26,
      iconPath: 'assets/images/quarter.png',
      detectionKeyword: 'coin',
    ),
    ReferenceObject(
      id: 'us_dollar',
      name: 'US Dollar Bill',
      widthMm: 156.0,
      heightMm: 66.3,
      iconPath: 'assets/images/dollar.png',
      detectionKeyword: 'money',
    ),
    ReferenceObject(
      id: 'iphone_15',
      name: 'iPhone 15',
      widthMm: 147.6,
      heightMm: 71.6,
      iconPath: 'assets/images/iphone15.png',
      detectionKeyword: 'phone',
    ),
    ReferenceObject(
      id: 'a4_paper',
      name: 'A4 Paper',
      widthMm: 210.0,
      heightMm: 297.0,
      iconPath: 'assets/images/a4.png',
      detectionKeyword: 'paper',
    ),
  ];
}