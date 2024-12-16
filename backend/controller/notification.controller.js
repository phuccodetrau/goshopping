import NotificationService from '../services/notification.service.js';

class NotificationController {
    // Lấy danh sách thông báo của user
    static async getNotifications(req, res) {
        try {
            const userId = req.user._id; // Lấy userId từ middleware auth
            const result = await NotificationService.getNotifications(userId);
            res.json(result);
        } catch (error) {
            res.status(500).json({ code: 500, message: "Lỗi server", error: error.message });
        }
    }

    // Đánh dấu thông báo đã đọc
    static async markAsRead(req, res) {
        try {
            const { notificationId } = req.params;
            const result = await NotificationService.markAsRead(notificationId);
            res.json(result);
        } catch (error) {
            res.status(500).json({ code: 500, message: "Lỗi server", error: error.message });
        }
    }

    // Đánh dấu tất cả thông báo đã đọc
    static async markAllAsRead(req, res) {
        try {
            const userId = req.user._id;
            const result = await NotificationService.markAllAsRead(userId);
            res.json(result);
        } catch (error) {
            res.status(500).json({ code: 500, message: "Lỗi server", error: error.message });
        }
    }

    // Xóa thông báo
    static async deleteNotification(req, res) {
        try {
            const { notificationId } = req.params;
            const result = await NotificationService.deleteNotification(notificationId);
            res.json(result);
        } catch (error) {
            res.status(500).json({ code: 500, message: "Lỗi server", error: error.message });
        }
    }
}

export default NotificationController; 