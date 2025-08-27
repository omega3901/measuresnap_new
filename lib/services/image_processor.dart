// lib/services/image_processor.dart

import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;

class ImageProcessor {
  // Auto-detect reference objects in image
  static Future<List<DetectedObject>> detectReferenceObjects(String imagePath) async {
    // Simplified detection - in production use ML Kit
    final List<DetectedObject> detected = [];
    
    // For MVP, return manual selection prompt
    return detected;
  }
  
  // Enhance image for better detection
  static Future<File> enhanceImage(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    final image = img.decodeImage(bytes);
    
    if (image != null) {
      // Auto-adjust brightness and contrast
      final enhanced = img.adjustColor(image, 
        brightness: 1.1,
        contrast: 1.2,
      );
      
      // Save enhanced image
      final enhancedFile = File(imageFile.path.replaceAll('.jpg', '_enhanced.jpg'));
      await enhancedFile.writeAsBytes(img.encodeJpg(enhanced));
      return enhancedFile;
    }
    
    return imageFile;
  }
  
  // Calculate measurement accuracy confidence
  static double calculateConfidence(List<Offset> referencePoints) {
    if (referencePoints.length != 4) return 0;
    
    // Check if points form a reasonable rectangle
    final width1 = (referencePoints[1] - referencePoints[0]).distance;
    final width2 = (referencePoints[3] - referencePoints[2]).distance;
    final height1 = (referencePoints[2] - referencePoints[0]).distance;
    final height2 = (referencePoints[3] - referencePoints[1]).distance;
    
    // Calculate how "rectangular" the selection is
    final widthRatio = width1 / width2;
    final heightRatio = height1 / height2;
    
    // Perfect rectangle = 1.0, distorted = lower
    final confidence = 2.0 - (widthRatio - 1.0).abs() - (heightRatio - 1.0).abs();
    return confidence.clamp(0.0, 1.0);
  }
}

class DetectedObject {
  final String type;
  final List<Offset> corners;
  final double confidence;
  
  DetectedObject({
    required this.type,
    required this.corners,
    required this.confidence,
  });
}