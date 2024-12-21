import { Notification, User, Group } from "../models/schema.js";
import mongoose from "mongoose";
import axios from 'axios';

class NotificationService {
    // Thêm hàm gửi thông báo push qua OneSignal
    static async sendPushNotification(userIds, title, content) {
        try {
            const users = await User.find({ _id: { $in: userIds } });
            console.log('Found users:', users.map(u => ({
                email: u.email,
                deviceToken: u.deviceToken
            })));

            const playerIds = users
                .map(user => user.deviceToken)
                .filter(token => token != null && token !== '');

            console.log('Valid player IDs:', playerIds);

            if (playerIds.length > 0) {
                try {
                    const payload = {
                        app_id: process.env.ONESIGNAL_APP_ID,
                        include_player_ids: playerIds,
                        contents: { en: content },
                        headings: { en: title },
                        priority: 10,
                        // Thêm các thông số để debug
                        data: {
                            type: "notification",
                            timestamp: new Date().toISOString()
                        }
                    };

                    console.log('Sending notification with payload:', {
                        ...payload,
                        include_player_ids: playerIds
                    });

                    const apiKey = process.env.ONESIGNAL_REST_API_KEY;
                    const response = await axios.post(
                        'https://onesignal.com/api/v1/notifications',
                        payload,
                        {
                            headers: {
                                'Authorization': `Basic ${apiKey}`,
                                'Content-Type': 'application/json',
                                'Accept': 'application/json'
                            }
                        }
                    );

                    console.log('OneSignal API Response:', response.data);
                    return response.data;
                } catch (error) {
                    if (error.response) {
                        console.error('OneSignal Error Response:', {
                            status: error.response.status,
                            data: error.response.data
                        });
                        
                        // Xử lý các loại lỗi cụ thể
                        if (error.response.status === 400) {
                            console.error('Bad request. Please check the payload format.');
                        } else if (error.response.status === 403) {
                            console.error('Authentication failed. Please check your OneSignal API key configuration.');
                        }
                    }
                    console.error('Error sending OneSignal notification:', error.message);
                    return null;
                }
            } else {
                console.log('No valid device tokens found for users:', userIds);
                return null;
            }
        } catch (error) {
            console.error('Error in sendPushNotification:', error);
            return null;
        }
    }

    // Tạo thông báo cho một user
    static async createNotification(userId, type, content) {
        try {
            const notification = new Notification({
                user: userId,
                type,
                content,
                isRead: false
            });
            await notification.save();
            return { code: 800, message: "Tạo thông báo thành công", data: notification };
        } catch (error) {
            console.error("Lỗi khi tạo thông báo:", error);
            throw error;
        }
    }

    // Tạo thông báo cho nhiều user (ví dụ: thông báo cho cả nhóm)
    static async createNotificationForMany(userIds, type, content) {
        try {
            // Tạo notifications trong database
            const notifications = userIds.map(userId => ({
                user: userId,
                type,
                content,
                isRead: false
            }));
            
            const createdNotifications = await Notification.insertMany(notifications);

            // Bỏ comment phần gửi push notification
            try {
                await this.sendPushNotification(
                    userIds,
                    this.getNotificationTitle(type),
                    content
                );
            } catch (error) {
                console.error("Push notification failed but continuing:", error);
            }

            return { 
                code: 800, 
                message: "Tạo thông báo thành công", 
                data: createdNotifications 
            };
        } catch (error) {
            console.error("Error in createNotificationForMany:", error);
            throw error;
        }
    }
    
    // Hàm helper để lấy tiêu đề thông báo dựa vào type
    static getNotificationTitle(type) {
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
                return 'Thông báo mới';
        }
    }

    // Lấy danh sách thông báo của một user
    static async getNotifications(userId) {
        try {
            console.log("Fetching notifications for userId:", userId); // Debug log

            // Convert string ID to ObjectId if needed
            const userObjectId = mongoose.Types.ObjectId(userId);
            
            const notifications = await Notification.find({ 
                user: userObjectId 
            }).sort({ createdAt: -1 }); // Sắp xếp theo thời gian mới nhất

            console.log("Found notifications:", notifications); // Debug log

            return { 
                code: 801, 
                message: "Lấy danh sách thông báo thành công", 
                data: notifications 
            };
        } catch (error) {
            console.error("Error in getNotifications:", error);
            throw error;
        }
    }

    // Đánh dấu thông báo đã đọc
    static async markAsRead(notificationId) {
        try {
            const notification = await Notification.findByIdAndUpdate(
                notificationId,
                { isRead: true },
                { new: true }
            );
            return { code: 802, message: "Đánh dấu đã đ��c thành công", data: notification };
        } catch (error) {
            console.error("Lỗi khi đánh dấu đã đọc:", error);
            throw error;
        }
    }

    // Đánh dấu tất cả thông báo của user đã đọc
    static async markAllAsRead(userId) {
        try {
            await Notification.updateMany(
                { user: userId, isRead: false },
                { isRead: true }
            );
            return { code: 803, message: "Đánh dấu tất cả đã đọc thành công" };
        } catch (error) {
            console.error("Lỗi khi đánh dấu tất cả đã đọc:", error);
            throw error;
        }
    }

    // Xóa thông báo
    static async deleteNotification(notificationId) {
        try {
            await Notification.findByIdAndDelete(notificationId);
            return { code: 804, message: "Xóa thông báo thành công" };
        } catch (error) {
            console.error("Lỗi khi xóa thông báo:", error);
            throw error;
        }
    }

    // Tạo thông báo cho nhóm về item sắp hết hạn
    static async createExpirationNotification(groupId, itemName, expirationDate) {
        try {
            const group = await Group.findById(groupId);
            if (!group) {
                throw new Error("Không tìm thấy nhóm");
            }

            const userIds = group.listUser.map(user => user._id);
            const content = `Sản phẩm ${itemName} trong nhóm ${group.name} sắp hết hạn vào ngày ${expirationDate}`;
            
            return await this.createNotificationForMany(userIds, "expiration_alert", content);
        } catch (error) {
            console.error("Lỗi khi tạo thông báo hết hạn:", error);
            throw error;
        }
    }

    // Tạo thông báo khi người dùng rời nhóm
    static async createLeaveGroupNotification(groupId, leavingUserEmail) {
        try {
            const group = await Group.findById(groupId);
            if (!group) {
                throw new Error("Không tìm thấy nhóm");
            }

            const userIds = group.listUser.map(user => user._id);
            const content = `Người dùng ${leavingUserEmail} đã rời khỏi nhóm ${group.name}`;
            
            return await this.createNotificationForMany(userIds, "member_left", content);
        } catch (error) {
            console.error("Lỗi khi tạo thông báo rời nhóm:", error);
            throw error;
        }
    }

    // Thêm log cho hàm deleteGroup trong GroupService
    static async deleteGroup(groupId, userEmail) {
        try {
            const group = await Group.findById(groupId);
            if (!group) {
                return { code: 404, message: "Không tìm thấy nhóm", data: "" };
            }

            // Lấy danh sách user IDs trước khi xóa nhóm
            const users = await User.find({ 
                email: { $in: group.listUser.map(u => u.email) } 
            });
            const userIds = users.map(user => user._id);

            console.log("Users to notify:", users);
            console.log("UserIds for notification:", userIds);

            // Gửi thông báo cho tất cả thành viên
            try {
                await NotificationService.createNotificationForMany(
                    userIds,
                    'group_deleted',
                    `Nhóm "${group.name}" đã bị xóa bởi admin ${userEmail}`
                );
                console.log("Notification sent successfully");
            } catch (error) {
                console.error("Error sending delete notification:", error);
            }

            // Xóa nhóm
            await Group.findByIdAndDelete(groupId);

            return { code: 700, message: "Xóa nhóm thành công", data: group };
        } catch (error) {
            console.error('Error deleting group:', error);
            throw error;
        }
    }

    // Tạo thông báo cho task được giao
    static async createTaskNotification(memberEmail, taskName, type = 'task_assigned') {
        try {
            // Tìm user dựa trên email
            const user = await User.findOne({ email: memberEmail });
            if (!user) {
                throw new Error('User not found');
            }

            let title, content;
            if (type === 'task_assigned') {
                title = 'Nhiệm vụ mới';
                content = `Bạn được giao nhiệm vụ mới: ${taskName}`;
            } else if (type === 'task_updated') {
                title = 'Cập nhật nhiệm vụ';
                content = `Nhiệm vụ của bạn đã được cập nhật: ${taskName}`;
            }

            // Gửi push notification
            await this.sendPushNotification([user._id], title, content);

            // Tạo notification trong database
            return await this.createNotification(user._id, type, content);
        } catch (error) {
            console.error('Error in createTaskNotification:', error);
            throw error;
        }
    }
}

export default NotificationService; 