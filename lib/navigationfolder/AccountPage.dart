import 'package:e_learnning/screens/editprofilescreen.dart';
import 'package:flutter/material.dart';
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: Icon(Icons.arrow_back, color: Colors.black),
        title: Text("My Profile", style: TextStyle(color: Colors.black)),
        centerTitle: true,
        elevation: 0,
        actions: [Icon(Icons.settings, color: Colors.black)],
      ),
      body: Column(
        children: [
          SizedBox(height: 20),

          // Profile Info
          CircleAvatar(
            radius: 50,
            backgroundImage: AssetImage('images/profile.png'), // Replace with NetworkImage if needed
          ),
          SizedBox(height: 10),
          Text("Sabrina Aryan", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          Text("SabrinaAry208@gmail.com", style: TextStyle(color: Colors.grey)),
          SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return EditProfileScreen();
              },));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text("Edit Profile"),
          ),
          SizedBox(height: 30),

          // Options List
          Expanded(
            child: ListView(
              children: [
                _buildTile(Icons.favorite_border, "Favourites"),
                _buildTile(Icons.download, "Downloads"),
                Divider(thickness: 1, height: 30),
                _buildTile(Icons.language, "Languages"),
                _buildTile(Icons.location_on_outlined, "Location"),
                _buildTile(Icons.subscriptions_outlined, "Subscription"),
                _buildTile(Icons.desktop_windows, "Display"),
                Divider(thickness: 1, height: 30),
                _buildTile(Icons.delete_outline, "Clear Cache"),
                _buildTile(Icons.history, "Clear History"),
                _buildTile(Icons.logout, "Log Out"),
                SizedBox(height: 20),
                Center(child: Text("App Version 2.3", style: TextStyle(color: Colors.grey))),
                SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTile(IconData icon, String title) {
    return ListTile(
      leading: Icon(icon, color: Colors.black),
      title: Text(title),
      trailing: Icon(Icons.chevron_right),
      onTap: () {},
    );
  }
}
