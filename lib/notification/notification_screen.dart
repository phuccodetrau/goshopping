import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_shopping/home_screen/home_screen.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'notification_detail_screen.dart';
import '../user/user_info.dart';


class NotificationScreen extends StatefulWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final _secureStorage = FlutterSecureStorage();
  final String _url = dotenv.env['ROOT_URL']!;
  List<dynamic> notifications = [];
  bool isLoading = true;
  String? userId;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    await _getUserId();
    await _fetchNotifications();
  }

  Future<void> _getUserId() async {
    try {
      final String? token = await _secureStorage.read(key: "auth_token");
      final String? email = await _secureStorage.read(key: "email");
      
      if (email == null) {
        throw Exception("Email not found");
      }

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
            userId = data['data']['_id'];
          });
          print("Got user ID: $userId"); // Debug log
        }
      }
    } catch (error) {
      print("Error getting user ID: $error");
    }
  }

  Future<void> _fetchNotifications() async {
    if (userId == null) {
      print("No user ID available");
      return;
    }

    try {
      setState(() {
        isLoading = true;
      });

      final String? token = await _secureStorage.read(key: "auth_token");
      final response = await http.get(
        Uri.parse('$_url/api/notifications'),
        headers: {
          'Authorization': 'Bearer $token',
          'User-ID': userId!,
        },
      );

      print("Notifications response: ${response.body}"); // Debug log

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['code'] == 801) {
          setState(() {
            notifications = data['data'];
          });
        }
      }
    } catch (error) {
      print("Error fetching notifications: $error");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi tải thông báo'))
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inMinutes < 60) {
        return '${difference.inMinutes} phút trước';
      } else if (difference.inHours < 24) {
        return '${difference.inHours} giờ trước';
      } else if (difference.inDays < 7) {
        return '${difference.inDays} ngày trước';
      } else {
        return DateFormat('dd/MM/yyyy HH:mm').format(date);
      }
    } catch (e) {
      return dateString;
    }
  }

  Future<void> _markAllAsRead() async {
    try {
      final String? token = await _secureStorage.read(key: "auth_token");
      final response = await http.put(
        Uri.parse('$_url/api/notifications/read-all'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        await _fetchNotifications();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Đã đánh dấu tất cả là đã đọc'))
        );
      }
    } catch (error) {
      print("Error marking all as read: $error");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi đánh dấu đã đọc'))
      );
    }
  }

  Widget _getNotificationIcon(String type) {
    IconData iconData;
    Color iconColor;

    switch (type) {
      case 'task_assigned':
        iconData = Icons.assignment_add;
        iconColor = Colors.blue[600]!;
        break;
      case 'task_updated':
        iconData = Icons.update;
        iconColor = Colors.orange[600]!;
        break;
      case 'expiration_alert':
        iconData = Icons.warning_amber_rounded;
        iconColor = Colors.red[600]!;
        break;
      case 'member_left':
        iconData = Icons.person_remove;
        iconColor = Colors.red[400]!;
        break;
      case 'group_created':
        iconData = Icons.group_add;
        iconColor = Colors.green[600]!;
        break;
      case 'group_joined':
        iconData = Icons.person_add;
        iconColor = Colors.green[400]!;
        break;
      case 'group_deleted':
        iconData = Icons.delete_forever;
        iconColor = Colors.red[700]!;
        break;
      case 'members_added':
        iconData = Icons.group_add;
        iconColor = Colors.blue[400]!;
        break;
      default:
        iconData = Icons.notifications;
        iconColor = Colors.grey[600]!;
    }

    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.1),
        shape: BoxShape.circle,
        border: Border.all(
          color: iconColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Icon(iconData, color: iconColor, size: 24),
    );
  }

  Color _getNotificationColor(String type) {
    switch (type) {
      case 'task_assigned':
        return Colors.blue[600]!;
      case 'task_updated':
        return Colors.orange[600]!;
      case 'expiration_alert':
        return Colors.red[600]!;
      case 'member_left':
        return Colors.red[400]!;
      case 'group_created':
      case 'group_joined':
        return Colors.green[600]!;
      case 'group_deleted':
        return Colors.red[700]!;
      case 'members_added':
        return Colors.blue[400]!;
      default:
        return Colors.grey[600]!;
    }
  }

  void _onItemTapped(int index) {
    if (index == 0) {  // Home tab
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) =>HomeScreen()),
      );
    } else if (index == 2) {  // Profile tab
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => PersonalInfoScreen()),
      );
    }
  }

  String _getNotificationTitle(String type) {
    switch (type) {
      case 'task_assigned':
        return 'Nhiệm vụ mua sắm mới';
      case 'task_updated':
        return 'Cập nhật nhiệm vụ';
      case 'expiration_alert':
        return 'Cảnh báo hết hạn';
      case 'member_left':
        return 'Thành viên rời nhóm';
      case 'group_created':
        return 'Tạo nhóm mới';
      case 'group_joined':
        return 'Tham gia nhóm';
      case 'group_deleted':
        return 'Xóa nhóm';
      case 'members_added':
        return 'Thêm thành viên mới';
      default:
        return 'Thông báo';
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context);
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.green[700],
          elevation: 0,
          title: Text(
            'Thông báo',
            style: TextStyle(
              fontSize: 24,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            if (notifications.isNotEmpty)
              Padding(
                padding: EdgeInsets.only(right: 16),
                child: TextButton.icon(
                  onPressed: _markAllAsRead,
                  icon: Icon(Icons.done_all, color: Colors.white, size: 20),
                  label: Text(
                    'Đánh dấu đã đọc',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.2),
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ),
          ],
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.green[700]!.withOpacity(0.9),
                Colors.green[600]!.withOpacity(0.7),
                Colors.green[500]!.withOpacity(0.3),
                Colors.white,
              ],
              stops: [0.0, 0.3, 0.5, 0.7],
            ),
          ),
          child: isLoading
            ? Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : RefreshIndicator(
                onRefresh: _fetchNotifications,
                color: Colors.green[700],
                child: notifications.isEmpty
                  ? _buildEmptyState()
                  : _buildNotificationList(),
              ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: 1,
          selectedItemColor: Colors.green[700],
          unselectedItemColor: Colors.grey,
          onTap: _onItemTapped,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
            BottomNavigationBarItem(icon: Icon(Icons.notifications), label: ''),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: ''),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 120),
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Icon(
              Icons.notifications_none_outlined,
              size: 60,
              color: Colors.grey[400],
            ),
          ),
          SizedBox(height: 24),
          Text(
            'Chưa có thông báo nào',
            style: TextStyle(
              color: Colors.grey[800],
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Kéo xuống để làm mới',
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationList() {
    return ListView.builder(
      physics: AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: notifications.length,
      itemBuilder: (context, index) {
        final notification = notifications[index];
        final bool isRead = notification['isRead'] ?? false;
        final String type = notification['type'] ?? '';
        final Color iconColor = _getNotificationColor(type);

        return Dismissible(
          key: Key(notification['_id']),
          background: Container(
            margin: EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: Colors.red[400],
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.centerRight,
            padding: EdgeInsets.only(right: 20),
            child: Icon(Icons.delete_sweep, color: Colors.white, size: 28),
          ),
          direction: DismissDirection.endToStart,
          onDismissed: (direction) async {
            try {
              final String? token = await _secureStorage.read(key: "auth_token");
              await http.delete(
                Uri.parse('$_url/api/notifications/${notification['_id']}'),
                headers: {
                  'Authorization': 'Bearer $token',
                },
              );
              setState(() {
                notifications.removeAt(index);
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      Icon(Icons.check_circle_outline, color: Colors.white),
                      SizedBox(width: 8),
                      Text('Đã xóa thông báo'),
                    ],
                  ),
                  backgroundColor: Colors.green[700],
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  margin: EdgeInsets.all(16),
                ),
              );
            } catch (error) {
              print("Error deleting notification: $error");
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.white),
                      SizedBox(width: 8),
                      Text('Không thể xóa thông báo'),
                    ],
                  ),
                  backgroundColor: Colors.red[400],
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  margin: EdgeInsets.all(16),
                ),
              );
            }
          },
          child: Card(
            elevation: 2,
            margin: EdgeInsets.symmetric(vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: !isRead ? Border.all(color: Colors.green[700]!, width: 2) : null,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => NotificationDetailScreen(
                        notification: notification,
                        onRead: () async {
                          if (!isRead) {
                            try {
                              final String? token = await _secureStorage.read(key: "auth_token");
                              await http.put(
                                Uri.parse('$_url/api/notifications/${notification['_id']}/read'),
                                headers: {
                                  'Authorization': 'Bearer $token',
                                },
                              );
                              await _fetchNotifications();
                            } catch (error) {
                              print("Error marking as read: $error");
                            }
                          }
                        },
                      ),
                    ),
                  );
                },
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              _getNotificationTitle(type),
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.green[800],
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: isRead ? Colors.grey[100] : Colors.green[50],
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isRead ? Colors.grey[300]! : Colors.green[100]!,
                                width: 1,
                              ),
                            ),
                            child: Text(
                              isRead ? 'Đã đọc' : 'Chưa đọc',
                              style: TextStyle(
                                color: isRead ? Colors.grey[600] : Colors.green[700],
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Divider(color: Colors.grey[200], thickness: 1, height: 20),
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.grey[200]!,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            _getNotificationIcon(type),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                notification['content'],
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.grey[800],
                                  height: 1.4,
                                ),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 12),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.grey[300]!,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 16,
                              color: Colors.grey[600],
                            ),
                            SizedBox(width: 4),
                            Text(
                              _formatDate(notification['createdAt']),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
} 