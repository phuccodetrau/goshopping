import 'package:flutter/material.dart';

class GroupMainScreen extends StatelessWidget {
  const GroupMainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const Icon(Icons.arrow_back),
        title: Text("Gia đình bên nội",style: TextStyle(color: Colors.green[800],fontWeight: FontWeight.bold),),
        actions: [
          IconButton(icon: const Icon(Icons.person_add), onPressed: () {}),
          IconButton(icon: const Icon(Icons.chat_bubble_outline), onPressed: () {}),
        ],

      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Image and Family Title
            Stack(
              alignment: Alignment.bottomCenter,
              children: [
                Image.asset(
                  'images/group.png',
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),

                const Positioned(
                  bottom: 16,
                  child: Column(
                    children: [
                      Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                      ),
                      Text(
                        "Gia đình bên nội",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const Positioned(
                  bottom: 16,
                  right: 16,
                  child: Icon(
                    Icons.edit,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            // Family Members
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  MemberAvatar(name: "Hung", imagePath: 'images/group.png'),
                  const SizedBox(width: 10),
                  MemberAvatar(name: "Hung", imagePath: 'images/group.png'),
                  const SizedBox(width: 10),
                  MemberAvatar(name: "Hoang", imagePath: 'images/group.png'),
                  const SizedBox(width: 10),
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.grey[300],
                    child: const Text("+3", style: TextStyle(color: Colors.black)),
                  ),
                ],
              ),
            ),
            // Food Management Section
            SectionTitle(title: "Quản lí thực phẩm"),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  FoodCard(

                    title: "Thực phẩm tủ lạnh",
                    description: "Quản lí số lượng các loại thực phẩm",
                    color: Colors.green[700]!,
                    iconPath: 'images/group.png',

                  ),
                  FoodCard(
                    title: "Món ăn theo ngày",
                    description: "Quản lí từng bữa ăn dễ dàng, có công thức kèm theo.",
                    color: Colors.orange[700]!,
                    iconPath: 'images/group.png',
                  ),
                ],
              ),
            ),
            // Activity Section
            SectionTitle(title: "Hoạt động"),
            ActivityCard(
              title: "Kế hoạch nấu ăn",
              filesCount: 4,
              adminName: "@hung123",
              adminAvatarPath: "images/group.png"
            ),
          ],
        ),
      ),
    );
  }
}

// Widget for family member avatars
class MemberAvatar extends StatelessWidget {
  final String name;
  final String imagePath;

  const MemberAvatar({super.key, required this.name, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundImage: AssetImage(imagePath),
        ),
        const SizedBox(height: 5),
        Text(name, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}

// Widget for section titles
class SectionTitle extends StatelessWidget {
  final String title;

  const SectionTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

// Widget for food management cards
class FoodCard extends StatelessWidget {
  final String title;
  final String description;
  final Color color;
  final String iconPath;


  const FoodCard({super.key, 

    required this.title,
    required this.description,
    required this.color,
    required this.iconPath,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.4,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(child: Image.asset(iconPath, height: 50,),),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold,color: Colors.white),
          ),
          const SizedBox(height: 5),
          Text(
            description,
            style: const TextStyle(fontSize: 12,color: Colors.white),
          ),
          const SizedBox(height: 10),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(Icons.cloud, size: 20),
              Text("20"),
            ],
          )
        ],
      ),
    );
  }
}

// Widget for activity card
class ActivityCard extends StatelessWidget {
  final String title;
  final int filesCount;
  final String adminName;
  final String adminAvatarPath;

  const ActivityCard({super.key, 
    required this.title,
    required this.filesCount,
    required this.adminName,
    required this.adminAvatarPath,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundImage: AssetImage(adminAvatarPath),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 5),
                Text(
                  "$filesCount Files  Admin: $adminName",
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
            const Spacer(),
            const Icon(Icons.more_vert),
          ],
        ),
      ),
    );
  }
}
