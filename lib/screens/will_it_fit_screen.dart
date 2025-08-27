// lib/screens/will_it_fit_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/database_service.dart';
import '../models/saved_space.dart';

class WillItFitScreen extends StatefulWidget {
  const WillItFitScreen({super.key});

  @override
  State<WillItFitScreen> createState() => _WillItFitScreenState();
}

class _WillItFitScreenState extends State<WillItFitScreen> {
  List<SavedSpace> _savedSpaces = [];
  final _widthController = TextEditingController();
  final _heightController = TextEditingController();
  final _depthController = TextEditingController();
  SavedSpace? _selectedSpace;
  String _unit = 'cm';
  bool? _willFit;
  
  @override
  void initState() {
    super.initState();
    _loadSavedSpaces();
  }
  
  Future<void> _loadSavedSpaces() async {
    final db = Provider.of<DatabaseService>(context, listen: false);
    final spaces = await db.getAllSavedSpaces();
    setState(() {
      _savedSpaces = spaces;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Will It Fit?'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addNewSpace,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Space Selector
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Select Space',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<SavedSpace>(
                      value: _selectedSpace,
                      hint: const Text('Choose a saved space'),
                      items: _savedSpaces.map((space) {
                        return DropdownMenuItem(
                          value: space,
                          child: Row(
                            children: [
                              Icon(_getSpaceIcon(space.type), size: 20),
                              const SizedBox(width: 8),
                              Text(space.name),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (space) {
                        setState(() {
                          _selectedSpace = space;
                          _willFit = null;
                        });
                      },
                    ),
                    if (_selectedSpace != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildDimension(
                              'Width', 
                              _selectedSpace!.dimensions['width'] ?? 0,
                            ),
                            _buildDimension(
                              'Height',
                              _selectedSpace!.dimensions['height'] ?? 0,
                            ),
                            _buildDimension(
                              'Depth',
                              _selectedSpace!.dimensions['depth'] ?? 0,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Item Dimensions Input
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Item Dimensions',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SegmentedButton<String>(
                          segments: const [
                            ButtonSegment(value: 'cm', label: Text('cm')),
                            ButtonSegment(value: 'inches', label: Text('in')),
                          ],
                          selected: {_unit},
                          onSelectionChanged: (Set<String> newSelection) {
                            setState(() {
                              _unit = newSelection.first;
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _widthController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Width',
                              suffixText: _unit,
                              border: const OutlineInputBorder(),
                            ),
                            onChanged: (_) => setState(() => _willFit = null),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _heightController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Height',
                              suffixText: _unit,
                              border: const OutlineInputBorder(),
                            ),
                            onChanged: (_) => setState(() => _willFit = null),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _depthController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Depth',
                              suffixText: _unit,
                              border: const OutlineInputBorder(),
                            ),
                            onChanged: (_) => setState(() => _willFit = null),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Check Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _selectedSpace == null ? null : _checkFit,
                child: const Text('Check Fit'),
              ),
            ),
            
            // Result
            if (_willFit != null) ...[
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _willFit! ? Colors.green.shade50 : Colors.red.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _willFit! ? Colors.green : Colors.red,
                    width: 2,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _willFit! ? Icons.check_circle : Icons.cancel,
                      color: _willFit! ? Colors.green : Colors.red,
                      size: 48,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _willFit! ? 'It will fit!' : 'It won\'t fit',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: _willFit! ? Colors.green : Colors.red,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _willFit!
                              ? 'The item will fit through/in the selected space'
                              : 'The item is too large for the selected space',
                            style: TextStyle(
                              color: _willFit! 
                                ? Colors.green.shade700 
                                : Colors.red.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
  
  Widget _buildDimension(String label, double valueMm) {
    final displayValue = _unit == 'cm' 
      ? valueMm / 10 
      : valueMm / 25.4;
    
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${displayValue.toStringAsFixed(1)} $_unit',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
  
  void _checkFit() {
    if (_selectedSpace == null) return;
    
    final width = double.tryParse(_widthController.text) ?? 0;
    final height = double.tryParse(_heightController.text) ?? 0;
    final depth = double.tryParse(_depthController.text) ?? 0;
    
    // Convert to mm if needed
    final widthMm = _unit == 'cm' ? width * 10 : width * 25.4;
    final heightMm = _unit == 'cm' ? height * 10 : height * 25.4;
    final depthMm = _unit == 'cm' ? depth * 10 : depth * 25.4;
    
    setState(() {
      _willFit = _selectedSpace!.willFitItem(widthMm, heightMm, depthMm);
    });
  }
  
  void _addNewSpace() {
    showDialog(
      context: context,
      builder: (context) => _AddSpaceDialog(
        onSave: (space) async {
          final db = Provider.of<DatabaseService>(context, listen: false);
          await db.saveSavedSpace(space);
          await _loadSavedSpaces();
        },
      ),
    );
  }
  
  IconData _getSpaceIcon(SpaceType type) {
    switch (type) {
      case SpaceType.doorway:
        return Icons.door_front_door;
      case SpaceType.room:
        return Icons.home;
      case SpaceType.closet:
        return Icons.checkroom;
      case SpaceType.trunk:
        return Icons.directions_car;
      case SpaceType.elevator:
        return Icons.elevator;
      case SpaceType.stairway:
        return Icons.stairs;
      case SpaceType.custom:
        return Icons.square_foot;
    }
  }
}

// Add Space Dialog
class _AddSpaceDialog extends StatefulWidget {
  final Function(SavedSpace) onSave;
  
  const _AddSpaceDialog({required this.onSave});
  
  @override
  State<_AddSpaceDialog> createState() => _AddSpaceDialogState();
}

class _AddSpaceDialogState extends State<_AddSpaceDialog> {
  final _nameController = TextEditingController();
  final _widthController = TextEditingController();
  final _heightController = TextEditingController();
  final _depthController = TextEditingController();
  SpaceType _selectedType = SpaceType.doorway;
  String _unit = 'cm';
  
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add New Space'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Space Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<SpaceType>(
              value: _selectedType,
              decoration: const InputDecoration(
                labelText: 'Type',
                border: OutlineInputBorder(),
              ),
              items: SpaceType.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type.toString().split('.').last),
                );
              }).toList(),
              onChanged: (type) {
                setState(() {
                  _selectedType = type!;
                });
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text('Unit: '),
                const SizedBox(width: 8),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'cm', la