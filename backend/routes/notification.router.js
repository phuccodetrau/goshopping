import { Router } from 'express';
import NotificationController from '../controller/notification.controller.js';
import authMiddleware from '../middleware/auth.js';

const router = Router();

router.use(authMiddleware);

router.get('/notifications', NotificationController.getNotifications);
router.put('/notifications/:notificationId/read', NotificationController.markAsRead);
router.put('/notifications/read-all', NotificationController.markAllAsRead);
router.delete('/notifications/:notificationId', NotificationController.deleteNotification);

export default router; 