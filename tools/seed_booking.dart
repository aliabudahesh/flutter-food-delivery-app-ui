import 'dart:convert';
import 'dart:io';

/// Simple script that demonstrates how existing menu items could be migrated
/// into booking services by inferring duration from textual hints.
///
/// Usage:
/// ```
/// dart tools/seed_booking.dart <<<'[{"name":"Relax massage 60 min","price":280}]'
/// ```
void main(List<String> args) async {
  final StringBuffer buffer = StringBuffer();
  await stdin.transform(utf8.decoder).forEach(buffer.write);
  final List<dynamic> rawItems = jsonDecode(buffer.toString()) as List<dynamic>;
  final List<Map<String, dynamic>> services = rawItems.map((dynamic item) {
    final Map<String, dynamic> map = item as Map<String, dynamic>;
    final String name = map['name'] as String;
    final int inferredDuration = _inferDuration(name);
    return <String, dynamic>{
      'name': name,
      'duration_minutes': inferredDuration,
      'price': map['price'] ?? 0,
      'description': map['description'] ?? '',
    };
  }).toList();

  stdout.writeln(const JsonEncoder.withIndent('  ').convert(services));
}

int _inferDuration(String text) {
  final RegExp exp = RegExp(r'(\d{2,3})');
  final Match match = exp.firstMatch(text ?? '');
  if (match != null) {
    return int.parse(match.group(0));
  }
  return 60;
}
