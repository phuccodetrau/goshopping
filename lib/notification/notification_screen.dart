import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'notification_detail_screen.dart';

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
      case 'expiration_alert':
        iconData = Icons.warning;
        iconColor = Colors.orange;
        break;
      case 'member_left':
        iconData = Icons.person_remove;
        iconColor = Colors.red;
        break;
      case 'group_created':
        iconData = Icons.group_add;
        iconColor = Colors.green;
        break;
      case 'group_joined':
        iconData = Icons.person_add;
        iconColor = Colors.green;
        break;
      case 'group_deleted':
        iconData = Icons.delete_forever;
        iconColor = Colors.red;
        break;
      case 'members_added':
        iconData = Icons.group_add;
        iconColor = Colors.blue;
        break;
      default:
        iconData = Icons.notifications;
        iconColor = Colors.grey;
    }

    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(iconData, color: iconColor),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Thông báo',
          style: TextStyle(color: Colors.green[900]),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.green[900]),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          if (notifications.isNotEmpty)
            IconButton(
              icon: Icon(Icons.done_all, color: Colors.green[900]),
              onPressed: _markAllAsRead,
              tooltip: 'Đánh dấu tất cả đã đọc',
            ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchNotifications,
              child: notifications.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.notifications_none, 
                            size: 64, 
                            color: Colors.grey
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Không có thông báo nào',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: notifications.length,
                      itemBuilder: (context, index) {
                        final notification = notifications[index];
                        final bool isRead = notification['isRead'] ?? false;

                        return Dismissible(
                          key: Key(notification['_id']),
                          background: Container(
                            color: Colors.red,
                            alignment: Alignment.centerRight,
                            padding: EdgeInsets.only(right: 20.0),
                            child: Icon(Icons.delete, color: Colors.white),
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
                            } catch (error) {
                              print("Error deleting notification: $error");
                            }
                          },
                          child: Card(
                            color: isRead ? Colors.white : Colors.green[50],
                            child: ListTile(
                              leading: _getNotificationIcon(notification['type']),
                              title: Text(
                                notification['content'],
                                style: TextStyle(
                                  fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                _formatDate(notification['createdAt']),
                                style: TextStyle(fontSize: 12),
                              ),
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
                            ),
                          ),
                        );
                      },
                    ),
            ),
    );
  }
} 