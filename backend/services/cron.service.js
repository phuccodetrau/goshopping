import cron from 'node-cron';
import { Item, Group, User } from '../models/schema.js';
import NotificationService from './notification.service.js';

class CronService {
    // Chạy mỗi ngày lúc 11:50 theo giờ Việt Nam
    static initExpirationCheck() {
        cron.schedule('47 23 * * *', async () => {
            try {
                // Lấy các item sẽ hết hạn trong 3 ngày tới
                const threeDaysFromNow = new Date();
                threeDaysFromNow.setDate(threeDaysFromNow.getDate() + 3);
                const today = new Date();

                const expiringItems = await Item.find({
                    expireDate: {
                        $gte: today,
                        $lte: threeDaysFromNow
                    }
                }).populate('group');

                // Nhóm các item theo group để gửi thông báo gộp
                const groupedItems = {};
                
                // Phân loại items theo group
                expiringItems.forEach(item => {
                    if (item.group && item.group._id) {
                        const groupId = item.group._id.toString();
                        if (!groupedItems[groupId]) {
                            groupedItems[groupId] = {
                                groupName: item.group.name,
                                items: [],
                                userEmails: item.group.listUser.map(u => u.email)
                            };
                        }
                        groupedItems[groupId].items.push({
                            foodName: item.foodName,
                            expireDate: item.expireDate,
                            daysUntilExpiration: Math.ceil(
                                (item.expireDate - today) / (1000 * 60 * 60 * 24)
                            )
                        });
                    }
                });

                // Gửi thông báo cho từng group
                for (const groupId in groupedItems) {
                    const groupData = groupedItems[groupId];
                    
                    // Tạo nội dung thông báo gộp cho group
                    let notificationContent = `Danh sách thực phẩm sắp hết hạn trong tủ lạnh của nhóm "${groupData.groupName}":\n\n`;
                    groupData.items.forEach(item => {
                        notificationContent += `- ${item.foodName}: còn ${item.daysUntilExpiration} ngày (${new Date(item.expireDate).toLocaleDateString('vi-VN')})\n`;
                    });

                    try {
                        // Tìm user IDs từ emails
                        const users = await User.find({ 
                            email: { $in: groupData.userEmails } 
                        });
                        
                        const userIds = users.map(user => user._id);

                        // Tạo notifications trong database
                        await NotificationService.createNotificationForMany(
                            userIds,
                            'expiration_alert',
                            notificationContent
                        );

                        // Gửi push notification qua OneSignal (vẫn dùng email)
                        await NotificationService.sendPushNotification(
                            groupData.userEmails, // OneSignal dùng email
                            'Cảnh báo thực phẩm sắp hết hạn',
                            notificationContent
                        );

                        console.log(`Đã gửi thông báo thành công cho nhóm ${groupData.groupName}`);
                    } catch (error) {
                        console.error(`Lỗi khi gửi thông báo cho nhóm ${groupData.groupName}:`, error);
                    }
                }
            } catch (error) {
                console.error('Lỗi khi kiểm tra hạn sử dụng:', error);
            }
        }, {
            scheduled: true,
            timezone: "Asia/Ho_Chi_Minh"
        });
    }
}

export default CronService; 