
class UserUpdatedResponse {

  final bool resp;
  final String msg;
  final UserUpdated user;

  UserUpdatedResponse({
    required this.resp,
    required this.msg,
    required this.user,
  });

  factory UserUpdatedResponse.fromJson(Map<String, dynamic> json) => UserUpdatedResponse(
    resp: json["resp"],
    msg: json["msg"],
    user: UserUpdated.fromJson(json["user"]),
  );
}

class UserUpdated {

  final String name;
  final String image;
  final String email;
  final int rolId;
  final String? address;
  final String? reference;

  UserUpdated({
    required this.name,
    required this.image,
    required this.email,
    required this.rolId,
    this.address,
    this.reference
  });

  factory UserUpdated.fromJson(Map<String, dynamic> json) => UserUpdated(
    name: json["name"],
    image: json["image"],
    email: json["email"],
    rolId: json["rol_id"],
    address: json["address"],
    reference: json["reference"]
  );
}
