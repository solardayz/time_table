class User {
  int? id;
  final String name;
  User({this.id, required this.name});
  factory User.fromMap(Map<String, dynamic> map) => User(
    id: map['id'],
    name: map['name'],
  );
  Map<String, dynamic> toMap() => {
    'name': name,
    if (id != null) 'id': id,
  };
}
