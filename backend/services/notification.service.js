import { Notification, User, Group } from "../models/schema.js";
import mongoose from "mongoose";

class NotificationService {
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
            console.log("Creating notifications for users:", userIds, "type:", type); // Debug log
            
            const notifications = userIds.map(userId => ({
                user: userId,
                type,
                content,
                isRead: false
            }));
            
            const createdNotifications = await Notification.insertMany(notifications);
            console.log("Created notifications:", createdNotifications); // Debug log

            return { 
                code: 800, 
                message: "Tạo thông báo cho nhiều người dùng thành công", 
                data: createdNotifications 
            };
        } catch (error) {
            console.error("Lỗi khi tạo thông báo cho nhiều người:", error);
            throw error;
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
            return { code: 802, message: "Đánh dấu đã đọc thành công", data: notification };
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
            const content = `Sản phẩm ${itemName} trong nhóm ${group.name} sẽ hết hạn vào ngày ${expirationDate}`;
            
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
}

export default NotificationService; 