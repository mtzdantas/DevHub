import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/repository.dart';
import '../models/user.dart';
import 'dart:math';

class GithubService {
  final String baseUrl = "https://api.github.com";

  Future<User> fetchUserDetails(String username) async {
    final response = await http.get(
      Uri.parse('$baseUrl/users/$username'),
    );

    if (response.statusCode == 200) {
      return User.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load user details');
    }
  }

  Future<List<Repository>> fetchRepositories(String username) async {
    final response = await http.get(
      Uri.parse('$baseUrl/users/$username/repos'),
    );

    if (response.statusCode == 200) {
      List<dynamic> body = json.decode(response.body);
      List<Repository> repositories = body.map((dynamic item) => Repository.fromJson(item)).toList();
      return repositories;
    } else {
      throw Exception('Failed to load repositories');
    }
  }

  Future<List<Repository>> searchRepositories(String query) async {
    String url = '$baseUrl/search/repositories?q=$query';

    try {
      var response = await http.get(
        Uri.parse(url),
      );
      if (response.statusCode == 200) {
        List<dynamic> body = json.decode(response.body)['items'];
        List<Repository> repositories = body.map((dynamic item) => Repository.fromJson(item)).toList();
        return repositories;
      } else {
        throw Exception('Failed to load repositories');
      }
    } catch (e) {
      throw Exception('Failed to connect to the API');
    }
  }

  Future<List<Repository>> getTop3Repositories(String username) async {
    final url = '$baseUrl/users/$username/repos';
    final response = await http.get(
      Uri.parse(url),
    );

    if (response.statusCode == 200) {
      List<dynamic> reposJson = json.decode(response.body);
      List<Repository> repos = reposJson.map((repoJson) => Repository.fromJson(repoJson)).toList();
      repos.sort((a, b) => b.stars.compareTo(a.stars));
      return repos.take(3).toList();
    } else {
      throw Exception('Erro ao carregar repositórios');
    }
  }

  Future<List<String>> fetchFollowing(String username) async {
    final response = await http.get(
      Uri.parse('$baseUrl/users/$username/following'),
    );

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((user) => user['login'].toString()).toList();
    } else {
      throw Exception('Failed to load following');
    }
  }

  Future<Repository> fetchRandomRepository(String username) async {
    final response = await http.get(
      Uri.parse('$baseUrl/users/$username/repos'),
    );

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      if (data.isNotEmpty) {
        Random random = Random();
        int randomIndex = random.nextInt(data.length);
        return Repository.fromJson(data[randomIndex]);
      } else {
        throw Exception('No repositories found for this user');
      }
    } else {
      throw Exception('Failed to load repositories');
    }
  }
}