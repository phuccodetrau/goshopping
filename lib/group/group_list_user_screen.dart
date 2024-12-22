import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GroupListUserScreen extends StatefulWidget {
  @override
  _GroupListUserScreenState createState() => _GroupListUserScreenState();
}

class _GroupListUserScreenState extends State<GroupListUserScreen> {
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  final String _url = dotenv.env['ROOT_URL']!;
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> users = [];
  List<Map<String, dynamic>> filteredUsers = [];
  String? groupId;
  String? token;
  String? currentUserEmail;
  bool isCurrentUserAdmin = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _loadInitialData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      filteredUsers = users.where((user) {
        return user['name'].toString().toLowerCase().contains(query) ||
               user['email'].toString().toLowerCase().contains(query);
      }).toList();
    });
  }

  Future<void> _loadInitialData() async {
    await _loadGroupUsers();
    await _loadCurrentUserInfo();
  }

  Future<void> _loadCurrentUserInfo() async {
    try {
      currentUserEmail = await _secureStorage.read(key: 'email');
      
      if (users.isNotEmpty && currentUserEmail != null) {
        final currentUser = users.firstWhere(
          (user) => user['email'] == currentUserEmail,
          orElse: () => {'role': 'member'},
        );
        
        setState(() {
          isCurrentUserAdmin = currentUser['role'] == 'admin';
        });
        
        print('Current user email: $currentUserEmail');
        print('Is admin: $isCurrentUserAdmin');
      }
    } catch (e) {
      print('Error loading current user info: $e');
    }
  }

  Future<void> _loadGroupUsers() async {
    try {
      groupId = await _secureStorage.read(key: 'groupId');
      token = await _secureStorage.read(key: 'auth_token');
      
      final response = await http.get(
        Uri.parse('$_url/groups/get-users-by-group-id/$groupId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['code'] == 700) {
          setState(() {
            users = List<Map<String, dynamic>>.from(responseData['data']);
            filteredUsers = users;
          });
          print('Loaded users: $users');
        }
      }
    } catch (e) {
      print('Error loading group users: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Không thể tải danh sách thành viên'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _removeMember(String memberEmail) async {
    try {
      print('Removing member with email: $memberEmail'); // Debug log
      print('Group ID: $groupId'); // Debug log

      final response = await http.delete(
        Uri.parse('$_url/groups/remove-member'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'groupId': groupId,
          'email': memberEmail,
        }),
      );

      print('Response status: ${response.statusCode}'); // Debug log
      print('Response body: ${response.body}'); // Debug log

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['code'] == 700) {
          setState(() {
            users.removeWhere((user) => user['email'] == memberEmail);
            filteredUsers.removeWhere((user) => user['email'] == memberEmail);
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Đã xóa thành viên khỏi nhóm'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          // Hiển thị thông báo lỗi từ server
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(responseData['message'] ?? 'Không thể xóa thành viên'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        // Xử lý các mã lỗi HTTP khác
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi xóa thành viên: ${response.statusCode}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Error removing member: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Không thể xóa thành viên: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showRemoveConfirmDialog(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Xác nhận xóa thành viên'),
          content: Text('Bạn có chắc chắn muốn xóa ${user['name']} khỏi nhóm?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Hủy'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _removeMember(user['email']);
              },
              child: Text(
                'Xóa',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.green[900]),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Thành viên nhóm',
          style: TextStyle(
            fontSize: 24,
            color: Colors.green[900],
            fontWeight: FontWeight.bold
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Search Bar
            Container(
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
                      decoration: InputDecoration(
                        hintText: 'Tìm kiếm thành viên',
                        border: InputBorder.none
                      ),
                    ),
                  ),
                  Icon(Icons.search, color: Colors.grey),
                ],
              ),
            ),
            SizedBox(height: 16),
            // List of Users
            Expanded(
              child: filteredUsers.isEmpty
                ? Center(
                    child: CircularProgressIndicator(
                      color: Colors.green,
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _loadGroupUsers,
                    child: ListView.builder(
                      itemCount: filteredUsers.length,
                      itemBuilder: (context, index) {
                        final user = filteredUsers[index];
                        return Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0)
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Row(
                              children: [
                                user["avatar"] == "" ?
                                CircleAvatar(
                                  radius: 30,
                                  backgroundColor: Colors.green[100],
                                  child: Text(
                                    user['name']?[0]?.toUpperCase() ?? '?',
                                    style: TextStyle(
                                      fontSize: 24,
                                      color: Colors.green[900],
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ) : ClipOval(
                                  child: Container(
                                    color: Colors.green[100],
                                    width: 60,
                                    height: 60,
                                    child: Image.memory(
                                      base64Decode(user["avatar"]),
                                      fit: BoxFit.cover,
                                      width: 60,
                                      height: 60,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        user['name'] ?? 'Không có tên',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        user['email'] ?? '',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 14,
                                        ),
                                      ),
                                      Text(
                                        user['role'] == 'admin' 
                                          ? 'Quản trị viên'
                                          : 'Thành viên',
                                        style: TextStyle(
                                          color: user['role'] == 'admin' 
                                            ? Colors.green 
                                            : Colors.grey,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Chỉ hiển thị nút 3 chấm nếu user hiện tại là admin
                                if (isCurrentUserAdmin && user['email'] != currentUserEmail)
                                  PopupMenuButton<String>(
                                    icon: Icon(Icons.more_vert, color: Colors.grey),
                                    onSelected: (value) {
                                      if (value == 'remove') {
                                        _showRemoveConfirmDialog(user);
                                      }
                                    },
                                    itemBuilder: (BuildContext context) => [
                                      PopupMenuItem(
                                        value: 'remove',
                                        child: Row(
                                          children: [
                                            Icon(Icons.person_remove, color: Colors.red),
                                            SizedBox(width: 8),
                                            Text('Xóa khỏi nhóm'),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
