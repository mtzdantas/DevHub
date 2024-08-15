import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/github_service.dart';
import '../models/repository.dart';

class RepositoriesScreen extends StatefulWidget {
  @override
  _RepositoriesScreenState createState() => _RepositoriesScreenState();
}

class _RepositoriesScreenState extends State<RepositoriesScreen> {
  final TextEditingController _controller = TextEditingController();
  final GithubService _githubService = GithubService();
  List<Repository> _searchResults = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: _controller,
            decoration: InputDecoration(
              hintText: 'Search repositories',
              suffixIcon: IconButton(
                icon: Icon(Icons.search),
                onPressed: () async {
                  setState(() {
                    _searchResults.clear();
                  });
                  List<Repository> results =
                      await _githubService.searchRepositories(_controller.text);
                  setState(() {
                    _searchResults = results;
                  });
                },
              ),
            ),
          ),
        ),
        Expanded(
          child: ListView.separated(
            itemCount: _searchResults.length,
            itemBuilder: (context, index) {
              var repo = _searchResults[index];
              return ListTile(
                dense: true,
                title: Text(repo.fullName, style: TextStyle(fontWeight: FontWeight.bold,),),
                subtitle: Text(repo.description ?? 'No description'),
                leading: CircleAvatar(
                  radius: 24.0,
                  backgroundImage: NetworkImage(repo.avatar),
                ),
                onTap: () {
                  _launchURL(repo.htmlUrl);
                },
              );
            },
            separatorBuilder: (context, index) {
              return Divider(
                color: Colors.grey,
                thickness: 1,
              );
            },
          ),
        ),
      ],
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