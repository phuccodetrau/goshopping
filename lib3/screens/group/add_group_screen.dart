import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/group_provider.dart';
import '../../providers/user_provider.dart';
import 'add_member_screen.dart';

class AddGroupScreen extends StatefulWidget {
  const AddGroupScreen({super.key});

  @override
  State<AddGroupScreen> createState() => _AddGroupScreenState();
}

class _AddGroupScreenState extends State<AddGroupScreen> {
  final TextEditingController _controller = TextEditingController();
  final int _maxChars = 75;
  List<Map<String, String>> _userEmails = [];
  String _email = "";
  int _charCount = 0;

  @override
  void initState() {
    super.initState();
    _initializeUserEmail();
    _controller.addListener(() {
      setState(() {
        _charCount = _controller.text.length;
      });
    });
  }

  Future<void> _initializeUserEmail() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final groupProvider = Provider.of<GroupProvider>(context, listen: false);
    
    final emailUser = userProvider.user?.email ?? '';
    final token = userProvider.user?.token;
    
    if (token != null && emailUser.isNotEmpty) {
      final userName = await groupProvider.getUserNameByEmail(emailUser, token);
      if (userName != null) {
        setState(() {
          _email = emailUser;
          _userEmails = [{
            "name": userName,
            "email": _email,
            "role": "admin"
          }];
        });
      }
    }
  }

  Future<void> _createGroup() async {
    final groupName = _controller.text;
    final groupProvider = Provider.of<GroupProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    
    try {
      final token = userProvider.user?.token;
      if (token == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bạn cần đăng nhập lại')),
        );
        return;
      }

      final data = {
        'name': groupName,
        'listUser': _userEmails,
      };

      final success = await groupProvider.createGroup(token, data);
      if (success && mounted) {
        final groups = await groupProvider.getItemsWithPagination(
          groupId: groupProvider.groups.last.id,
          keyword: "",
          page: 1,
          limit: 10,
        );
        
        if (groups.isNotEmpty && mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddMemberScreen(
                groupName: groupName,
                groupId: groupProvider.groups.last.id,
              ),
            ),
          );
        }
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã xảy ra lỗi khi tạo nhóm.')),
        );
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            _buildHeaderText(),
            const SizedBox(height: 8),
            _buildSubHeaderText(),
            const SizedBox(height: 32),
            _buildImageUploadSection(),
            const SizedBox(height: 32),
            _buildGroupNameInput(),
            const SizedBox(height: 16),
            _buildTermsText(),
            const SizedBox(height: 16),
            _buildNextButton(),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: Colors.grey[700]),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        TextButton(
          onPressed: () {},
          child: Text("Bỏ qua", style: TextStyle(color: Colors.green[800])),
        ),
      ],
    );
  }

  Widget _buildHeaderText() {
    return Text(
      "Tùy chỉnh nhóm của bạn",
      style: TextStyle(
        fontSize: 22,
        color: Colors.green[900],
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildSubHeaderText() {
    return Text(
      "Cá nhân hóa nhóm của bạn bằng cách đặt tên và thêm hình ảnh đại diện.",
      textAlign: TextAlign.center,
      style: TextStyle(color: Colors.grey[700]),
    );
  }

  Widget _buildImageUploadSection() {
    return GestureDetector(
      onTap: () {
        // Add logic for image upload here
      },
      child: Column(
        children: [
          Container(
            height: 100,
            width: 100,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.add_photo_alternate,
              size: 40,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text("Cập nhật hình ảnh", style: TextStyle(color: Colors.green[700])),
        ],
      ),
    );
  }

  Widget _buildGroupNameInput() {
    return TextField(
      controller: _controller,
      maxLength: _maxChars,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.grey[200],
        hintText: "Tên nhóm",
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        counterText: "$_charCount/$_maxChars",
      ),
    );
  }

  Widget _buildTermsText() {
    return Text.rich(
      TextSpan(
        text: "Khi tạo nhóm, nghĩa là bạn đã đồng ý với ",
        style: TextStyle(fontSize: 12, color: Colors.grey[700]),
        children: [
          TextSpan(
            text: "Nguyên tắc cộng đồng",
            style: TextStyle(
              fontSize: 12,
              color: Colors.green[700],
              decoration: TextDecoration.underline,
            ),
          ),
          const TextSpan(text: " của Đi chợ tiện lợi."),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildNextButton() {
    return ElevatedButton(
      onPressed: () {
        if (_userEmails.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Danh sách người dùng trống!")),
          );
          return;
        }
        _createGroup();
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green[700],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 32),
      ),
      child: const Text("Tiếp theo", style: TextStyle(fontSize: 16)),
    );
  }
}
