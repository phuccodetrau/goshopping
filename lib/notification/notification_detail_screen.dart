import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NotificationDetailScreen extends StatefulWidget {
  final Map<String, dynamic> notification;
  final VoidCallback onRead;

  const NotificationDetailScreen({
    Key? key,
    required this.notification,
    required this.onRead,
  }) : super(key: key);

  @override
  _NotificationDetailScreenState createState() => _NotificationDetailScreenState();
}

class _NotificationDetailScreenState extends State<NotificationDetailScreen> {
  @override
  void initState() {
    super.initState();
    widget.onRead();
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString).toLocal();
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inMinutes < 60) {
        return '${difference.inMinutes} phút trước';
      } else if (difference.inHours < 24) {
        return '${difference.inHours} giờ trước';
      } else if (difference.inDays < 7) {
        return '${difference.inDays} ngày trước';
      } else {
        return DateFormat('HH:mm - dd/MM/yyyy').format(date);
      }
    } catch (e) {
      return dateString;
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
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.1),
        shape: BoxShape.circle,
        border: Border.all(
          color: iconColor.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Icon(iconData, color: iconColor, size: 48),
    );
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

  @override
  Widget build(BuildContext context) {
    final color = _getNotificationColor(widget.notification['type']);
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.green[700],
        elevation: 0,
        title: Text(
          'Chi tiết thông báo',
          style: TextStyle(
            fontSize: 24,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
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
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: SafeArea(
            child: Column(
              children: [
                SizedBox(height: 24),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(24),
                          child: Column(
                            children: [
                              _getNotificationIcon(widget.notification['type']),
                              SizedBox(height: 24),
                              Text(
                                _getNotificationTitle(widget.notification['type']),
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[900],
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 16),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                                    Icon(Icons.access_time, color: Colors.grey[700], size: 18),
                                    SizedBox(width: 8),
                                    Text(
                                      'Nhận lúc: ${DateFormat('HH:mm - dd/MM/yyyy').format(DateTime.parse(widget.notification['createdAt']).toLocal())}',
                                      style: TextStyle(
                                        color: Colors.grey[700],
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.message_outlined, 
                                    color: Colors.green[700],
                                    size: 24,
                                  ),
                                  SizedBox(width: 12),
                                  Text(
                                    'Nội dung thông báo',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey[900],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 16),
                              Container(
                                padding: EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.grey[50],
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.grey[200]!,
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  widget.notification['content'],
                                  style: TextStyle(
                                    fontSize: 16,
                                    height: 1.5,
                                    color: Colors.grey[800],
                                  ),
                                ),
                              ),
                            ],
                          ),
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
    );
  }
} 