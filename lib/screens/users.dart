import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/github_service.dart';
import '../models/user.dart';
import '../models/repository.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final GithubService _githubService = GithubService();
  final TextEditingController _controller = TextEditingController();
  Future<User>? _futureUser;
  Future<List<Repository>>? _futureTopRepos;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          TextField(
            controller: _controller,
            decoration: InputDecoration(
              hintText: 'Enter GitHub username',
              suffixIcon: IconButton(
                icon: Icon(Icons.search),
                onPressed: () {
                  setState(() {
                    _futureUser = _githubService.fetchUserDetails(_controller.text);
                    _futureTopRepos = _githubService.getTop3Repositories(_controller.text);
                  });
                },
              ),
            ),
          ),
          SizedBox(height: 30),
          _futureUser == null
              ? Container()
              : FutureBuilder<User>(
                  future: _futureUser,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else if (!snapshot.hasData) {
                      return Text('No user found');
                    } else {
                      final user = snapshot.data!;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Stack(
                                alignment: Alignment.center,
                                children: [
                                  Container(
                                    width: 110,
                                    height: 110,
                                    decoration: BoxDecoration(
                                      color: Color.fromARGB(255, 24, 18, 71),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  CircleAvatar(
                                    radius: 50,
                                    backgroundImage: NetworkImage(user.avatarUrl),
                                  ),
                                ],
                              ),
                              Spacer(),
                              Column(
                                children: [
                                  Text('${user.repositories}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                  Text('Repositories', style: TextStyle(fontSize: 16)),
                                ],
                              ),
                              Spacer(),
                              Column(
                                children: [
                                  Text('${user.followers}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                  Text('Followers', style: TextStyle(fontSize: 16)),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(height: 15),
                          Text('${user.name}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          Row(
                            children: [
                              Icon(Icons.location_on, size: 20),
                              SizedBox(width: 5),
                              Text('${user.location ?? 'Not specified'}', style: TextStyle(fontSize: 17)),
                              Spacer(),
                              IconButton(
                                icon: Icon(
                                  Icons.open_in_new,
                                  size: 25,
                                  color: Colors.grey,
                                ),
                                onPressed: () {
                                  _launchURL(user.url);
                                },
                              ),
                            ],
                          ),
                          Divider(),
                          SizedBox(height: 10),
                          Row(
                            children: [
                              Icon(Icons.emoji_events_outlined, size: 30),
                              SizedBox(width: 5),
                              Text('Top Repositories', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),        
                            ],
                          ),
                          _buildTopRepositories(),
                        ],
                      );
                    }
                  },
                ),
        ],
      ),
    );
  }

  Widget _buildTopRepositories() {
    return FutureBuilder<List<Repository>>(
      future: _futureTopRepos,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Text('No top repositories found');
        } else {
          final repos = snapshot.data!;
          return Column(
            children: repos.map((repo) {
              return ListTile(
                title: Text(repo.name),
                subtitle: Row(
                            children: [
                              Icon(Icons.stars, size: 20),
                              Text('${repo.stars}'),   
                              SizedBox(width: 10),
                              Icon(Icons.fork_right, size: 20),
                              Text('${repo.forks}'),
                              SizedBox(width: 10),
                              Icon(Icons.chat, size: 20),
                              Text('${repo.issues}'),
                              Spacer(),
                              Icon(Icons.code, size: 20),
                              SizedBox(width: 5),
                              Text('${repo.language}'), 
                            ],
                          ),
              );
            }).toList(),
          );
        }
      },
    );
  }

  void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}