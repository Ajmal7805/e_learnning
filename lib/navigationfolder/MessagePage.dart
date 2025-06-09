import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CourseScreen extends StatelessWidget {
  const CourseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top bar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Course",
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    CircleAvatar(
                      backgroundColor: Colors.grey.shade300,
                      child: Icon(Icons.person),
                    ),
                  ],
                ),
                SizedBox(height: 20),

                // Search bar (UI only)
                TextField(
                  decoration: InputDecoration(
                    hintText: "Find Course",
                    prefixIcon: Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                SizedBox(height: 20),

                // Categories
             
                SizedBox(height: 20),

                // Tab bar
                TabBar(
                  labelColor: Colors.blue,
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: Colors.blue,
                  tabs: [
                    Tab(text: "All"),
                    Tab(text: "Popular"),
                    Tab(text: "New"),
                  ],
                ),
                SizedBox(height: 10),

                // TabBarView with Firestore data
                Expanded(
                  child: TabBarView(
                    children: [
                      CourseListView(),
                      CourseListView(),
                      CourseListView(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CategoryCard extends StatelessWidget {
  final String title;
  final Color color;

  const CategoryCard({
    super.key,
    required this.title,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          title,
          style: TextStyle(color: color, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

class CourseListView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('courses')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting)
          return Center(child: CircularProgressIndicator());

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty)
          return Center(child: Text("No courses available"));

        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            var course = snapshot.data!.docs[index];
            String title = course['title'];
            String author = course['author'];
            String duration = course['duration'];
            String category = course['category'];
            String youtubeId = course['youtubeId'];

            return CourseCard(
              title: title,
              author: author,
              duration: duration,
              category: category,
              youtubeId: youtubeId,
            );
          },
        );
      },
    );
  }
}

class CourseCard extends StatelessWidget {
  final String title;
  final String author;
  final String duration;
  final String category;
  final String youtubeId;

  const CourseCard({
    super.key,
    required this.title,
    required this.author,
    required this.duration,
    required this.category,
    required this.youtubeId,
  });

  @override
  Widget build(BuildContext context) {
    String thumbnailUrl = "https://img.youtube.com/vi/$youtubeId/0.jpg";

    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              thumbnailUrl,
              height: 50,
              width: 50,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 50,
                width: 50,
                color: Colors.grey.shade300,
                child: Icon(Icons.broken_image, color: Colors.grey),
              ),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                SizedBox(height: 4),
                Text("By $author • $category",
                    style: TextStyle(color: Colors.grey, fontSize: 12)),
                SizedBox(height: 4),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(duration,
                      style: TextStyle(color: Colors.orange, fontSize: 12)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
