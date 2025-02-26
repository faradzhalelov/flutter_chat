import 'package:flutter/material.dart';

class AppColors {
  AppColors._();
  
  // App background
  static const Color appBackground = Colors.white;
  static const Color headerBackground = Color(0xFF121212);
  static const Color searchBackground = Color(0xFFF2F2F7);
  static const Color messageInputBackground = Color(0xFFF2F2F7);
  
  // Message bubbles
  static const Color myMessageBubble = Color(0xFF7CFC00); // Light green
  static const Color otherMessageBubble = Color(0xFFF2F2F7); // Light gray
  
  // Text colors
  static const Color primaryText = Color(0xFF000000);
  static const Color secondaryText = Color(0xFF8A8A8F);
  static const Color whiteText = Colors.white;
  static const Color timeStampText = Color(0xFF8E8E93);
  static const Color onlineStatusText = Color(0xFF8E8E93);
  
  // Avatar colors
  static const Color avatarBackground1 = Color(0xFF7CFC00); // Green for "ВВ" avatar
  static const Color avatarBackground2 = Color(0xFFFF6347); // Red-orange for "СА" and "АЖ" avatars
  static const Color avatarBackground3 = Color(0xFF1E90FF); // Blue for "ПЖ" avatar
  static const Color avatarText = Colors.white;
  
  // Dividers and separators
  static const Color divider = Color(0xFFE5E5EA);
  static const Color dateSeparator = Color(0xFFE5E5EA);
  static const Color dateSeparatorText = Color(0xFF8E8E93);
  
  // Status indicators
  static const Color onlineStatus = Color(0xFF8E8E93);
  static const Color messageDelivered = Color(0xFF7CFC00);
  
  // Icon colors
  static const Color iconPrimary = Color(0xFF000000);
  static const Color iconSecondary = Color(0xFF8E8E93);
  static const Color backButton = Color(0xFF007AFF);
  static const Color attachButton = Color(0xFF8E8E93);
  static const Color micButton = Color(0xFF8E8E93);
}