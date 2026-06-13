class AdminLineaProfile {
  final String name;
  final String lastname;
  final String phone;
  final String? image;

  const AdminLineaProfile({
    required this.name,
    required this.lastname,
    required this.phone,
    this.image,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'lastname': lastname,
        'phone': phone,
        'image': image,
      };
}

