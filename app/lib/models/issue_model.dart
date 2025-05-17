class Issue {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final double latitude;
  final double longitude;
  final String userId;
  final DateTime createdAt;
  final String status;

  Issue({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.latitude,
    required this.longitude,
    required this.userId,
    required this.createdAt,
    required this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'latitude': latitude,
      'longitude': longitude,
      'userId': userId,
      'createdAt': createdAt.toIso8601String(),
      'status': status,
    };
  }

  factory Issue.fromMap(Map<String, dynamic> map) {
    return Issue(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      imageUrl: map['imageUrl'],
      latitude: map['latitude'],
      longitude: map['longitude'],
      userId: map['userId'],
      createdAt:
          map['createdAt'] is DateTime
              ? map['createdAt']
              : DateTime.parse(map['createdAt']),
      status: map['status'],
    );
  }
}
