import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:hellochickgu/shared/utils/responsive.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Deterministic avatar color from a string (e.g., userId)
Color _colorFromString(String input) {
  int hash = 0;
  for (int i = 0; i < input.length; i++) {
    hash = input.codeUnitAt(i) + ((hash << 5) - hash);
  }
  final int r = (hash & 0xFF0000) >> 16;
  final int g = (hash & 0x00FF00) >> 8;
  final int b = (hash & 0x0000FF);
  return Color.fromARGB(255, 150 + (r % 105), 120 + (g % 120), 120 + (b % 120));
}

// Simple time-ago formatter
String _formatTimeAgo(DateTime? date) {
  if (date == null) return 'just now';
  final Duration diff = DateTime.now().difference(date);
  if (diff.inSeconds < 60) return 'just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
  if (diff.inHours < 24) return '${diff.inHours}h ago';
  if (diff.inDays < 7) return '${diff.inDays}d ago';
  final weeks = (diff.inDays / 7).floor();
  if (weeks < 5) return '${weeks}w ago';
  final months = (diff.inDays / 30).floor();
  if (months < 12) return '${months}mo ago';
  final years = (diff.inDays / 365).floor();
  return '${years}y ago';
}

class CommunityPage extends StatefulWidget {
  const CommunityPage({super.key});

  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  Future<void> _showCreatePostScreen() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreatePostScreen()),
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = Responsive.isSmallScreen(context);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          'Community',
          style: TextStyle(
            fontSize: Responsive.scaleFont(context, 20),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream:
            FirebaseFirestore.instance
                .collection('posts')
                .orderBy('created_at', descending: true)
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Failed to load posts'));
          }
          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return const Center(child: Text('No posts yet. Be the first!'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data();
              final post = Post(
                id: docs[index].id,
                userId: data['user_id'] as String? ?? '',
                username: data['username'] as String? ?? 'User',
                avatarColor: _colorFromString(data['user_id'] as String? ?? ''),
                timeAgo: _formatTimeAgo(
                  (data['created_at'] as Timestamp?)?.toDate(),
                ),
                content: data['content'] as String? ?? '',
                image: data['image'] as String?,
                likes: (data['likes'] as num?)?.toInt() ?? 0,
                isLiked: ((data['liked_by'] as List?)?.cast<String>() ??
                        const <String>[])
                    .contains(FirebaseAuth.instance.currentUser?.uid),
                comments: <Comment>[],
                timestamp:
                    (data['created_at'] as Timestamp?)?.toDate() ??
                    DateTime.now(),
              );
              return PostCard(post: post);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreatePostScreen,
        backgroundColor: Theme.of(context).colorScheme.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Icon(
          Icons.add_rounded,
          color: Theme.of(context).colorScheme.onPrimary,
          size: 32,
        ),
      ),
    );
  }
}

class PostCard extends StatefulWidget {
  final Post post;

  const PostCard({super.key, required this.post});

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  late Post post;
  final TextEditingController _commentController = TextEditingController();
  String? _commentImage; // stores base64 or path
  bool _showComments = false;

  @override
  void initState() {
    super.initState();
    post = widget.post;
  }

  Future<void> _pickCommentImage() async {
    // Lightweight picker using ImagePicker; returns XFile bytes -> base64
    try {
      // Defer import locally to avoid top-level dependency in this file section
      // ignore: avoid_dynamic_calls
      final picker = await _loadPicker();
      final xfile = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      if (xfile == null) return;
      final bytes = await xfile.readAsBytes();
      final encoded = base64Encode(bytes);
      setState(() {
        _commentImage = 'data:image/jpeg;base64,$encoded';
      });
    } catch (_) {
      // Ignore picker errors for now
    }
  }

  Future<ImagePicker> _loadPicker() async {
    // Import deferred to keep file header minimal
    return ImagePicker();
  }

  void _toggleLike() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || post.id == null) return;
    setState(() {
      post.isLiked = !post.isLiked;
      post.likes += post.isLiked ? 1 : -1;
    });
    final ref = FirebaseFirestore.instance.collection('posts').doc(post.id);
    FirebaseFirestore.instance.runTransaction((txn) async {
      final snap = await txn.get(ref);
      final data = snap.data() as Map<String, dynamic>? ?? {};
      final likedBy = (data['liked_by'] as List?)?.cast<String>() ?? <String>[];
      if (likedBy.contains(user.uid)) {
        likedBy.remove(user.uid);
        txn.update(ref, {
          'liked_by': likedBy,
          'likes': FieldValue.increment(-1),
        });
      } else {
        likedBy.add(user.uid);
        txn.update(ref, {
          'liked_by': likedBy,
          'likes': FieldValue.increment(1),
        });
      }
    });
  }

  void _toggleComments() {
    setState(() {
      _showComments = !_showComments;
    });
  }

  void _addComment() {
    if (_commentController.text.isNotEmpty || _commentImage != null) {
      setState(() {
        post.comments.add(
          Comment(
            username: 'You',
            avatarColor: Colors.orange[300]!,
            content: _commentController.text,
            image: _commentImage,
          ),
        );
      });
      _commentController.clear();
      _commentImage = null;
    }
  }

  Widget _buildImage(String value) {
    if (value.startsWith('data:image')) {
      return Image.memory(
        base64Decode(value.split(',')[1]),
        height: 160,
        fit: BoxFit.cover,
      );
    }
    if (value.startsWith('http')) {
      return Image.network(value, height: 160, fit: BoxFit.cover);
    }
    return Image.asset(value, height: 160, fit: BoxFit.cover);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: CircleAvatar(
              backgroundColor: post.avatarColor,
              radius: 24,
              child: Text(
                post.username[0],
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(
              post.username,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              post.timeAgo,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).hintColor,
              ),
            ),
            trailing: _PostMenu(
              postId: post.id,
              ownerUserId: post.userId,
              onDeleted: () {
                if (!mounted) return;
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Post deleted')));
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              post.content,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          if (post.image != null)
            Container(
              height: 200,
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                image: DecorationImage(
                  image:
                      post.image!.startsWith('data:image')
                          ? MemoryImage(base64Decode(post.image!.split(',')[1]))
                          : post.image!.startsWith('http')
                          ? NetworkImage(post.image!) as ImageProvider
                          : AssetImage(post.image!) as ImageProvider,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _ActionButton(
                  icon: post.isLiked ? Icons.favorite : Icons.favorite_border,
                  label: '${post.likes}',
                  onTap: _toggleLike,
                  iconColor:
                      post.isLiked ? Colors.red : Theme.of(context).hintColor,
                ),
                const SizedBox(width: 24),
                _ActionButton(
                  icon: Icons.chat_bubble_outline,
                  label: '${post.comments.length}',
                  onTap: _toggleComments,
                ),
              ],
            ),
          ),
          if (_showComments) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...post.comments.map(
                    (comment) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            backgroundColor: comment.avatarColor,
                            radius: 16,
                            child: Text(
                              comment.username[0],
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: Colors.white),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "${comment.username}: ${comment.content}",
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                                if (comment.image != null) ...[
                                  const SizedBox(height: 8),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: _buildImage(comment.image!),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_commentImage != null) ...[
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: _buildImage(_commentImage!),
                        ),
                        const SizedBox(height: 8),
                      ],
                      Row(
                        children: [
                          IconButton(
                            tooltip: 'Attach image',
                            icon: const Icon(Icons.image_outlined),
                            onPressed: _pickCommentImage,
                          ),
                          Expanded(
                            child: TextField(
                              controller: _commentController,
                              decoration: const InputDecoration(
                                hintText: 'Add a comment...',
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.send_rounded),
                            color: Theme.of(context).colorScheme.primary,
                            onPressed: _addComment,
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? iconColor;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, size: 24, color: iconColor ?? Colors.grey[600]),
          const SizedBox(width: 4),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _PostMenu extends StatelessWidget {
  const _PostMenu({
    required this.postId,
    required this.ownerUserId,
    required this.onDeleted,
  });

  final String? postId;
  final String ownerUserId;
  final VoidCallback onDeleted;

  @override
  Widget build(BuildContext context) {
    final current = FirebaseAuth.instance.currentUser;
    final canDelete = current != null && current.uid == ownerUserId;
    if (!canDelete) return const SizedBox.shrink();

    return PopupMenuButton<String>(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onSelected: (value) async {
        if (value == 'delete' && postId != null) {
          final confirm = await showDialog<bool>(
            context: context,
            builder:
                (context) => AlertDialog(
                  title: const Text('Delete post?'),
                  content: const Text('This action cannot be undone.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Delete'),
                    ),
                  ],
                ),
          );
          if (confirm == true) {
            try {
              await FirebaseFirestore.instance
                  .collection('posts')
                  .doc(postId)
                  .delete();
              onDeleted();
            } catch (e) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('Delete failed: $e')));
            }
          }
        }
      },
      itemBuilder:
          (context) => [
            const PopupMenuItem<String>(value: 'delete', child: Text('Delete')),
          ],
      icon: const Icon(Icons.more_vert),
    );
  }
}

class Post {
  String? id;
  String userId;
  String username;
  Color avatarColor;
  String timeAgo;
  String content;
  String? image;
  int likes;
  bool isLiked;
  List<Comment> comments;
  DateTime timestamp;

  Post({
    this.id,
    required this.userId,
    required this.username,
    required this.avatarColor,
    required this.timeAgo,
    required this.content,
    this.image,
    required this.likes,
    required this.isLiked,
    required this.comments,
    required this.timestamp,
  });
}

class Comment {
  String username;
  Color avatarColor;
  String content;
  String? image; // base64, http, or asset path

  Comment({
    required this.username,
    required this.avatarColor,
    required this.content,
    this.image,
  });
}

// Dummy data
final List<Post> dummyPosts = [];

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final TextEditingController _postController = TextEditingController();
  String? _attachedImageBase64;
  String? _currentUsername;

  @override
  void initState() {
    super.initState();
    _loadCurrentUsername();
  }

  Future<void> _loadCurrentUsername() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    String username = user.displayName ?? 'User';
    try {
      final snap =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();
      final data = snap.data() as Map<String, dynamic>?;
      if ((data?['username'] as String?)?.trim().isNotEmpty == true) {
        username = (data!['username'] as String).trim();
      }
    } catch (_) {}
    if (mounted) setState(() => _currentUsername = username);
  }

  Future<void> _createPost() async {
    if (_postController.text.trim().isEmpty) return;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // Fetch username from users collection
    String username = user.displayName ?? 'User';
    try {
      final doc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();
      final data = doc.data() as Map<String, dynamic>?;
      username =
          (data?['username'] as String?)?.trim().isNotEmpty == true
              ? data!['username'] as String
              : (user.displayName ?? 'User');
    } catch (_) {}

    final payload = <String, dynamic>{
      'user_id': user.uid,
      'username': username,
      'content': _postController.text.trim(),
      'image': _attachedImageBase64, // store small base64 or remote URL later
      'likes': 0,
      'liked_by': <String>[],
      'created_at': FieldValue.serverTimestamp(),
    };

    await FirebaseFirestore.instance.collection('posts').add(payload);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        elevation: 0,
        leadingWidth: 72,
        leading: TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel', style: Theme.of(context).textTheme.labelLarge),
        ),
        centerTitle: true,
        title: const Text('New Post'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilledButton(
              onPressed:
                  _postController.text.trim().isEmpty ? null : _createPost,
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                disabledBackgroundColor: Theme.of(context).disabledColor,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text('Post'),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: _colorFromString(
                    FirebaseAuth.instance.currentUser?.uid ?? 'user',
                  ),
                  radius: 20,
                  child: Text(
                    (_currentUsername ?? 'User').isNotEmpty
                        ? (_currentUsername ?? 'U').characters.first
                            .toUpperCase()
                        : 'U',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _currentUsername ?? 'User',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: TextField(
                controller: _postController,
                maxLines: null,
                expands: true,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(
                  hintText: 'What do you want to ask?',
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                IconButton(
                  tooltip: 'Attach image',
                  icon: const Icon(Icons.image_outlined),
                  onPressed: () async {
                    try {
                      final picker = ImagePicker();
                      final xfile = await picker.pickImage(
                        source: ImageSource.gallery,
                        imageQuality: 80,
                      );
                      if (xfile == null) return;
                      final bytes = await xfile.readAsBytes();
                      setState(() {
                        _attachedImageBase64 =
                            'data:image/jpeg;base64,' + base64Encode(bytes);
                      });
                    } catch (_) {}
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _IconAction extends StatelessWidget {
  final IconData icon;

  const _IconAction({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(icon, color: Theme.of(context).hintColor),
    );
  }
}
