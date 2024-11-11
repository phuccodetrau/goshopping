import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../group_main_screen.dart';

class AddMember extends StatefulWidget {
  final String groupName;

  AddMember({required this.groupName});

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
      final response = await http.get(Uri.parse('$_url/user/get-user-name-by-email?email=$email'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == true && data['name'] != null && data['name']['name'] != null) {
          setState(() {
            _userSuggestions = [
              {
                "name": data['name']['name'],
                "email": email,
              }
            ];
          });
        }
      } else {
        print("Failed to fetch user.");
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

  // Function to add the group with selected members
  Future<void> _addGroup() async {
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
      "groupName": widget.groupName, // Use the passed groupName
      "members": members,
    };

    try {
      final response = await http.put(
        Uri.parse('$_url/groups/add-member'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Group created successfully!")),
        );
        setState(() {
          _selectedUsers.clear();
        });

        // Set adminName as the creator of the group
        final adminName = _selectedUsers.isNotEmpty ? _selectedUsers[0]['name'] ?? "Admin" : "Admin";

        // Navigate to GroupMainScreen with groupName and adminName
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => GroupMainScreen(
              groupName: widget.groupName,
              adminName: adminName,
            ),
          ),
        );
      } else {
        print("Failed to create group. Status code: ${response.statusCode}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to create group.")),
        );
      }
    } catch (error) {
      print("Error creating group: $error");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error creating group.")),
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
          "",
          style: TextStyle(color: Colors.green),
        ),
        actions: [
          TextButton(
            onPressed: _addGroup,
            child: Text(
              "Tạo nhóm",
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
            // Search bar for adding members
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Nhập Tên hoặc Email để tìm kiếm",
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

            // Display selected users with an option to remove
            Wrap(
              children: _selectedUsers.map((user) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Stack(
                    alignment: Alignment.topRight,
                    children: [
                      CircleAvatar(
                        backgroundImage: AssetImage("images/group.png"),
                        radius: 30,
                      ),
                      Positioned(
                        right: 0,
                        top: 0,
                        child: GestureDetector(
                          onTap: () => _removeUser(user),
                          child: Container(
                            padding: EdgeInsets.all(1),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
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

            // Suggested contacts list based on the search
            Expanded(
              child: _userSuggestions.isNotEmpty
                  ? ListView.builder(
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
              )
                  : ListView(
                children: [
                  ContactItem(
                      name: "Hoanghung_1000",
                      image: "images/group.png",
                      isSelected: false),
                  ContactItem(
                      name: "Thaomy_1000",
                      image: "images/group.png",
                      isSelected: false),
                  ContactItem(
                      name: "Alice_200",
                      image: "images/group.png",
                      isSelected: false),
                  ContactItem(
                      name: "Tom_1000",
                      image: "images/group.png",
                      isSelected: false),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: ''),
        ],
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
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
