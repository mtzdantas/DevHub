import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';
import '../services/github_service.dart';
import '../models/repository.dart';
import 'dart:math';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GithubService _githubService = GithubService();
  late Future<Repository> _repositoryFuture;

  @override
  void initState() {
    super.initState();
    _repositoryFuture = _loadRandomRepository();
  }

  Future<Repository> _loadRandomRepository() async {
    List<String> following = await _githubService.fetchFollowing('mtzdantas');
    if (following.isNotEmpty) {
      Random random = Random();
      int randomIndex = random.nextInt(following.length);
      String randomUser = following[randomIndex];
      return await _githubService.fetchRandomRepository(randomUser);
    } else {
      throw Exception('No following found');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<Repository>(
          future: _repositoryFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData) {
              return Center(child: Text('No repository found'));
            }

            Repository repository = snapshot.data!;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
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
                          backgroundImage: NetworkImage(repository.avatar),
                        ),
                      ],
                    ),
                    SizedBox(width: 16.0),
                    Expanded(
                      child: SelectableText(
                        repository.login,
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.0),
                Divider(),
                SizedBox(height: 16.0),
                Row(
                  children: [
                    Icon(Icons.folder_copy_outlined, size: 25),
                    SizedBox(width: 5),
                    Text('${repository.name}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Spacer(),
                    IconButton(
                      icon: Icon(Icons.open_in_new, size: 25, color: Colors.grey),
                      onPressed: () {
                        _launchURL(repository.htmlUrl);
                      },
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Text('Description', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                SizedBox(height: 5.0),
                Text(repository.description, style: TextStyle(fontSize: 16)),
                SizedBox(height: 20.0),
                Row(
                  children: [
                    Icon(Icons.code, size: 25),
                    SizedBox(width: 5),
                    Text('${repository.language}'),
                    Spacer(),
                    Icon(Icons.star, size: 25),
                    SizedBox(width: 5),
                    Text('${repository.stars} stars'),
                  ],
                ),
                Spacer(),
                TextButton.icon(
                  icon: Icon(Icons.drive_folder_upload, size: 25),
                  label: Text(
                    'Git Clone',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  onPressed: () => _copyToClipboard(repository.cloneUrl),
                ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _refreshRepository,
        child: Icon(Icons.refresh),
      ),
    );
  }

  void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  void _copyToClipboard(String url) {
    Clipboard.setData(ClipboardData(text: url));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Clone URL copied to clipboard')),
    );
  }

  void _refreshRepository() {
    setState(() {
      _repositoryFuture = _loadRandomRepository();
    });
  }

}