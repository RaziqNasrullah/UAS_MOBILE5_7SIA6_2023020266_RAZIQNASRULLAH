/// Helper konversi nilai JSON yang aman (angka bisa datang sebagai String).
int asInt(dynamic v, [int fallback = 0]) {
  if (v is int) return v;
  if (v is num) return v.toInt();
  return int.tryParse(v?.toString() ?? '') ?? fallback;
}

double asDouble(dynamic v, [double fallback = 0]) {
  if (v is num) return v.toDouble();
  return double.tryParse(v?.toString() ?? '') ?? fallback;
}

String? asStringOrNull(dynamic v) {
  final s = v?.toString();
  return (s == null || s.isEmpty) ? null : s;
}

DateTime? asDate(dynamic v) =>
    v == null ? null : DateTime.tryParse(v.toString().replaceFirst(' ', 'T'));
