class UserModel {
  final String id;
  final String email;
  final String? name;
  final int rewardCoins;

  UserModel({
    required this.id,
    required this.email,
    this.name,
    this.rewardCoins = 0,
  });

  Map<String, dynamic> toMap() {
    return {'id': id, 'email': email, 'name': name, 'rewardCoins': rewardCoins};
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'],
      email: map['email'],
      name: map['name'],
      rewardCoins: map['rewardCoins'] ?? 0,
    );
  }
}
