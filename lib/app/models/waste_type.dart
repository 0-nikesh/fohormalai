import 'package:flutter/material.dart';

enum WasteType {
  compost,
  paper,
  plastic,
  metal,
  glass,
  electronic,
  other;

  String get displayName {
    switch (this) {
      case WasteType.compost:
        return 'Compost/Organic';
      case WasteType.paper:
        return 'Paper';
      case WasteType.plastic:
        return 'Plastic';
      case WasteType.metal:
        return 'Metal';
      case WasteType.glass:
        return 'Glass';
      case WasteType.electronic:
        return 'Electronic';
      case WasteType.other:
        return 'Other';
    }
  }

  List<Color> get gradientColors {
    switch (this) {
      case WasteType.compost:
        return [const Color(0xFF76BA1B), const Color(0xFF4D9A0B)];
      case WasteType.paper:
        return [const Color(0xFFBDBDBD), const Color(0xFF757575)];
      case WasteType.plastic:
        return [const Color(0xFF64B5F6), const Color(0xFF1976D2)];
      case WasteType.metal:
        return [const Color(0xFFB0BEC5), const Color(0xFF546E7A)];
      case WasteType.glass:
        return [const Color(0xFF80DEEA), const Color(0xFF00ACC1)];
      case WasteType.electronic:
        return [const Color(0xFFFFB74D), const Color(0xFFF57C00)];
      case WasteType.other:
        return [const Color(0xFF81C784), const Color(0xFF2E7D32)];
    }
  }

  Color get color {
    switch (this) {
      case WasteType.compost:
        return const Color(0xFF76BA1B);
      case WasteType.paper:
        return const Color(0xFFBDBDBD);
      case WasteType.plastic:
        return const Color(0xFF64B5F6);
      case WasteType.metal:
        return const Color(0xFFB0BEC5);
      case WasteType.glass:
        return const Color(0xFF80DEEA);
      case WasteType.electronic:
        return const Color(0xFFFFB74D);
      case WasteType.other:
        return const Color(0xFF81C784);
    }
  }

  IconData get icon {
    switch (this) {
      case WasteType.compost:
        return Icons.eco;
      case WasteType.paper:
        return Icons.article;
      case WasteType.plastic:
        return Icons.local_drink;
      case WasteType.metal:
        return Icons.precision_manufacturing;
      case WasteType.glass:
        return Icons.wine_bar;
      case WasteType.electronic:
        return Icons.devices;
      case WasteType.other:
        return Icons.category;
    }
  }
}
