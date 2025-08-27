// lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'camera_screen.dart';
import 'history_screen.dart';
import 'will_it_fit_screen.dart';
import 'measurement_screen.dart';
import '../widgets/reference_selector.dart';
import '../models/reference_object.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final ImagePicker _picker = ImagePicker();
  ReferenceObject _selectedReference = ReferenceObject.standardObjects[0];

  final List<Widget> _screens = [
    const MeasureTab(),
    const HistoryScreen(),
    const WillItFitScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _currentIndex == 0 ? _buildMeasureTab() : _screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.straighten),
            label: 'Measure',
          ),
          NavigationDestination(
            icon: Icon(Icons.history),
            label: 'History',
          ),
          NavigationDestination(
            icon: Icon(Icons.aspect_ratio),
            label: 'Will It Fit?',
          ),
        ],
      ),
    );
  }
  
  Widget _buildMeasureTab() {
    return MeasureTab(
      selectedReference: _selectedReference,
      onReferenceChanged: (ref) {
        setState(() {
          _selectedReference = ref;
        });
      },
      onCameraPressed: () => _openCamera(),
      onGalleryPressed: () => _openGallery(),
    );
  }
  
  void _openCamera() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CameraScreen(
          selectedReference: _selectedReference,
        ),
      ),
    );
  }
  
  Future<void> _openGallery() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null && mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => MeasurementScreen(
            imagePath: image.path,
            selectedReference: _selectedReference,
          ),
        ),
      );
    }
  }
}

class MeasureTab extends StatelessWidget {
  final ReferenceObject selectedReference;
  final Function(ReferenceObject) onReferenceChanged;
  final VoidCallback onCameraPressed;
  final VoidCallback onGalleryPressed;
  
  const MeasureTab({
    super.key,
    required this.selectedReference,
    required this.onReferenceChanged,
    required this.onCameraPressed,
    required this.onGalleryPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          // App Bar
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Image.asset(
                  'assets/images/logo.png',
                  height: 32,
                  errorBuilder: (_, __, ___) => const Icon(Icons.straighten, size: 32),
                ),
                const SizedBox(width: 12),
                const Text(
                  'MeasureSnap',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.settings),
                  onPressed: () {
                    // Navigate to settings
                  },
                ),
              ],
            ),
          ),
          
          // Instructions Card
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'How to measure:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: 8),
                _buildStep('1', 'Place reference object in photo'),
                _buildStep('2', 'Take or select photo'),
                _buildStep('3', 'Mark reference object'),
                _buildStep('4', 'Tap points to measure'),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Reference Selector
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Select Reference Object:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                ReferenceSelector(
                  selected: selectedReference,
                  onChanged: onReferenceChanged,
                ),
              ],
            ),
          ),
          
          const Spacer(),
          
          // Action Buttons
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: onCameraPressed,
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Take Photo'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: OutlinedButton.icon(
                    onPressed: onGalleryPressed,
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Choose from Gallery'),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildStep(String number, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.3),
            ),
            child: Text(
              number,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(text),
        ],
      ),
    );
  }
}