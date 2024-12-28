import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../group_main_screen.dart';

class AddMember extends StatefulWidget {
  String? imageBase64;
  final String adminName;
  final String groupName;
  final String groupId;

  AddMember({required this.groupName, required this.groupId, required this.imageBase64,required this.adminName});

  @override
  _AddMemberState createState() => _AddMemberState();
}

class _AddMemberState extends State<AddMember> {
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  final TextEditingController _searchController = TextEditingController();
  final String _url = dotenv.env['ROOT_URL']!;

  List<Map<String, String>> _userSuggestions = [];
  List<Map<String, String>> _selectedUsers = [];
  String _imageBase64 = "";
  List<dynamic> currentGroupMembers = [];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _fetchGroupMembers();
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
      // Kiểm tra xem email đã là thành viên chưa
      bool isExistingMember = currentGroupMembers.any(
        (member) => member['email'].toString().toLowerCase() == email.toLowerCase()
      );

      if (isExistingMember) {
        setState(() {
          _userSuggestions = [];  // Xóa suggestions nếu là thành viên
        });
        
        // Hiển thị thông báo với style mới
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: Colors.white),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Email này đã là thành viên của nhóm!',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
        
        // Xóa text trong search field
        _searchController.clear();
        return;
      }

      // Nếu không phải thành viên, tiếp tục tìm kiếm user
      final String? token = await _secureStorage.read(key: "auth_token");
      final response = await http.get(
        Uri.parse('$_url/auth/user/info?email=$email'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == true && data['data'] != null) {
          setState(() {
            _userSuggestions = [
              {
                "name": data['data']['name'] ?? '',
                "email": email,
                "avatar": data['data']['avatar'] ?? '',
              }
            ];
          });
        } else {
          // Nếu không tìm thấy user
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.white),
                  SizedBox(width: 10),
                  Text('Không tìm thấy người dùng với email này'),
                ],
              ),
              backgroundColor: Colors.grey[700],
              duration: Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
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
      _selectedUsers.add({
        'name': user['name']!,
        'email': user['email']!,
        'avatar': user['avatar'] ?? '',  // Thêm avatar vào thông tin người được chọn
      });
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
        SnackBar(content: Text("Vui lòng chọn thành viên để thêm vào nhóm")),
      );
      return;
    }

    // Đảm bảo tất cả người dùng được thêm vào đều có role là "member"
    final members = _selectedUsers.map((user) => {
      "name": user['name'],
      "email": user['email'],
      "role": "user"  // Đặt role mặc định là user cho người được thêm vào
    }).toList();

    final data = {
      "groupId": widget.groupId,
      "members": members,
    };

    try {
      final String? token = await _secureStorage.read(key: "auth_token");
      
      // Debug log
      print("Adding members with data: ${jsonEncode(data)}");
      
      final response = await http.put(
        Uri.parse('$_url/groups/add-member'),  // Sửa endpoint từ add-member thành add-members
        headers: {
          "Content-Type": "application/json",
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(data),
      );

      // Debug log
      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 10),
                Text("Thêm thành viên thành công!"),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => GroupMainScreen(
              imageBase64: widget.imageBase64,
              groupId: widget.groupId,
              groupName: widget.groupName,
              adminName: widget.adminName,
            ),
          ),
        );
      } else if (responseData['code'] == 706) {
        // Xử lý trường hợp thành viên đã tồn tại
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: Colors.white),
                SizedBox(width: 10),
                Expanded(
                  child: Text(responseData['message'] ?? "Thành viên đã tồn tại trong nhóm"),
                ),
              ],
            ),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      } else {
        // Xử lý các lỗi khác
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.white),
                SizedBox(width: 10),
                Text("Không thể thêm thành viên. Vui lòng thử lại sau."),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (error) {
      print("Error adding members: $error");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error_outline, color: Colors.white),
              SizedBox(width: 10),
              Text("Lỗi khi thêm thành viên: $error"),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _fetchGroupMembers() async {
    try {
      final String? token = await _secureStorage.read(key: "auth_token");
      final response = await http.get(
        Uri.parse('$_url/groups/get-emails-by-group-id/${widget.groupId}'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['code'] == 700) {
          setState(() {
            // Lưu danh sách email vào biến currentGroupMembers
            currentGroupMembers = data['data'].map((email) => {
              'email': email
            }).toList();
          });
        }
      }
    } catch (error) {
      print("Error fetching group members: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,  // Remove back button
        title: Text(
          "Thêm thành viên",
          style: TextStyle(color: Colors.green),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => GroupMainScreen(
                    imageBase64: widget.imageBase64,
                    groupId: widget.groupId,
                    groupName: widget.groupName,
                    adminName: widget.adminName,
                  ),
                ),
              );
            },
            child: Text(
              "Bỏ qua",
              style: TextStyle(color: Colors.grey),
            ),
          ),
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
            if (_selectedUsers.isNotEmpty) ...[  // Chỉ hiển thị khi có người được chọn
              Text(
                "Đã chọn",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              SizedBox(height: 10),
              Wrap(
                spacing: 12.0,
                runSpacing: 12.0,
                children: _selectedUsers.map((user) {
                  return Stack(
                    children: [
                      Column(
                        children: [
                          CircleAvatar(
                            backgroundImage: (user['avatar']?.isEmpty ?? true)
                              ? AssetImage("images/person.png") as ImageProvider
                              : MemoryImage(base64Decode(user['avatar']!)),
                            radius: 30,
                          ),
                          SizedBox(height: 4),
                          Text(
                            user['name'] ?? '',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.black87,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                      Positioned(  // Thêm nút xóa
                        top: -10,
                        right: -10,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.3),
                                spreadRadius: 1,
                                blurRadius: 2,
                              ),
                            ],
                          ),
                          child: InkWell(
                            onTap: () => _removeUser(user),
                            child: CircleAvatar(
                              radius: 12,
                              backgroundColor: Colors.white,
                              child: Icon(
                                Icons.close,
                                size: 16,
                                color: Colors.red,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ],
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
                      avatar: user['avatar'] ?? '',
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
  final String avatar;
  final bool isSelected;

  const ContactItem({
    required this.name,
    required this.avatar,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        radius: 20,
        backgroundImage: (avatar.isEmpty) 
          ? AssetImage("images/person.png") as ImageProvider
          : MemoryImage(base64Decode(avatar)),
      ),
      title: Text(name),
      trailing: Icon(
        isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
        color: isSelected ? Colors.green : Colors.grey,
      ),
    );
  }
}
