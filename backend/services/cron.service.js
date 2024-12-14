import cron from 'node-cron';
import { Item, Group } from '../models/schema.js';
import NotificationService from './notification.service.js';

class CronService {
    // Chạy mỗi ngày lúc 0h
    static initExpirationCheck() {
        cron.schedule('0 0 * * *', async () => {
            try {
                // Lấy các item sẽ hết hạn trong 3 ngày tới
                const threeDaysFromNow = new Date();
                threeDaysFromNow.setDate(threeDaysFromNow.getDate() + 3);

                const expiringItems = await Item.find({
                    expireDate: {
                        $gte: new Date(),
                        $lte: threeDaysFromNow
                    }
                });

                // Gửi thông báo cho từng item
                for (const item of expiringItems) {
                    await NotificationService.createExpirationNotification(
                        item.group,
                        item.foodName,
                        item.expireDate
                    );
                }
            } catch (error) {
                console.error('Lỗi khi kiểm tra hạn sử dụng:', error);
            }
        });
    }
}

export default CronService; 