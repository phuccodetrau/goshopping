import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../group_main_screen.dart';

class AddMember extends StatefulWidget {
  final String groupName;
  final String groupId;

  AddMember({required this.groupName, required this.groupId});

  @override
  _AddMemberState createState() => _AddMemberState();
}

class _AddMemberState extends State<AddMember> {
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  final TextEditingController _searchController = TextEditingController();
  final String _url = dotenv.env['ROOT_URL']!;

  List<Map<String, String>> _userSuggestions = [];
  List<Map<String, String>> _selectedUsers = [];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  // Listener for search text field
  void _onSearchChanged() {
    final query = _searchController.text;
    if (query.isNotEmpty) {
      _searchUserByEmail(query);
    } else {
      setState(() {
        _userSuggestions.clear();
      });
    }
  }

  // Function to search users by email
  Future<void> _searchUserByEmail(String email) async {
    try {
      final String? token = await _secureStorage.read(key: "auth_token");
      final response = await http.get(
        Uri.parse('$_url/auth/user/get-user-name?email=$email'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == true && data['name'] != null) {
          setState(() {
            _userSuggestions = [
              {
                "name": data['name'],
                "email": email,
              }
            ];
          });
        }
      } else {
        print("Failed to fetch user. Status code: ${response.statusCode}");
      }
    } catch (error) {
      print("Error searching user: $error");
    }
  }

  // Function to select a user from the suggestions
  void _selectUser(Map<String, String> user) {
    if (_selectedUsers.any((selectedUser) => selectedUser['email'] == user['email'])) {
      return; // If user is already selected, ignore
    }

    setState(() {
      _selectedUsers.add(user);
      _userSuggestions.clear();
      _searchController.clear();
    });
  }

  // Function to remove a selected user
  void _removeUser(Map<String, String> user) {
    setState(() {
      _selectedUsers.removeWhere((selectedUser) => selectedUser['email'] == user['email']);
    });
  }

  // Function to add members to the group
  Future<void> _addMembers() async {
    if (_selectedUsers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please select members to add to the group.")),
      );
      return;
    }

    final members = _selectedUsers
        .map((user) => {"name": user['name'], "email": user['email'], "role": "user"})
        .toList();

    final data = {
      "groupId": widget.groupId,
      "members": members,
    };

    try {
      final String? token = await _secureStorage.read(key: "auth_token");
      final response = await http.put(
        Uri.parse('$_url/groups/add-member'),
        headers: {
          "Content-Type": "application/json",
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Members added successfully!")),
        );
        setState(() {
          _selectedUsers.clear();
        });
        // Navigate to GroupMainScreen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => GroupMainScreen(
              groupId: widget.groupId,
              groupName: widget.groupName,
              adminName: "Admin", // Pass appropriate adminName if available
            ),
          ),
        );
      } else {
        print("Failed to add members. Status code: ${response.statusCode}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to add members.")),
        );
      }
    } catch (error) {
      print("Error adding members: $error");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error adding members.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Thêm thành viên",
          style: TextStyle(color: Colors.green),
        ),
        actions: [
          TextButton(
            onPressed: _addMembers,
            child: Text(
              "Hoàn tất",
              style: TextStyle(color: Colors.green),
            ),
          ),
        ],
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Nhập Email để tìm kiếm",
                filled: true,
                fillColor: Colors.grey[200],
                prefixIcon: Icon(Icons.search, color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            SizedBox(height: 20),
            Wrap(
              children: _selectedUsers.map((user) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: CircleAvatar(
                    backgroundImage: AssetImage("images/group.png"),
                    radius: 30,
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: 20),
            Text(
              "Gợi ý",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: _userSuggestions.length,
                itemBuilder: (context, index) {
                  final user = _userSuggestions[index];
                  return GestureDetector(
                    onTap: () => _selectUser(user),
                    child: ContactItem(
                      name: user['name']!,
                      image: "images/group.png",
                      isSelected: _selectedUsers.any((selectedUser) =>
                      selectedUser['email'] == user['email']),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ContactItem extends StatelessWidget {
  final String name;
  final String image;
  final bool isSelected;

  const ContactItem({
    required this.name,
    required this.image,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: AssetImage(image),
        radius: 20,
      ),
      title: Text(name),
      trailing: Icon(
        isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
        color: isSelected ? Colors.green : Colors.grey,
      ),
    );
  }
}
