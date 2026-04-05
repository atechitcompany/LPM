import 'package:flutter/material.dart';

// --- THEME COLORS ---
const kPrimaryYellow = Color(0xFFFDD835);
const kBackground = Color(0xFFF8F9FA);
const kBlueColor = Color(0xFF0056D2);
const kGreenColor = Color(0xFF1E8E3E);

// --- SAMPLE DATA ---
const sampleCompanies = [
  'A Tech IT Company',
  'A Tech Developer',
  'Laxmi Associates',
  'Future interior',
  'A Tech Education',
  'Other'
];
const sampleAddresses = ['Pune', 'Mumbai', 'Nashik', 'Nagpur', 'Other'];
const sampleLeadSources = ['Walk-in', 'Referral', 'Website', 'Instagram', 'Other'];

// --- HELPERS ---
String avatarChar(String? name) {
  if (name == null) return 'U';
  if (name.trim().isEmpty) return 'U';
  return name.trim()[0].toUpperCase();
}

class PhoneHelper {
  static const defaultCountryCode = '91';
  static String normalize(String? raw) {
    if (raw == null) return '';
    var p = raw.replaceAll(RegExp(r'[^0-9+]'), '');
    if (p.isEmpty) return '';
    if (p.startsWith('+')) p = p.substring(1);
    if (RegExp(r'^[0-9]{10}$').hasMatch(p)) p = defaultCountryCode + p;
    return p;
  }
  static Uri? whatsappUri(String? raw) {
    final p = normalize(raw);
    if (p.isEmpty) return null;
    return Uri.parse('https://wa.me/$p');
  }
  static Uri? telUri(String? raw) {
    final p = normalize(raw);
    if (p.isEmpty) return null;
    return Uri(scheme: 'tel', path: '+$p');
  }
}
