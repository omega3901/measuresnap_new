// lib/screens/measurement_screen.dart

import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/reference_object.dart';
import '../models/measurement.dart';
import '../services/measurement_service.dart';
import '../services/database_service.dart';
import 'package:provider/provider.dart';

class MeasurementScreen extends StatefulWidget {
  final String imagePath;
  final ReferenceObject selectedReference;
  
  const MeasurementScreen({
    super.key,
    required this.imagePath,
    required this.selectedReference,
  });

  @override
  State<MeasurementScreen> createState() => _MeasurementScreenState();
}

class _MeasurementScreenState extends State<MeasurementScreen> {
  List<Offset> _referencePoints = [];
  List<Offset> _measurementPoints = [];
  List<MeasurementLine> _measurements = [];
  double _pixelToMmRatio = 0;
  bool _isMarkingReference = true;
  String _selectedUnit = 'cm';
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Measure'),
        actions: [
          if (_measurements.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _saveMeasurement,
            ),
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                _selectedUnit = value;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'mm', child: Text('Millimeters')),
              const PopupMenuItem(value: 'cm', child: Text('Centimeters')),
              const PopupMenuItem(value: 'inches', child: Text('Inches')),
              const PopupMenuItem(value: 'feet', child: Text('Feet')),
            ],
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Chip(
                label: Text(_selectedUnit.toUpperCase()),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Instructions
          Container(
            padding: const EdgeInsets.all(12),
            color: _isMarkingReference 
              ? Colors.orange.shade100 
              : Colors.green.shade100,
            child: Row(
              children: [
                Icon(
                  _isMarkingReference ? Icons.crop_free : Icons.straighten,
                  color: _isMarkingReference ? Colors.orange : Colors.green,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _isMarkingReference
                      ? 'Tap the corners of the ${widget.selectedReference.name}'
                      : 'Tap two points to measure distance',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
                if (_referencePoints.length == 4)
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _isMarkingReference = false;
                        _calculatePixelRatio();
                      });
                    },
                    child: const Text('Start Measuring'),
                  ),
              ],
            ),
          ),
          
          // Image with touch detection
          Expanded(
            child: InteractiveViewer(
              child: GestureDetector(
                onTapUp: (details) {
                  final RenderBox box = context.findRenderObject() as RenderBox;
                  final localPosition = box.globalToLocal(details.globalPosition);
                  _handleTap(localPosition);
                },
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.file(
                      File(widget.imagePath),
                      fit: BoxFit.contain,
                    ),
                    CustomPaint(
                      painter: MeasurementPainter(
                        referencePoints: _referencePoints,
                        measurementPoints: _measurementPoints,
                        measurements: _measurements,
                        isMarkingReference: _isMarkingReference,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Measurements List
          if (_measurements.isNotEmpty)
            Container(
              height: 120,
              child: ListView.builder(
                itemCount: _measurements.length,
                itemBuilder: (context, index) {
                  final m = _measurements[index];
                  return ListTile(
                    leading: CircleAvatar(
                      child: Text('${index + 1}'),
                    ),
                    title: Text(_formatDistance(m)),
                    subtitle: Text('Line ${index + 1}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        setState(() {
                          _measurements.removeAt(index);
                        });
                      },
                    ),
                  );
                },
              ),
            ),
        ],
      ),
      floatingActionButton: _measurements.isNotEmpty
        ? FloatingActionButton.extended(
            onPressed: () {
              setState(() {
                _measurementPoints.clear();
              });
            },
            label: const Text('New Measurement'),
            icon: const Icon(Icons.add),
          )
        : null,
    );
  }
  
  void _handleTap(Offset position) {
    setState(() {
      if (_isMarkingReference) {
        if (_referencePoints.length < 4) {
          _referencePoints.add(position);
        }
        if (_referencePoints.length == 4) {
          _calculatePixelRatio();
        }
      } else {
        _measurementPoints.add(position);
        if (_measurementPoints.length == 2) {
          _createMeasurement();
        }
      }
    });
  }
  
  void _calculatePixelRatio() {
    if (_referencePoints.length != 4) return;
    
    // Calculate average width and height of reference object in pixels
    final width1 = (_referencePoints[1] - _referencePoints[0]).distance;
    final width2 = (_referencePoints[3] - _referencePoints[2]).distance;
    final avgWidth = (width1 + width2) / 2;
    
    _pixelToMmRatio = widget.selectedReference.widthMm / avgWidth;
  }
  
  void _createMeasurement() {
    if (_measurementPoints.length != 2 || _pixelToMmRatio == 0) return;
    
    final distance = (_measurementPoints[1] - _measurementPoints[0]).distance;
    final distanceMm = distance * _pixelToMmRatio;
    
    setState(() {
      _measurements.add(
        MeasurementLine(
          startX: _measurementPoints[0].dx,
          startY: _measurementPoints[0].dy,
          endX: _measurementPoints[1].dx,
          endY: _measurementPoints[1].dy,
          distanceMm: distanceMm,
          pixelToMmRatio: _pixelToMmRatio,
        ),
      );
      _measurementPoints.clear();
    });
  }
  
  String _formatDistance(MeasurementLine line) {
    switch (_selectedUnit) {
      case 'mm':
        return '${line.distanceMm.toStringAsFixed(1)} mm';
      case 'cm':
        return '${line.distanceCm.toStringAsFixed(1)} cm';
      case 'inches':
        return '${line.distanceInches.toStringAsFixed(2)} inches';
      case 'feet':
        return '${line.distanceFeet.toStringAsFixed(2)} feet';
      default:
        return '${line.distanceCm.toStringAsFixed(1)} cm';
    }
  }
  
  Future<void> _saveMeasurement() async {
    final measurement = Measurement(
      imagePath: widget.imagePath,
      referenceUsed: widget.selectedReference,
      measurements: _measurements,
      title: 'Measurement ${DateTime.now().toString().substring(0, 16)}',
    );
    
    final db = Provider.of<DatabaseService>(context, listen: false);
    await db.saveMeasurement(measurement);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Measurement saved!')),
      );
      Navigator.pop(context);
    }
  }
}

// Measurement Painter
class MeasurementPainter extends CustomPainter {
  final List<Offset> referencePoints;
  final List<Offset> measurementPoints;
  final List<MeasurementLine> measurements;
  final bool isMarkingReference;
  
  MeasurementPainter({
    required this.referencePoints,
    required this.measurementPoints,
    required this.measurements,
    required this.isMarkingReference,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final pointPaint = Paint()
      ..style = PaintingStyle.fill
      ..strokeWidth = 3;
    
    final linePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    
    // Draw reference points
    if (referencePoints.isNotEmpty) {
      pointPaint.color = Colors.orange;
      linePaint.color = Colors.orange;
      
      for (final point in referencePoints) {
        canvas.drawCircle(point, 8, pointPaint);
      }
      
      if (referencePoints.length >= 2) {
        for (int i = 0; i < referencePoints.length - 1; i++) {
          canvas.drawLine(referencePoints[i], referencePoints[i + 1], linePaint);
        }
        if (referencePoints.length == 4) {
          canvas.drawLine(referencePoints.last, referencePoints.first, linePaint);
        }
      }
    }
    
    // Draw measurement points and lines
    pointPaint.color = Colors.green;
    linePaint.color = Colors.green;
    
    for (final measurement in measurements) {
      final start = Offset(measurement.startX, measurement.startY);
      final end = Offset(measurement.endX, measurement.endY);
      canvas.drawLine(start, end, linePaint);
      canvas.drawCircle(start, 6, pointPaint);
      canvas.drawCircle(end, 6, pointPaint);
    }
    
    // Draw current measurement points
    for (final point in measurementPoints) {
      canvas.drawCircle(point, 8, pointPaint);
    }
    
    if (measurementPoints.length == 2) {
      canvas.drawLine(measurementPoints[0], measurementPoints[1], linePaint);
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}