import 'package:flutter/material.dart';

// ─────────────────────────────────────────────
// COULEURS GLOBALES DE L'APPLICATION
// ─────────────────────────────────────────────
const kGreen      = Color(0xFF2EAF6F);
const kGreenLight = Color(0xFFE8F7EF);
const kGreenDark  = Color(0xFF1E8A55);
const kYellow     = Color(0xFFF5C842);
const kGrey       = Color(0xFF6B7280);
const kLightGrey  = Color(0xFFF3F4F6);
const kText       = Color(0xFF1F2937);

// ─────────────────────────────────────────────
// COULEUR PAR CATÉGORIE DE CONTENU
// ─────────────────────────────────────────────
Color getCategorieColor(String? categorie) {
  switch (categorie?.toLowerCase()) {
    case 'bien-être': return const Color(0xFF10B981);
    case 'relations': return const Color(0xFF3B82F6);
    case 'sommeil':   return const Color(0xFF8B5CF6);
    case 'stress':    return const Color(0xFFEF4444);
    default:          return kGreen;
  }
}

// ─────────────────────────────────────────────
// COULEUR + ICÔNE PAR THÈME DE DIAGNOSTIC
// ─────────────────────────────────────────────
Color getThemeColor(String? theme) {
  switch (theme?.toLowerCase()) {
    case 'stress':    return const Color(0xFFEF4444);
    case 'sommeil':   return const Color(0xFF8B5CF6);
    case 'relations': return const Color(0xFF3B82F6);
    case 'bien-être': return const Color(0xFF10B981);
    default:          return kGreen;
  }
}

IconData getThemeIcon(String? theme) {
  switch (theme?.toLowerCase()) {
    case 'stress':    return Icons.self_improvement;
    case 'sommeil':   return Icons.bedtime_outlined;
    case 'relations': return Icons.people_outline;
    case 'bien-être': return Icons.favorite_border;
    default:          return Icons.psychology_outlined;
  }
}