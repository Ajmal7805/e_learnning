import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_learnning/homescreen/CoursePlayerPage.dart';
import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';

class CourseDetailsPage extends StatefulWidget {
  final String title;
  final String author;
  final String duration;
  final String thumbnailUrl;
  final String courseId;
  final String description;
  final bool itsstarted;

  const CourseDetailsPage({
    super.key,
    required this.title,
    required this.author,
    required this.duration,
    required this.thumbnailUrl,
    required this.courseId,
    required this.description,
    required this.itsstarted,
  });

  @override
  State<CourseDetailsPage> createState() => _CourseDetailsPageState();
}

class _CourseDetailsPageState extends State<CourseDetailsPage> {
  List<Map<String, dynamic>> lessons = [];
  bool isLoading = true;
  late bool hasStarted;
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    hasStarted = !widget.itsstarted; // If false, already started
    fetchLessons();
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  Future<void> fetchLessons() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('courses')
          .doc(widget.courseId)
          .collection('lessons')
          .orderBy('createdAt')
          .get();

      setState(() {
        lessons = snapshot.docs.map((doc) => doc.data()).toList();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print("Error fetching lessons: $e");
    }
  }

  Future<void> startCourse() async {
    try {
      await FirebaseFirestore.instance
          .collection('courses')
          .doc(widget.courseId)
          .update({'islocked': false});

      setState(() {
        hasStarted = true;
      });

      _confettiController.play();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('🎉 Course "${widget.title}" started!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print("Error updating Firestore: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDECEF),
      body: Stack(
        children: [
          Column(
            children: [
              // Top Banner
              Container(
                padding: const EdgeInsets.all(10),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    widget.thumbnailUrl,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 180,
                      color: Colors.grey.shade300,
                      child: const Icon(Icons.broken_image),
                    ),
                  ),
                ),
              ),

              // Content
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: const BoxDecoration(color: Colors.white),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        Text("${widget.duration} • ${lessons.length} Lessons"),
                        const SizedBox(height: 10),
                        const Text("About this course", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        Text(widget.description, style: const TextStyle(color: Colors.black54)),
                        const SizedBox(height: 20),
                        const Text("Lessons", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : Column(
                                children: lessons.asMap().entries.map((entry) {
                                  int index = entry.key;
                                  var lesson = entry.value;
                                  return LessonTile(
                                    isCourseStarted: hasStarted,
                                    index: index + 1,
                                    title: lesson['title'] ?? 'No title',
                                    duration: lesson['duration'] ?? '0:00',
                                    isLocked: lesson['isLocked'] ?? false,
                                    courseId: widget.courseId,
                                    courseTitle: lesson['title'] ?? 'No title',
                                    authorName: widget.author,
                                    courseDescription: widget.description,
                                    totalDuration: lesson['duration'] ?? '0:00',
                                    youtubeId: lesson['youtubeId'] ?? '',
                                  );
                                }).toList(),
                              ),
                        const SizedBox(height: 90),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              numberOfParticles: 20,
            ),
          ),
        ],
      ),

      // Bottom bar
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        color: Colors.white,
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.orange.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.all(10),
              child: const Icon(Icons.star_border, color: Colors.orange),
            ),
            const SizedBox(width: 10),
            !hasStarted
                ? Expanded(
                    child: ElevatedButton(
                      onPressed: startCourse,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('Start Course', style: TextStyle(color: Colors.white)),
                    ),
                  )
                : const SizedBox(),
          ],
        ),
      ),
    );
  }
}

class LessonTile extends StatelessWidget {
  final int index;
  final String title;
  final String duration;
  final bool isLocked;
  final bool isCourseStarted;
  final String courseId;
  final String courseTitle;
  final String authorName;
  final String courseDescription;
  final String totalDuration;
  final String youtubeId;

  const LessonTile({
    super.key,
    required this.index,
    required this.title,
    required this.duration,
    required this.isLocked,
    required this.isCourseStarted,
    required this.courseId,
    required this.courseTitle,
    required this.authorName,
    required this.courseDescription,
    required this.totalDuration,
    required this.youtubeId,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (!isCourseStarted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please start the course first!')),
          );
          return;
        }

        if (!isLocked) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CoursePlayerPage(
                courseId: courseId,
                courseTitle: courseTitle,
                authorName: authorName,
                courseDescription: courseDescription,
                totalDuration: totalDuration,
                youtubeId: youtubeId,
              ),
            ),
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Text(index.toString().padLeft(2, '0'),
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 2),
                  Text(duration,
                      style: TextStyle(fontSize: 12, color: isLocked ? Colors.grey : Colors.blue)),
                ],
              ),
            ),
            isLocked
                ? const Icon(Icons.lock, color: Colors.grey)
                : const Icon(Icons.play_circle_fill, color: Colors.blue),
          ],
        ),
      ),
    );
  }
}
