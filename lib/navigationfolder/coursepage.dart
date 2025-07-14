import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_learnning/screens/CourseDetailsPage.dart';

class CourseScreen extends StatefulWidget {
  const CourseScreen({super.key});

  @override
  State<CourseScreen> createState() => _CourseScreenState();
}

class _CourseScreenState extends State<CourseScreen> {
  final TextEditingController _searchController = TextEditingController();
  String searchQuery = "";

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                
                // Top Bar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Courses",
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                   
                  ],
                ),
                
                const SizedBox(height: 20),

                // Search Bar
                TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value.trim().toLowerCase();
                    });
                  },
                  decoration: InputDecoration(
                    hintText: "Find Course",
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Tabs
                const TabBar(
                  labelColor: Colors.blue,
                  unselectedLabelColor: Colors.black54,
                  indicatorColor: Colors.blue,
                  tabs: [
                    Tab(text: "All Courses"),
                    Tab(text: "Popular"),
                    Tab(text: "New"),
                  ],
                ),
                const SizedBox(height: 10),

                // Tab Views
                Expanded(
                  child: TabBarView(
                    children: [
                      CourseListView(searchQuery: searchQuery),
                      Center(child: const Text("Popular Courses (Coming Soon)")),
                      const RecentCoursesView(),
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

// All Courses Tab
class CourseListView extends StatelessWidget {
  final String searchQuery;
  const CourseListView({super.key, required this.searchQuery});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('courses')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("No courses available"));
        }

        final filteredCourses = snapshot.data!.docs.where((doc) {
          var data = doc.data() as Map<String, dynamic>;
          String title = data['courseName']?.toLowerCase() ?? '';
          return title.contains(searchQuery);
        }).toList();

        if (filteredCourses.isEmpty) {
          return const Center(child: Text("No matching courses found"));
        }

        return ListView.builder(
          itemCount: filteredCourses.length,
          itemBuilder: (context, index) {
            var course = filteredCourses[index].data() as Map<String, dynamic>;
            return CourseCard.fromMap(course);
          },
        );
      },
    );
  }
}



// Recent Courses Tab (last 7 days)
class RecentCoursesView extends StatelessWidget {
  const RecentCoursesView({super.key});

  @override
  Widget build(BuildContext context) {
    final lastWeek = DateTime.now().subtract(const Duration(days: 7));

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('courses')
          .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(lastWeek))
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("No new courses this week"));
        }

        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            var course = snapshot.data!.docs[index].data() as Map<String, dynamic>;
            return CourseCard.fromMap(course);
          },
        );
      },
    );
  }
}

// Reusable Course Card
class CourseCard extends StatelessWidget {
  final String title;
  final String author;
  final String duration;
  final String thumbnailUrl;
  final String courseId;
  final String description;
  final bool itsstarted;

  const CourseCard({
    super.key,
    required this.title,
    required this.author,
    required this.duration,
    required this.thumbnailUrl,
    required this.courseId,
    required this.description, required this.itsstarted,
  });

  factory CourseCard.fromMap(Map<String, dynamic> course) {
    String title = course['courseName'] ?? "No title";
    String author = course['authorName'] ?? "Unknown author";
    String duration = course['totalDuration'] ?? "Unknown duration";
    String courseId = course['courseId'] ?? "";
    String youtubeId = course['youtubeId'] ?? "";
    String description = course['courseDescription'] ?? "";
    bool isfree =course['islocked'] ?? false;

    String thumbnailUrl = youtubeId.isNotEmpty
        ? 'https://img.youtube.com/vi/$youtubeId/hqdefault.jpg'
        : 'https://via.placeholder.com/150';

    return CourseCard(
      itsstarted: isfree,
      title: title,
      author: author,
      duration: duration,
      thumbnailUrl: thumbnailUrl,
      courseId: courseId,
      description: description,
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CourseDetailsPage(
              itsstarted:itsstarted ,
              
              description: description,
              author: author,
              duration: duration,
              thumbnailUrl: thumbnailUrl,
              title: title,
              courseId: courseId,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade200,
              blurRadius: 6,
              offset: const Offset(0, 3),
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
                  child: const Icon(Icons.broken_image, color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 4),
                  Text(author,
                      style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  const SizedBox(height: 4),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(duration,
                        style: const TextStyle(
                            color: Colors.orange, fontSize: 12)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
