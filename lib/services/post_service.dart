import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Post {
  final String id;
  final String content;
  final String userId;
  final DateTime timestamp;
  final int upvotes;
  final int downvotes;
  final List<String> comments;

  Post({
    required this.id,
    required this.content,
    required this.userId,
    required this.timestamp,
    required this.upvotes,
    required this.downvotes,
    required this.comments,
  });

  factory Post.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Post(
      id: doc.id,
      content: data['content'] ?? '',
      userId: data['userId'] ?? '',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      upvotes: data['upvotes'] ?? 0,
      downvotes: data['downvotes'] ?? 0,
      comments: List<String>.from(data['comments'] ?? []),
    );
  }
}

class PostService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Create a new post
  Future<void> createPost(String content) async {
    if (_auth.currentUser == null) return;
    
    await _firestore.collection('posts').add({
      'content': content,
      'userId': _auth.currentUser!.uid,
      'timestamp': Timestamp.now(),
      'upvotes': 0,
      'downvotes': 0,
      'comments': [],
    });
  }

  // Get stream of all posts
  Stream<List<Post>> getPosts() {
    return _firestore
        .collection('posts')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Post.fromFirestore(doc)).toList());
  }

  // Upvote a post
  Future<void> upvotePost(String postId) async {
    await _firestore.collection('posts').doc(postId).update({
      'upvotes': FieldValue.increment(1),
    });
  }

  // Downvote a post
  Future<void> downvotePost(String postId) async {
    await _firestore.collection('posts').doc(postId).update({
      'downvotes': FieldValue.increment(1),
    });
  }

  // Add comment to a post
  Future<void> addComment(String postId, String comment) async {
    await _firestore.collection('posts').doc(postId).update({
      'comments': FieldValue.arrayUnion([comment]),
    });
  }
}