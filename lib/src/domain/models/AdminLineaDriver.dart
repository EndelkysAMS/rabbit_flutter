class AdminLineaDriver {
  final int id;
  final String name;
  final String lastname;
  final String email;
  final String phone;
  final String? image;
  final bool isActive;
  final AdminLineaLine? line;
  final List<String> roles;

  const AdminLineaDriver({
    required this.id,
    required this.name,
    required this.lastname,
    required this.email,
    required this.phone,
    this.image,
    required this.isActive,
    this.line,
    this.roles = const [],
  });

  factory AdminLineaDriver.fromJson(Map<String, dynamic> json) {
    int toInt(dynamic value, {int fallback = 0}) {
      if (value is int) return value;
      return int.tryParse(value?.toString() ?? '') ?? fallback;
    }

    bool toBool(dynamic value, {bool fallback = true}) {
      if (value is bool) return value;
      final str = value?.toString().toLowerCase();
      if (str == 'true' || str == '1') return true;
      if (str == 'false' || str == '0') return false;
      return fallback;
    }

    return AdminLineaDriver(
      id: toInt(json['id']),
      name: json['name']?.toString() ?? '',
      lastname: json['lastname']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      image: json['image']?.toString(),
      isActive: toBool(json['is_active']),
      line: json['line'] is Map<String, dynamic>
          ? AdminLineaLine.fromJson(json['line'])
          : null,
      roles: (json['roles'] as List?)
              ?.map((e) => e?.toString() ?? '')
              .where((e) => e.isNotEmpty)
              .toList() ??
          [],
    );
  }
}

class AdminLineaLine {
  final int id;
  final String name;

  const AdminLineaLine({
    required this.id,
    required this.name,
  });

  factory AdminLineaLine.fromJson(Map<String, dynamic> json) {
    return AdminLineaLine(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      name: json['name']?.toString() ?? '',
    );
  }
}

