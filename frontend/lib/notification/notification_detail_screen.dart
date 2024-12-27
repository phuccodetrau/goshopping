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
    // Đánh dấu đã đọc khi màn hình được mở
    widget.onRead();
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('dd/MM/yyyy HH:mm').format(date);
    } catch (e) {
      return dateString;
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
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        iconData,
        color: iconColor,
        size: 32,
      ),
    );
  }

  String _getNotificationTitle(String type) {
    switch (type) {
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
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Chi tiết thông báo',
          style: TextStyle(color: Colors.green[900]),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.green[900]),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon và tiêu đề
              Center(
                child: Column(
                  children: [
                    _getNotificationIcon(widget.notification['type']),
                    SizedBox(height: 16),
                    Text(
                      _getNotificationTitle(widget.notification['type']),
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[900],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24),

              // Thời gian
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.access_time, color: Colors.grey[600]),
                    SizedBox(width: 8),
                    Text(
                      _formatDate(widget.notification['createdAt']),
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24),

              // Nội dung
              Text(
                'Nội dung',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[900],
                ),
              ),
              SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Text(
                  widget.notification['content'],
                  style: TextStyle(
                    fontSize: 16,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 