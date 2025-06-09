import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class CoursePlayerPage extends StatefulWidget {
  final String courseId;
  final String courseTitle;
  final String authorName;
  final String courseDescription;
  final String totalDuration;
  final String youtubeId;

  const CoursePlayerPage({
    super.key,
    required this.courseId,
    required this.courseTitle,
    required this.authorName,
    required this.courseDescription,
    required this.totalDuration,
    required this.youtubeId,
  });

  @override
  State<CoursePlayerPage> createState() => _CoursePlayerPageState();
}

class _CoursePlayerPageState extends State<CoursePlayerPage> {
  late YoutubePlayerController _youtubeController;
  List<Map<String, dynamic>> lessons = [];
  bool isLoading = true;
  int? playingIndex;

  String currentLessonTitle = '';
  String currentLessonDuration = '';

  @override
  void initState() {
    super.initState();
    _youtubeController = YoutubePlayerController(
      initialVideoId: widget.youtubeId,
      flags: const YoutubePlayerFlags(
        autoPlay: false,
        mute: false,
      ),
    );

    // Set default values for lesson title/duration
    currentLessonTitle = 'Course Preview';
    currentLessonDuration = widget.totalDuration;

    fetchLessons();
  }

  Future<void> fetchLessons() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection("courses")
          .doc(widget.courseId)
          .collection("lessons")
          .orderBy("createdAt")
          .get();

      setState(() {
        lessons = snapshot.docs.map((doc) => doc.data()).toList();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print("Error loading lessons: $e");
    }
  }

  @override
  void dispose() {
    _youtubeController.dispose();
    super.dispose();
  }

  void playLesson(int index) {
    final lesson = lessons[index];
    final lessonId = lesson['youtubeId'] ?? widget.youtubeId;
    final title = lesson['title'] ?? 'Untitled';
    final duration = lesson['duration'] ?? '0:00';

    _youtubeController.load(lessonId);

    setState(() {
      playingIndex = index;
      currentLessonTitle = title;
      currentLessonDuration = duration;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDECEF),
      body: YoutubePlayerBuilder(
        player: YoutubePlayer(
          controller: _youtubeController,
          showVideoProgressIndicator: true,
          progressColors: const ProgressBarColors(
            playedColor: Colors.orange,
            handleColor: Colors.orangeAccent,
          ),
        ),
        builder: (context, player) => Column(
          children: [
            player,

          

            Expanded(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                    currentLessonTitle,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                      const SizedBox(height: 4),
                      Text(
                        "$currentLessonDuration • ${lessons.length} Lessons",
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        widget.courseDescription.isNotEmpty
                            ? widget.courseDescription
                            : "No description available.",
                        style: const TextStyle(color: Colors.black54),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        "Lessons",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : lessons.isEmpty
                              ? const Center(child: Text("No lessons available"))
                              : Column(
                                  children: lessons.asMap().entries.map((entry) {
                                    int index = entry.key;
                                    Map<String, dynamic> lesson = entry.value;
                                    final isLocked = lesson['isLocked'] ?? false;
                                    final title = lesson['title'] ?? 'Untitled';
                                    final duration = lesson['duration'] ?? '0:00';
                                    final isPlaying = playingIndex == index;

                                    return InkWell(
                                      onTap: isLocked
                                          ? null
                                          : () => playLesson(index),
                                      child: Container(
                                        margin: const EdgeInsets.symmetric(vertical: 8),
                                        child: Row(
                                          children: [
                                            Text((index + 1).toString().padLeft(2, '0'),
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: isPlaying ? Colors.red : Colors.black,
                                                )),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(title,
                                                      style: TextStyle(
                                                        fontWeight: FontWeight.bold,
                                                        color: isPlaying ? Colors.red : Colors.black,
                                                      )),
                                                  const SizedBox(height: 2),
                                                  Text("$duration mins",
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        color: isLocked
                                                            ? Colors.grey
                                                            : (isPlaying ? Colors.red : Colors.black),
                                                      )),
                                                ],
                                              ),
                                            ),
                                            if (isLocked)
                                              const Icon(Icons.lock, color: Colors.grey)
                                            else
                                              IconButton(
                                                icon: Icon(
                                                  isPlaying
                                                      ? Icons.pause_circle
                                                      : Icons.play_circle_fill,
                                                  color: isPlaying ? Colors.red : Colors.blue,
                                                  size: 28,
                                                ),
                                                onPressed: () => playLesson(index),
                                              ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
