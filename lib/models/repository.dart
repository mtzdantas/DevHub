class Repository {
  final String name;
  final String description;
  final String htmlUrl;
  final String fullName;
  final String avatar;
  final int stars;
  final int forks;
  final String language;
  final int issues;
  final String login;
  final String cloneUrl;

  Repository({
    required this.name, 
    required this.description, 
    required this.htmlUrl,
    required this.fullName,  
    required this.avatar,
    required this.stars,
    required this.forks,
    required this.language,
    required this.issues,
    required this.login,
    required this.cloneUrl,
  });

  factory Repository.fromJson(Map<String, dynamic> json) {
    return Repository(
      name: json['name'],
      description: json['description'] ?? '',
      htmlUrl: json['html_url'],
      fullName: json['full_name'],
      avatar: json['owner']['avatar_url'],
      stars: json['stargazers_count'],
      forks: json['forks_count'],
      language: json['language'] ?? 'Unknown',
      issues: json['open_issues_count'],
      login: json['owner']['login'],
      cloneUrl: json['clone_url'],
    );
  }
}