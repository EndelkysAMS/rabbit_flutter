class AdminLineaCreateDriver {
  final String name;
  final String lastname;
  final String email;
  final String phone;
  final String password;
  final String? image;

  const AdminLineaCreateDriver({
    required this.name,
    required this.lastname,
    required this.email,
    required this.phone,
    required this.password,
    this.image,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'lastname': lastname,
        'email': email,
        'phone': phone,
        'password': password,
        'image': image,
      };
}

