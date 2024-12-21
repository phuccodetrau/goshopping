import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/group_provider.dart';
import '../notification/notification_list_screen.dart';
import '../user/user_info_screen.dart';
import '../group/add_group_screen.dart';
import '../group/group_main_screen.dart';
import '../statistics/statistics_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  int _selectedIndex = 0;
  Map<String, String> adminNames = {};

  @override
  void initState() {
    super.initState();
    _initializeData();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _initializeData() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final groupProvider = Provider.of<GroupProvider>(context, listen: false);
    
    if (userProvider.user?.email != null) {
      await groupProvider.fetchUserGroups(userProvider.user!.email);
      
      // Initialize adminNames
      for (var group in groupProvider.groups) {
        final admins = group.listUser
            .where((user) => user.role == 'admin')
            .map((user) => user.name)
            .toList();
        adminNames[group.id] = admins.join(", ");
      }
    }
  }

  void _onSearchChanged() {
    final groupProvider = Provider.of<GroupProvider>(context, listen: false);
    final query = _searchController.text.toLowerCase();
    groupProvider.filterGroups(query);
  }

  bool _isAdmin(String groupId) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final group = Provider.of<GroupProvider>(context, listen: false)
        .groups
        .firstWhere((g) => g.id == groupId);
        
    if (group == null || userProvider.user == null) return false;

    return group.listUser.any((user) => 
      user.email == userProvider.user!.email && user.role == 'admin'
    );
  }

  void _handleMenuSelection(String value, String groupId) async {
    final groupProvider = Provider.of<GroupProvider>(context, listen: false);
    
    switch (value) {
      case 'delete':
        if (_isAdmin(groupId)) {
          _confirmDeleteGroup(groupId);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Bạn không có quyền xóa nhóm này'))
          );
        }
        break;
      case 'leave':
        if (!_isAdmin(groupId)) {
          _confirmLeaveGroup(groupId);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Admin không thể rời nhóm. Vui lòng chỉ định admin mới hoặc xóa nhóm'))
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
          title: const Text('Xác nhận xóa'),
          content: const Text('Bạn có chắc chắn muốn xóa nhóm này?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                final groupProvider = Provider.of<GroupProvider>(context, listen: false);
                final success = await groupProvider.deleteGroup(groupId);
                
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Xóa nhóm thành công'))
                  );
                }
              },
              child: const Text('Xóa'),
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
          title: const Text('Xác nhận rời nhóm'),
          content: const Text('Bạn có chắc chắn muốn rời nhóm này?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                final groupProvider = Provider.of<GroupProvider>(context, listen: false);
                final success = await groupProvider.leaveGroup(groupId);
                
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Rời nhóm thành công'))
                  );
                }
              },
              child: const Text('Rời nhóm'),
            ),
          ],
        );
      },
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const NotificationListScreen()),
        );
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const UserInfoScreen()),
        );
        break;
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
        'Nhóm đã tham gia',
        style: TextStyle(fontSize: 24, color: Colors.green[900], fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildBody() {
    return Consumer<GroupProvider>(
      builder: (context, groupProvider, child) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildSearchBar(),
              SizedBox(height: 16),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    final userProvider = Provider.of<UserProvider>(context, listen: false);
                    if (userProvider.user?.email != null) {
                      await groupProvider.fetchUserGroups(userProvider.user!.email);
                    }
                  },
                  child: ListView.builder(
                    itemCount: groupProvider.filteredGroups.length,
                    itemBuilder: (context, index) {
                      final group = groupProvider.filteredGroups[index];
                      final adminName = adminNames[group.id] ?? "Chưa có admin";

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => GroupMainScreen(
                                groupId: group.id,
                                groupName: group.name,
                                adminName: adminName,
                              ),
                            ),
                          );
                        },
                        child: _buildGroupCard(group.name, adminName, group.id),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
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
              decoration: InputDecoration(
                hintText: 'Tìm kiếm nhóm', 
                border: InputBorder.none
              ),
            ),
          ),
          Icon(Icons.search, color: Colors.grey),
        ],
      ),
    );
  }

  Widget _buildGroupCard(String groupName, String adminName, String groupId) {
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
                  Text(
                    groupName, 
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
