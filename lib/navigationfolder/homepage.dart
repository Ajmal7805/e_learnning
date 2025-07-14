import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_learnning/homescreen/homescreen.dart';
import 'package:e_learnning/navigationfolder/AccountPage.dart';
import 'package:e_learnning/screens/CourseDetailsPage.dart';
import 'package:e_learnning/screens/editprofilescreen.dart';
import 'package:flutter/material.dart';
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f5f5),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Top greeting section
              Container(
                color: const Color(0xff3e64ff),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children:  [
                        InkWell(onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) {
                            return  ProfileScreen();
                          },));
                        },
                          child: CircleAvatar(
                            backgroundImage: AssetImage('images/profile.png'),
                          ),
                        ),
                        SizedBox(width: 10),
                        Text(
                          'Hi, Kristin',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Spacer(),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Let's start learning",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 15),
                      child: Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'Learned today',
                                style: TextStyle(color: Colors.grey),
                              ),
                              SizedBox(height: 5),
                              Text(
                                '46min / 60min',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const Spacer(),
                         
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // What do you want to learn today?
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: const [
                    Text(
                      'What do you want to learn today?',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            

              // Learning plan
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: const [
                    Text(
                      'Learning Plan',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    children: [
                      progressRow('Packaging Design', 40, 48),
                      const SizedBox(height: 10),
                      progressRow('Product Design', 6, 24),
                    ],
                  ),
                ),
              ),

              // Meetup section
              const SizedBox(height: 20),
              Row(
                children: [
                  SizedBox(width: 10,),
                  Text('Countinue with',style: TextStyle(),),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                      height: 160,
                      child: StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('courses')
                            .where('islocked', isEqualTo: false)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          }
                
                          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                            return const Center(child: Text("No free courses available"));
                          }
                
                          return ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: snapshot.data!.docs.length,
                            itemBuilder: (context, index) {
                var course = snapshot.data!.docs[index].data() as Map<String, dynamic>;
                
                String title = course['courseName'] ?? '';
                String author = course['authorName'] ?? '';
                String duration = course['totalDuration'] ?? '';
                String description = course['courseDescription'] ?? '';
                String courseId = course['courseId'] ?? '';
                String thumbnailUrl = course['youtubeId'] != null
                    ? 'https://img.youtube.com/vi/${course['youtubeId']}/hqdefault.jpg'
                    : 'https://via.placeholder.com/150';
                
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CourseDetailsPage(
                          itsstarted: true,
                          title: title,
                          author: author,
                          duration: duration,
                          thumbnailUrl: thumbnailUrl,
                          courseId: courseId,
                          description: description,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    width: 200,
                    margin: const EdgeInsets.only(right: 12),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            thumbnailUrl,
                            height: 80,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          title,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 14),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          author,
                          style:
                              const TextStyle(fontSize: 12, color: Colors.grey),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                );
                            },
                          );
                        },
                      ),
                    ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.purple.shade100,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Meetup',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 5),
                            Text(
                              'Off-line exchange of learning experiences',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.people, size: 40, color: Colors.blue),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // Learning Card Widget
  Widget learningCard(String title, String imgUrl) {
    return Container(
      width: 150,
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(15),
      ),
      padding: const EdgeInsets.all(15),
      child: Column(
        children: [
          
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
         
          
        ],
      ),
    );
  }

  // Progress Row Widget
  Widget progressRow(String title, int progress, int total) {
    return Row(
      children: [
        const Icon(Icons.check_circle_outline, color: Colors.grey),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(fontSize: 16),
          ),
        ),
        Text(
          '$progress/$total',
          style: const TextStyle(color: Colors.grey),
        ),
      ],
    );
  }
}
