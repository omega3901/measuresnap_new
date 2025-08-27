// lib/widgets/reference_selector.dart

import 'package:flutter/material.dart';
import '../models/reference_object.dart';

class ReferenceSelector extends StatelessWidget {
  final ReferenceObject selected;
  final Function(ReferenceObject) onChanged;
  
  const ReferenceSelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: ReferenceObject.standardObjects.length,
        itemBuilder: (context, index) {
          final ref = ReferenceObject.standardObjects[index];
          final isSelected = ref.id == selected.id;
          
          return GestureDetector(
            onTap: () => onChanged(ref),
            child: Container(
              width: 90,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: isSelected 
                  ? Theme.of(context).colorScheme.primaryContainer
                  : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey.shade300,
                  width: 2,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _getIcon(ref.id),
                    size: 32,
                    color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Colors.grey.shade600,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    ref.name,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey.shade700,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
  
  IconData _getIcon(String id) {
    switch (id) {
      case 'credit_card':
        return Icons.credit_card;
      case 'us_quarter':
        return Icons.monetization_on;
      case 'us_dollar':
        return Icons.attach_money;
      case 'iphone_15':
        return Icons.phone_iphone;
      case 'a4_paper':
        return Icons.description;
      default:
        return Icons.straighten;
    }
  }
}