class User {
  final String name;
  final String location;
  final int followers;
  final String url;
  final String avatarUrl;
  final int repositories;

  User({
    required this.name,
    required this.location,
    required this.followers,
    required this.url,
    required this.avatarUrl,
    required this.repositories,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      name: json['name'] ?? 'No name',
      location: json['location'] ?? 'No location',
      followers: json['followers'],
      url: json['html_url'],
      avatarUrl: json['avatar_url'],
      repositories: json['public_repos'],
    );
  }
}