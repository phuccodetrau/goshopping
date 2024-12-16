import { Router } from 'express';
import NotificationController from '../controller/notification.controller.js';
import authMiddleware from '../middleware/auth.js';

const router = Router();

// Tất cả các routes đều cần authentication
router.use(authMiddleware);

// Lấy danh sách thông báo
router.get('/notifications', NotificationController.getNotifications);

// Đánh dấu đã đọc một thông báo
router.put('/notifications/:notificationId/read', NotificationController.markAsRead);

// Đánh dấu tất cả thông báo đã đọc
router.put('/notifications/read-all', NotificationController.markAllAsRead);

// Xóa một thông báo
router.delete('/notifications/:notificationId', NotificationController.deleteNotification);

export default router; 