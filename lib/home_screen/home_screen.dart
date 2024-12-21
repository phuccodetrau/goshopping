import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_shopping/user/user_info.dart';
import 'package:go_shopping/group/add_group/add_group_screen.dart';
import 'package:go_shopping/group/group_main_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:go_shopping/notification/notification_screen.dart';
import '../statistics/statistics_screen.dart';
import 'package:flutter/services.dart';

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
          print('Token: ' + token!);
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
                    // Lưu toàn bộ thông tin group, bao gồm cả listUser
                    userGroups = data['data'].map((group) => {
                        'id': group['id'],
                        'name': group['name'],
                        'listUser': group['listUser'] ?? []
                    }).toList();
                    
                    filteredGroups = userGroups.map((group) => group['name']).toList();
                    filteredGroupsId = userGroups.map((group) => group['id']).toList();
                });

                // Khởi tạo adminNames với giá trị mặc định
                for (var group in userGroups) {
                    adminNames[group['id']] = "Đang tải...";
                }

                // Fetch admin names cho từng nhóm
                for (var group in userGroups) {
                    await _fetchAdminsByGroupId(group['id']);
                }
            }
        }
    } catch (error) {
        print("Error fetching user groups: $error");
    }
  }

  Future<void> _fetchAdminsByGroupId(String groupId) async {
    try {
        final String? token = await _secureStorage.read(key: "auth_token");
        final response = await http.get(
            Uri.parse('$_url/groups/get-admins-by-group-id/$groupId'),
            headers: {
                'Authorization': 'Bearer $token',
            },
        );

        if (response.statusCode == 200) {
            final data = jsonDecode(response.body);
            if (data['code'] == 700 && data['data'] != null) {
                final List<dynamic> admins = data['data'];
                setState(() {
                    if (admins.isNotEmpty) {
                        // Join tên các admin với dấu phẩy nếu có nhiều admin
                        adminNames[groupId] = admins.join(", ");
                    } else {
                        adminNames[groupId] = "Chưa có admin";
                    }
                });
            }
        }
    } catch (error) {
        print("Error fetching admin for group $groupId: $error");
        setState(() {
            adminNames[groupId] = "Lỗi khi tải thông tin admin";
        });
    }
  }

  bool _isAdmin(String groupId) {
    try {
        // Tìm group trong danh sách userGroups
        final group = userGroups.firstWhere(
            (group) => group['id'] == groupId,
            orElse: () => null
        );
        
        if (group == null) return false;

        // Kiểm tra listUser có tồn tại không
        final listUser = group['listUser'];
        if (listUser == null) return false;

        // Tìm user trong listUser của group
        return (listUser as List).any((user) => 
            user['email'] == email && user['role'] == 'admin'
        );
    } catch (error) {
        print("Error checking admin status for email $email in group $groupId: $error");
        return false;
    }
  }


  void _handleMenuSelection(String value, String groupId) {
    switch (value) {
        case 'delete':
            if (_isAdmin(groupId)) {
                _confirmDeleteGroup(groupId);
            } else {
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Bạn không có quyền xóa nhóm này'))
                );
            }
            break;
        case 'leave':
            if (!_isAdmin(groupId)) {
                _confirmLeaveGroup(groupId);
            } else {
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Admin không thể rời nhóm. Vui lòng chỉ định admin mới hoặc xóa nhóm'))
                );
            }
            break;
        case 'stats':
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => StatisticsScreen(groupId: groupId),
                ),
            );
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
        
        print("Deleting group with ID: $groupId"); // Debug log

        final response = await http.delete(
            Uri.parse('$_url/groups/delete-group'),
            headers: {
                'Authorization': 'Bearer $token',
                'Content-Type': 'application/json', // Thêm header này
            },
            body: jsonEncode({
                'groupId': groupId
            }),
        );

        print("Delete response status: ${response.statusCode}"); // Debug log
        print("Delete response body: ${response.body}"); // Debug log

        if (response.statusCode == 200) {
            final data = jsonDecode(response.body);
            if (data['code'] == 700) {
                setState(() {
                    userGroups.removeWhere((group) => group['id'] == groupId);
                    filteredGroups = userGroups.map((group) => group['name']).toList();
                    filteredGroupsId = userGroups.map((group) => group['id']).toList();
                });
                // Hiển thị thông báo thành công
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Xóa nhóm thành công'))
                );
            } else {
                // Hiển thị thông báo lỗi từ server
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(data['message'] ?? 'Có lỗi xảy ra'))
                );
            }
        } else {
            // Hiển thị thông báo lỗi HTTP
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Lỗi khi xóa nhóm: ${response.statusCode}'))
            );
        }
    } catch (error) {
        print("Error deleting group: $error");
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Có lỗi xảy ra khi xóa nhóm'))
        );
    }
  }

  Future<void> _leaveGroup(String groupId) async {
    try {
      final String? token = await _secureStorage.read(key: "auth_token");

      print("Sending leave group request for groupId: $groupId"); // Debug log

      final response = await http.delete(
        Uri.parse('$_url/groups/leave-group/$groupId'), // Thay đổi từ query parameter sang path parameter
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print("Leave group response status: ${response.statusCode}"); // Debug log
      print("Leave group response body: ${response.body}"); // Debug log

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['code'] == 700) {
          setState(() {
            userGroups.removeWhere((group) => group['id'] == groupId);
            filteredGroups = userGroups.map((group) => group['name']).toList();
            filteredGroupsId = userGroups.map((group) => group['id']).toList();
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Rời nhóm thành công'))
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data['message'] ?? 'Có lỗi xảy ra khi rời nhóm'))
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi rời nhóm: ${response.statusCode}'))
        );
      }
    } catch (error) {
      print("Error leaving group: $error");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Có lỗi xảy ra khi rời nhóm'))
      );
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

    if (index == 1) {  // Notification tab
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => NotificationScreen()),
      );
    } else if (index == 2) {  // Profile tab
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => PersonalInfoScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Thoát ứng dụng'),
            content: Text('Bạn có muốn thoát khỏi ứng dụng không?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('Hủy'),
              ),
              TextButton(
                onPressed: () {
                  SystemNavigator.pop();
                },
                child: Text('Thoát'),
              ),
            ],
          ),
        ) ?? false;
      },
      child: Scaffold(
        appBar: _buildAppBar(),
        body: _buildBody(),
        floatingActionButton: _buildFloatingActionButton(),
        bottomNavigationBar: _buildBottomNavigationBar(),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: Text(
        'Nhóm đã tham gia',
        style: TextStyle(fontSize: 24, color: Colors.green[900], fontWeight: FontWeight.bold),
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
            child: RefreshIndicator(
              onRefresh: () async {
                await _fetchUserGroups();
              },
              child: ListView.builder(
                itemCount: filteredGroups.length,
                itemBuilder: (context, index) {
                  final groupId = filteredGroupsId[index];
                  final groupName = filteredGroups[index];
                  final adminName = adminNames[groupId] ?? "Chưa có admin";

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
                    child: _buildGroupCard(groupName, adminName, groupId),

                  );
                },
              ),

            ),
          ),SizedBox(height: 30,),
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

  Widget _buildGroupCard(String groupName, String adminName, String groupId) {
    return Column(
      children: [
        Card(
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
                      Text(groupName, 
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
                      ),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Text('Admin: '),
                          adminName == "Đang tải..." 
                            ? SizedBox(
                                width: 12,
                                height: 12,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                )
                              )
                            : Text(adminName),
                        ]
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) => _handleMenuSelection(value, groupId),
                  itemBuilder: (BuildContext context) {
                    final isAdmin = _isAdmin(groupId);
                    return [
                      PopupMenuItem(
                        value: 'stats',
                        child: Row(
                          children: [
                            Icon(Icons.bar_chart, color: Colors.blue),
                            SizedBox(width: 8),
                            Text('Xem thống kê'),
                          ],
                        ),
                      ),
                      if (isAdmin)
                        PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, color: Colors.red),
                              SizedBox(width: 8),
                              Text('Xóa nhóm'),
                            ],
                          ),
                        )
                      else
                        PopupMenuItem(
                          value: 'leave',
                          child: Row(
                            children: [
                              Icon(Icons.exit_to_app, color: Colors.orange),
                              SizedBox(width: 8),
                              Text('Rời nhóm'),
                            ],
                          ),
                        ),
                    ];
                  },
                  icon: Icon(Icons.more_vert),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 12),
      ],
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
