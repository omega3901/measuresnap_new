// lib/screens/premium_screen.dart

import 'package:flutter/material.dart';
import '../services/settings_service.dart';
import 'package:provider/provider.dart';

class PremiumScreen extends StatelessWidget {
  const PremiumScreen({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upgrade to Premium'),
      ),
      body: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade600, Colors.purple.shade600],
              ),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.workspace_premium,
                  size: 64,
                  color: Colors.white,
                ),
                const SizedBox(height: 16),
                const Text(
                  'MeasureSnap Premium',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Unlock all features',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          
          // Features
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildFeature('Unlimited Measurements', Icons.all_inclusive, true),
                _buildFeature('Remove Ads', Icons.block, true),
                _buildFeature('Cloud Backup', Icons.cloud_upload, true),
                _buildFeature('Export to PDF/CSV', Icons.download, true),
                _buildFeature('Priority Support', Icons.support_agent, true),
                _buildFeature('Custom Reference Objects', Icons.add_box, true),
                _buildFeature('Batch Processing', Icons.collections, true),
                _buildFeature('Advanced Accuracy Mode', Icons.precision_manufacturing, true),
              ],
            ),
          ),
          
          // Pricing
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Monthly option
                Card(
                  child: RadioListTile<String>(
                    title: const Text('Monthly'),
                    subtitle: const Text('\$4.99/month'),
                    value: 'monthly',
                    groupValue: 'monthly',
                    onChanged: (value) {},
                  ),
                ),
                
                // Annual option (best value)
                Card(
                  color: Colors.green.shade50,
                  child: Stack(
                    children: [
                      RadioListTile<String>(
                        title: const Text('Annual'),
                        subtitle: const Text('\$39.99/year (Save 33%)'),
                        value: 'annual',
                        groupValue: 'monthly',
                        onChanged: (value) {},
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'BEST VALUE',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Purchase button
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  // Process purchase
                  context.read<SettingsService>().upgradeToPremium();
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Welcome to Premium!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Start Free Trial',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildFeature(String title, IconData icon, bool included) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            included ? Icons.check_circle : Icons.cancel,
            color: included ? Colors.green : Colors.grey,
          ),
          const SizedBox(width: 16),
          Icon(icon, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 16,
                color: included ? null : Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }
}