import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/post_service.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PostService _postService = PostService();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Anonymous Posts'),
        leading: IconButton(
          icon: Icon(Icons.menu),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text('Home'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.person),
              title: Text('Profile'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/profile');
              },
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Settings'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.exit_to_app),
              title: Text('Logout'),
              onTap: () async {
                await context.read<AuthService>().signOut();
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: StreamBuilder<List<Post>>(
        stream: _postService.getPosts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No posts yet. Be the first to post!'));
          }
          
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              Post post = snapshot.data![index];
              return Card(
                margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Anonymous User',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(post.content),
                      SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Posted on: ${post.timestamp.day}/${post.timestamp.month}/${post.timestamp.year}',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: Icon(Icons.thumb_up_outlined),
                                onPressed: () {
                                  _postService.upvotePost(post.id);
                                },
                              ),
                              Text('${post.upvotes}'),
                              SizedBox(width: 8),
                              IconButton(
                                icon: Icon(Icons.thumb_down_outlined),
                                onPressed: () {
                                  _postService.downvotePost(post.id);
                                },
                              ),
                              Text('${post.downvotes}'),
                            ],
                          ),
                        ],
                      ),
                      post.comments.isNotEmpty
                          ? ExpansionTile(
                              title: Text('Comments (${post.comments.length})'),
                              children: post.comments.map((comment) {
                                return ListTile(
                                  title: Text(comment),
                                );
                              }).toList(),
                            )
                          : SizedBox.shrink(),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/create_post');
        },
        tooltip: 'Create a post',
        child: Icon(Icons.add),
      ),
    );
  }
}
