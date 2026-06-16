class Role {
    String id;
    String name;
    String image;
    String route;

    Role({
        required this.id,
        required this.name,
        required this.image,
        required this.route,
    });

    factory Role.fromJson(Map<String, dynamic> json) => Role(
        id: json["id"]?.toString() ?? '',
        name: json["name"]?.toString() ?? '',
        image: json["image"]?.toString() ?? '',
        route: json["route"]?.toString() ?? '',
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "image": image,
        "route": route,
    };
}
