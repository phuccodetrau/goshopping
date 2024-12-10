import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_shopping/user/user_info.dart';
import 'package:go_shopping/group/add_group/add_group_screen.dart';
import 'package:go_shopping/group/group_main_screen.dart';
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
  List<dynamic> filteredGroupsId = [];
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
      final String? token = await _secureStorage.read(key: "auth_token");
      final response = await http.get(
        Uri.parse('$_url/user/get-user-name-by-email'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == true && data['name'] != null) {
          return data['name'];
        }
      }
    } catch (error) {
      print("Error fetching user name: $error");
    }
    return "Unknown User";
  }

  Future<void> _fetchUserGroups() async {
    try {
      final String? token = await _secureStorage.read(key: "auth_token");
      final response = await http.get(
        Uri.parse('$_url/groups/get-groups-by-member-email?email=$email'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['code'] == 700 && data['data'] != null) {
          setState(() {
            userGroups = data['data'];
            filteredGroups = userGroups.map((group) => group['name']).toList();
            filteredGroupsId = userGroups.map((group) => group['id']).toList();
          });
          _fetchAdminNamesForGroups();
        }
      }
    } catch (error) {
      print("Error fetching user groups: $error");
    }
  }

  Future<void> _fetchAdminNamesForGroups() async {
    for (var groupId in filteredGroupsId) {
      try {
        final String? token = await _secureStorage.read(key: "auth_token");
        final response = await http.get(
          Uri.parse('$_url/groups/get-admins-by-group-id?groupId=$groupId'),
          headers: {
            'Authorization': 'Bearer $token',
          },
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          if (data['code'] == 700 && data['data'] != null && data['data'].isNotEmpty) {
            setState(() {
              adminNames[groupId.toString()] = data['data'][0]; // Giả sử API trả về admin name đầu tiên
            });
          } else {
            setState(() {
              adminNames[groupId.toString()] = "Chưa có admin";
            });
          }
        } else {
          setState(() {
            adminNames[groupId.toString()] = "Chưa có admin";
          });
        }
      } catch (error) {
        print("Error fetching admin for group $groupId: $error");
        setState(() {
          adminNames[groupId.toString()] = "Chưa có admin";
        });
      }
    }
    print("Final adminNames: $adminNames");
  }

  bool _isAdmin(String groupId) {
    final group = userGroups.firstWhere((group) => group['id'] == groupId, orElse: () => null);
    if (group == null) return false;

    final userEmail = email;
    return group['listUser'].any(
          (user) => user['email'] == userEmail && user['role'] == 'admin',
    );
  }


  void _handleMenuSelection(String value, String groupId) {
    switch (value) {
      case 'delete':
        _confirmDeleteGroup(groupId); // Hiển thị hộp thoại xác nhận trước khi xóa nhóm
        break;
      case 'leave':
        _confirmLeaveGroup(groupId); // Hiển thị hộp thoại xác nhận trước khi rời nhóm
        break;
      default:
        break;
    }
  }

  void _confirmDeleteGroup(String groupId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Xác nhận xóa'),
          content: Text('Bạn có chắc chắn muốn xóa nhóm này?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Hủy'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteGroup(groupId);
              },
              child: Text('Xóa'),
            ),
          ],
        );
      },
    );
  }

  void _confirmLeaveGroup(String groupId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Xác nhận rời nhóm'),
          content: Text('Bạn có chắc chắn muốn rời nhóm này?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Hủy'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _leaveGroup(groupId);
              },
              child: Text('Rời nhóm'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteGroup(String groupId) async {
    try {
      final String? token = await _secureStorage.read(key: "auth_token");
      final response = await http.delete(
        Uri.parse('$_url/groups/delete-group'),
        headers: {
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'groupId': groupId}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['code'] == 700) {
          setState(() {
            userGroups.removeWhere((group) => group['id'] == groupId);
            filteredGroups.removeWhere((group) => group['id'] == groupId);
          });
        }
      }
    } catch (error) {
      print("Error deleting group: $error");
    }
  }

  Future<void> _leaveGroup(String groupId) async {
    try {
      final String? token = await _secureStorage.read(key: "auth_token");

      // Kiểm tra xem groupId có tồn tại không trước khi gửi request
      if (groupId == null || groupId.isEmpty) {
        print("groupId is null or empty");
        return;  // Dừng lại nếu groupId không hợp lệ
      }

      print("Sending request with groupId: $groupId");

      final response = await http.delete(
        Uri.parse('$_url/groups/leave-group'),
        headers: {
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'groupId': groupId}),  // Gửi groupId qua body
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print("Response from backend: $data");

        if (data['code'] == 700) {
          setState(() {
            userGroups.removeWhere((group) => group['id'] == groupId);
            filteredGroups.removeWhere((group) => group['id'] == groupId);
          });
        }
      }
    } catch (error) {
      print("Error leaving group: $error");
    }
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      // Lọc các nhóm theo tên và ID nhóm
      filteredGroups = userGroups.where((group) {
        return group['name'].toLowerCase().contains(query);  // Tìm kiếm theo tên nhóm
      }).map((group) => group['name']).toList();

      // Lọc ID nhóm tương ứng với tên nhóm tìm được
      filteredGroupsId = userGroups.where((group) {
        return group['name'].toLowerCase().contains(query);
      }).map((group) => group['id']).toList();
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
                final groupId = filteredGroupsId[index];
                final groupName = filteredGroups[index];
                final adminName = adminNames[groupId.toString()] ?? "Chưa có admin";

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => GroupMainScreen(
                          groupId: groupId,
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
            PopupMenuButton<String>(
              onSelected: (value) => _handleMenuSelection(value, groupName),
              itemBuilder: (BuildContext context) {
                final isAdmin = _isAdmin(groupName); // Kiểm tra quyền
                return isAdmin
                    ? [
                  PopupMenuItem(
                    value: 'delete',
                    child: Text('Xóa nhóm'),
                  ),
                ]
                    : [
                  PopupMenuItem(
                    value: 'leave',
                    child: Text('Rời nhóm'),
                  ),
                ];
              },
              icon: Icon(Icons.more_vert),
            ),
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
