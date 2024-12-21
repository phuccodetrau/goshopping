import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/group_provider.dart';
import '../home/home_screen.dart';

class AddMemberScreen extends StatefulWidget {
  final String groupName;
  final String groupId;

  const AddMemberScreen({
    Key? key,
    required this.groupName,
    required this.groupId,
  }) : super(key: key);

  @override
  _AddMemberScreenState createState() => _AddMemberScreenState();
}

class _AddMemberScreenState extends State<AddMemberScreen> {
  final TextEditingController _searchController = TextEditingController();
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

  void _onSearchChanged() async {
    final query = _searchController.text;
    if (query.isNotEmpty) {
      try {
        final user = await Provider.of<GroupProvider>(context, listen: false)
            .searchUserByEmail(query);
        setState(() {
          _userSuggestions = user != null ? [user] : [];
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error searching user: $e')),
        );
      }
    } else {
      setState(() {
        _userSuggestions.clear();
      });
    }
  }

  void _selectUser(Map<String, String> user) {
    if (_selectedUsers.any((selectedUser) => selectedUser['email'] == user['email'])) {
      return;
    }

    setState(() {
      _selectedUsers.add(user);
      _userSuggestions.clear();
      _searchController.clear();
    });
  }

  void _removeUser(Map<String, String> user) {
    setState(() {
      _selectedUsers.removeWhere((selectedUser) => selectedUser['email'] == user['email']);
    });
  }

  Future<void> _addMembers() async {
    if (_selectedUsers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn thành viên để thêm vào nhóm')),
      );
      return;
    }

    try {
      final success = await Provider.of<GroupProvider>(context, listen: false)
          .addMembersToGroup(
            groupId: widget.groupId,
            members: _selectedUsers,
          );

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Thêm thành viên thành công!')),
        );
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => const HomeScreen(),
          ),
          (route) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không thể thêm thành viên.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi thêm thành viên: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Thêm thành viên',
          style: TextStyle(color: Colors.green),
        ),
        actions: [
          TextButton(
            onPressed: _addMembers,
            child: const Text(
              'Hoàn tất',
              style: TextStyle(color: Colors.green),
            ),
          ),
        ],
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Nhập Email để tìm kiếm',
                filled: true,
                fillColor: Colors.grey[200],
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: _selectedUsers.map((user) {
                return Stack(
                  children: [
                    const CircleAvatar(
                      backgroundImage: AssetImage('assets/images/group.png'),
                      radius: 30,
                    ),
                    Positioned(
                      right: 0,
                      top: 0,
                      child: GestureDetector(
                        onTap: () => _removeUser(user),
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.close, size: 18, color: Colors.grey),
                        ),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            const Text(
              'Gợi ý',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: _userSuggestions.length,
                itemBuilder: (context, index) {
                  final user = _userSuggestions[index];
                  return ContactItem(
                    name: user['name']!,
                    image: 'assets/images/group.png',
                    isSelected: _selectedUsers.any(
                      (selectedUser) => selectedUser['email'] == user['email'],
                    ),
                    onTap: () => _selectUser(user),
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
  final VoidCallback onTap;

  const ContactItem({
    Key? key,
    required this.name,
    required this.image,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
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
