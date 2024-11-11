import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_shopping/user/user_info.dart';
import 'package:go_shopping/group/add_group/add_group_screen.dart';
import 'package:go_shopping/group/group_main_screen.dart'; // Import màn hình GroupMainScreen
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _secureStorage = FlutterSecureStorage();
  final String _url = dotenv.env['ROOT_URL']!;
  final TextEditingController _searchController = TextEditingController();
  String email = "";
  String name = "";
  int _selectedIndex = 0;
  List<dynamic> userGroups = [];
  List<dynamic> filteredGroups = [];
  Map<String, String> adminNames = {};

  @override
  void initState() {
    super.initState();
    _initializeUserInfo().then((_) {
      _fetchUserGroups();
    });
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _initializeUserInfo() async {
    final emailUser = await _secureStorage.read(key: "email") ?? '';
    final userName = await _fetchUserNameByEmail(emailUser);

    setState(() {
      email = emailUser;
      name = userName;
    });
  }

  Future<String> _fetchUserNameByEmail(String email) async {
    try {
      final response = await http.get(Uri.parse('$_url/user/get-user-name-by-email?email=$email'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == true && data['name'] != null && data['name']['name'] != null) {
          return data['name']['name'];
        }
      }
    } catch (error) {
      print("Error fetching user name: $error");
    }
    return email.isNotEmpty ? email.substring(0, 15) : "Unknown User";
  }

  Future<void> _fetchUserGroups() async {
    try {
      final response = await http.get(Uri.parse('$_url/groups/get-groups-by-member-email?email=$email'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['code'] == 700 && data['data'] != null) {
          setState(() {
            userGroups = data['data'];
            filteredGroups = userGroups;
          });
          _fetchAdminNamesForGroups();
        }
      }
    } catch (error) {
      print("Error fetching user groups: $error");
    }
  }

  Future<void> _fetchAdminNamesForGroups() async {
    for (String groupName in userGroups) {
      try {
        final response = await http.get(Uri.parse('$_url/groups/get-admins-by-group-name?groupName=$groupName'));
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          if (data['code'] == 700 && data['data'] != null && data['data'].isNotEmpty) {
            setState(() {
              adminNames[groupName] = data['data'][0];
            });
          }
        }
      } catch (error) {
        print("Error fetching admin for group $groupName: $error");
      }
    }
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      filteredGroups = userGroups.where((groupName) {
        return groupName.toLowerCase().contains(query);
      }).toList();
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => PersonalInfoScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(),
      floatingActionButton: _buildFloatingActionButton(),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: Text(
        'Cộng đồng',
        style: TextStyle(fontSize: 24, color: Colors.green[900], fontWeight: FontWeight.bold),
      ),
      leading: IconButton(
        icon: Icon(Icons.menu, color: Colors.grey[700]),
        onPressed: () {},
      ),
    );
  }

  Widget _buildBody() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _buildSearchBar(),
          SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: filteredGroups.length,
              itemBuilder: (context, index) {
                final groupName = filteredGroups[index];
                final adminName = adminNames[groupName] ?? "Chưa có admin";

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => GroupMainScreen(
                          groupName: groupName,
                          adminName: adminName,
                        ),
                      ),
                    );
                  },
                  child: _buildGroupCard(groupName, adminName),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(hintText: 'Tìm kiếm nhóm', border: InputBorder.none),
            ),
          ),
          Icon(Icons.search, color: Colors.grey),
        ],
      ),
    );
  }

  Widget _buildGroupCard(String groupName, String adminName) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            CircleAvatar(radius: 30, backgroundImage: AssetImage('images/group.png')),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(groupName, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 4),
                  Row(children: [Text('Admin: $adminName')]),
                ],
              ),
            ),
            IconButton(icon: Icon(Icons.more_vert), onPressed: () {}),
          ],
        ),
      ),
    );
  }

  FloatingActionButton _buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AddGroupScreen()),
        );
      },
      backgroundColor: Colors.green[700],
      child: Icon(Icons.add, color: Colors.white),
    );
  }

  BottomNavigationBar _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      selectedItemColor: Colors.green[700],
      unselectedItemColor: Colors.grey,
      onTap: _onItemTapped,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
        BottomNavigationBarItem(icon: Icon(Icons.notifications), label: ''),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: ''),
      ],
    );
  }
}
