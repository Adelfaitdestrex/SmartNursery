import 'package:flutter/material.dart';

void main() {
  runApp(const SchoolCommentsApp());
}

class SchoolCommentsApp extends StatelessWidget {
  const SchoolCommentsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // 🔴 enlève le mot DEBUG
      title: 'School Comments',
      theme: ThemeData(
        fontFamily: 'Plus Jakarta Sans',
        primaryColor: const Color(0xFF005224),
      ),
      home: const CommentsPage(),
    );
  }
}

class Comment {
  final String name;
  final String role;
  final String pic;
  String time;
  String text;
  bool liked;
  List<Comment> replies;

  Comment({
    required this.name,
    required this.role,
    required this.pic,
    required this.time,
    required this.text,
    this.liked = false,
    List<Comment>? replies,
  }) : replies = replies ?? [];
}

class CommentsPage extends StatefulWidget {
  const CommentsPage({super.key});

  @override
  State<CommentsPage> createState() => _CommentsPageState();
}

class _CommentsPageState extends State<CommentsPage> {
  final List<Comment> comments = [
    Comment(
      name: "Mme Sophie",
      role: "ENSEIGNANT",
      pic: "assets/images/sophie.png",
      time: "il y a 2h",
      text:
          "La sortie au jardin botanique a été un franc succès ! Merci à tous les parents accompagnateurs pour leur aide précieuse.",
    ),
    Comment(
      name: "Mr. Dupont",
      role: "ENSEIGNANT",
      pic: "assets/images/dupont.png",
      time: "il y a 10min",
      text:
          "Les projets de fin de trimestre avancent bien. N’oubliez pas que la présentation orale aura lieu mardi prochain.",
    ),
  ];

  final TextEditingController controller = TextEditingController();
  Comment? replyingTo;

  void addComment(String text, Comment? replyTo) {
    if (text.isEmpty) return;
    setState(() {
      if (replyTo == null) {
        comments.add(
          Comment(
            name: "Vous",
            role: "PARENT",
            pic: "assets/images/marc.png",
            time: "maintenant",
            text: text,
          ),
        );
      } else {
        replyTo.replies.add(
          Comment(
            name: "Vous",
            role: "PARENT",
            pic: "assets/images/marc.png",
            time: "maintenant",
            text: text,
          ),
        );
      }
    });
    controller.clear();
    replyingTo = null;
  }

  void toggleLike(Comment comment) {
    setState(() {
      comment.liked = !comment.liked;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F6),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAF9F6),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Color(0xFF005224),
          ), // 🔙 flèche retour
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          "Commentaires",
          style: TextStyle(
            color: Color(0xFF005224),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: comments.length,
              itemBuilder: (context, index) {
                final c = comments[index];
                return CommentCard(
                  comment: c,
                  onLike: () => toggleLike(c),
                  onReply: () {
                    setState(() {
                      replyingTo = c;
                    });
                  },
                );
              },
            ),
          ),
          CommentInputBar(
            controller: controller,
            replyTo: replyingTo,
            onSend: (text) => addComment(text, replyingTo),
          ),
        ],
      ),
    );
  }
}

/// Comment Card with nested replies
class CommentCard extends StatelessWidget {
  final Comment comment;
  final VoidCallback onLike;
  final VoidCallback onReply;

  const CommentCard({
    super.key,
    required this.comment,
    required this.onLike,
    required this.onReply,
  });

  @override
  Widget build(BuildContext context) {
    final isTeacher = comment.role == "ENSEIGNANT";
    final roleBg = isTeacher
        ? const Color(0xFF9DF898)
        : const Color(0xFF005EAE);
    final roleColor = isTeacher
        ? const Color(0xFF1A7425)
        : const Color(0xFFC2D9FF);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(backgroundImage: AssetImage(comment.pic)),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          comment.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: roleBg,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            comment.role,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: roleColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      comment.time,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              comment.text,
              style: const TextStyle(fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                IconButton(
                  icon: Icon(
                    comment.liked ? Icons.favorite : Icons.favorite_border,
                    size: 16,
                    color: comment.liked ? Colors.red : Colors.black54,
                  ),
                  onPressed: onLike,
                ),
                Text(comment.liked ? "1" : "0"),
                const SizedBox(width: 16),
                TextButton.icon(
                  onPressed: onReply,
                  icon: const Icon(
                    Icons.reply,
                    size: 16,
                    color: Colors.black54,
                  ),
                  label: const Text(
                    "Répondre",
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            if (comment.replies.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(left: 32, top: 8),
                child: Column(
                  children: comment.replies
                      .map(
                        (r) => CommentCard(
                          comment: r,
                          onLike: () => onLike(),
                          onReply: onReply,
                        ),
                      )
                      .toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Input bar
class CommentInputBar extends StatelessWidget {
  final TextEditingController controller;
  final void Function(String text) onSend;
  final Comment? replyTo;

  const CommentInputBar({
    super.key,
    required this.controller,
    required this.onSend,
    this.replyTo,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      color: const Color.fromRGBO(244, 244, 241, 0.8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: replyTo == null
                    ? "Écrire un commentaire…"
                    : "Répondre à ${replyTo!.name}…",
                border: InputBorder.none,
              ),
            ),
          ),
          GestureDetector(
            onTap: () => onSend(controller.text),
            child: Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: Color(0xFF005224),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.send, color: Colors.white, size: 18),
            ),
          ),
        ],
      ),
    );
  }
}
