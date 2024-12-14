import { Group, User } from '../models/schema.js';
import NotificationService from './notification.service.js';

class GroupService {
    static async createGroup(name, listUser) {
        try {
            const newGroup = new Group({
                name,
                listUser,
                refrigerator: []
            });

            const savedGroup = await newGroup.save();

            // Lấy danh sách email của các thành viên
            const emails = listUser.map(user => user.email);
            
            // Tìm các user trong database dựa trên email
            const users = await User.find({ email: { $in: emails } });
            
            // Lấy user IDs
            const userIds = users.map(user => user._id);
            console.log("Creating notifications for users:", userIds); // Debug log

            // Tạo thông báo cho tất cả thành viên trong nhóm
            if (userIds.length > 0) {
                const notificationResult = await NotificationService.createNotificationForMany(
                    userIds,
                    'group_created',
                    `Bạn đã được thêm vào nhóm "${name}"`
                );
                console.log("Notification creation result:", notificationResult); // Debug log
            }

            return { code: 700, message: "Tạo nhóm thành công", data: savedGroup };
        } catch (error) {
            console.error('Lỗi khi tạo nhóm:', error);
            throw { code: 101, message: "Server error!", data: "" };
        }
    }

    static async addMembers(groupId, members) {
        try {
            const group = await Group.findById(groupId);
            if (!group) {
                return { code: 703, message: "Không tìm thấy nhóm để thêm thành viên", data: "" };
            }

            const newMembers = members.filter(member =>
                !group.listUser.some(existingMember => existingMember.email === member.email)
            );

            if (newMembers.length === 0) {
                return { code: 706, message: "Tất cả thành viên đã có trong nhóm", data: "" };
            }

            const updatedGroup = await Group.findByIdAndUpdate(
                groupId,
                { $addToSet: { listUser: { $each: newMembers } } },
                { new: true }
            );

            // Lấy danh sách email của thành viên mới
            const newMemberEmails = newMembers.map(member => member.email);
            
            // T��m users trong database
            const newUsers = await User.find({ email: { $in: newMemberEmails } });
            const existingUsers = await User.find({ 
                email: { 
                    $in: group.listUser
                        .filter(user => !newMemberEmails.includes(user.email))
                        .map(user => user.email) 
                } 
            });

            // Tạo thông báo cho các thành viên mới
            if (newUsers.length > 0) {
                await NotificationService.createNotificationForMany(
                    newUsers.map(user => user._id),
                    'group_joined',
                    `Bạn đã được thêm vào nhóm "${group.name}"`
                );
            }

            // Tạo thông báo cho các thành viên hiện tại
            if (existingUsers.length > 0) {
                const newMemberNames = newMembers.map(member => member.name).join(', ');
                await NotificationService.createNotificationForMany(
                    existingUsers.map(user => user._id),
                    'members_added',
                    `${newMemberNames} đã được thêm vào nhóm "${group.name}"`
                );
            }

            return { code: 702, message: "Thêm thành viên thành công", data: updatedGroup };
        } catch (error) {
            console.error('Lỗi khi thêm danh sách thành viên:', error);
            throw { code: 101, message: "Server error!", data: "" };
        }
    }

    static async getGroupsByMemberEmail(email) {
        try {
            // Tìm các nhóm mà user là thành viên và lấy đầy đủ thông tin
            const groups = await Group.find(
                { "listUser.email": email },
                { name: 1, listUser: 1 } // Lấy name và listUser
            );

            if (groups.length === 0) {
                return { code: 704, message: "Không tìm thấy nhóm nào với email này", data: [] };
            }

            // Tạo danh sách với đầy đủ thông tin cần thiết
            const groupDetails = groups.map(group => ({
                id: group._id,
                name: group.name,
                listUser: group.listUser // Thêm listUser vào response
            }));

            return { code: 700, message: "Lấy danh sách nhóm thành công", data: groupDetails };
        } catch (error) {
            console.error('Lỗi khi lấy danh sách nhóm theo email:', error);
            throw { code: 101, message: "Server error!", data: "" };
        }
    }

    static async getAdminsByGroupId(groupId) {
        try {
            const group = await Group.findById(groupId);
            if (!group) {
                return { code: 704, message: "Không tìm thấy nhóm với ID này", data: [] };
            }

            // Lấy danh sách email của admin
            const adminEmails = group.listUser
                .filter(user => user.role === "admin")
                .map(admin => admin.email);

            // Lấy thông tin mới nhất của các admin từ User collection
            const adminUsers = await User.find(
                { email: { $in: adminEmails } },
                { name: 1, email: 1 }
            );

            // Map email với tên mới nhất
            const adminNames = adminUsers.map(user => user.name);

            if (adminNames.length === 0) {
                return { code: 705, message: "Không có admin trong nhóm này", data: [] };
            }

            return { code: 700, message: "Lấy danh sách admin thành công", data: adminNames };
        } catch (error) {
            console.error('Lỗi khi lấy danh sách admin:', error);
            throw { code: 101, message: "Server error!", data: "" };
        }
    }
    
    static async getUsersByGroupName(groupName) {
        try {
            // Tìm nhóm theo tên
            const group = await Group.findOne({ name: groupName });

            if (!group) {
                return { code: 704, message: "Group not found", data: [] };
            }

            // Trích xuất danh sách email
            const emails = group.listUser.map(user => user.email);

            return { code: 700, message: "Emails retrieved successfully", data: emails };
        } catch (error) {
            console.error('Error fetching emails by group name:', error);
            throw { code: 101, message: "Server error!", data: "" };
        }
    }

    static async deleteGroup(groupId, userEmail) {
        try {
            const group = await Group.findById(groupId);
            if (!group) {
                return { 
                    code: 404, 
                    message: "Không tìm thấy nhóm", 
                    data: "" 
                };
            }

            // Kiểm tra quyền admin
            const isAdmin = group.listUser.some(
                user => user.email === userEmail && user.role === 'admin'
            );

            if (!isAdmin) {
                return { 
                    code: 403, 
                    message: "Bạn không có quyền xóa nhóm này", 
                    data: "" 
                };
            }

            // Tạo thông báo cho tất cả thành viên
            const userEmails = group.listUser.map(user => user.email);
            const users = await User.find({ email: { $in: userEmails } });
            const userIds = users.map(user => user._id);

            await NotificationService.createNotificationForMany(
                userIds,
                'group_deleted',
                `Nhóm "${group.name}" đã bị xóa bởi admin`
            );

            // Xóa nhóm
            await Group.findByIdAndDelete(groupId);

            return { 
                code: 700, 
                message: "Xóa nhóm thành công", 
                data: group 
            };
        } catch (error) {
            console.error('Lỗi khi xóa nhóm:', error);
            throw { code: 101, message: "Server error!", data: "" };
        }
    }
    
    static async leaveGroup(groupId, userEmail) {
        try {
            const group = await Group.findById(groupId);
            if (!group) {
                return { 
                    code: 404, 
                    message: "Không tìm thấy nhóm", 
                    data: "" 
                };
            }

            // Cập nhật group bằng cách xóa user khỏi listUser
            const updatedGroup = await Group.findByIdAndUpdate(
                groupId,
                { $pull: { listUser: { email: userEmail } } },
                { new: true }
            );

            if (!updatedGroup) {
                return { 
                    code: 404, 
                    message: "Không thể rời khỏi nhóm", 
                    data: "" 
                };
            }

            // Tạo thông báo cho các thành viên còn lại
            const remainingUserEmails = updatedGroup.listUser.map(user => user.email);
            const users = await User.find({ email: { $in: remainingUserEmails } });
            const userIds = users.map(user => user._id);

            await NotificationService.createNotificationForMany(
                userIds,
                'member_left',
                `Thành viên ${userEmail} đã rời khỏi nhóm`
            );

            return { 
                code: 700, 
                message: "Rời nhóm thành công", 
                data: updatedGroup 
            };
        } catch (error) {
            console.error('Lỗi khi rời nhóm:', error);
            throw { code: 101, message: "Server error!", data: "" };
        }
    }
    
    static async getUsersByGroupId(groupId) {
        try {
            // Tìm nhóm theo ID
            const group = await Group.findById(groupId);
    
            if (!group) {
                return { code: 704, message: "Group not found", data: [] };
            }
    
            // Trích xuất danh sách người dùng
            const users = group.listUser.map(user => ({
                name: user.name,
                email: user.email,
                role: user.role
            }));
    
            return { code: 700, message: "Users retrieved successfully", data: users };
        } catch (error) {
            console.error('Error fetching users by group ID:', error);
            throw { code: 101, message: "Server error!", data: "" };
        }
    }
    
    static async addItemToRefrigerator(groupId, item) {
        try {
            // Tìm group theo groupId
            const group = await Group.findById(groupId);
            if (!group) {
                return { code: 704, message: "Không tìm thấy nhóm", data: "" };
            }
    
            // Thêm item vào refrigerator
            group.refrigerator.push(item);
    
            // Lưu group sau khi cập nhật
            const updatedGroup = await group.save();
    
            return { code: 700, message: "Thêm item vào tủ lạnh thành công", data: updatedGroup };
        } catch (error) {
            console.error('Lỗi khi thêm item vào tủ lạnh:', error);
            throw { code: 101, message: "Server error!", data: "" };
        }
    }

    static async getAvailableItems(groupId) {
        if (!groupId) {
            return { code: 701, message: "Vui lòng cung cấp ID nhóm", data: "" };
        }

        try {
            const group = await Group.findById(groupId).populate('refrigerator');
            if (!group) {
                return { code: 702, message: "Nhóm không tồn tại", data: "" };
            }

            // Lọc các item thỏa mãn điều kiện
            const today = new Date();
            const availableItems = group.refrigerator.filter(item => 
                item.amount > 0 && item.expireDate > today
            );

            return {
                code: 700,
                message: "Lấy danh sách item thành công",
                data: availableItems
            };
        } catch (error) {
            console.error("Lỗi khi lấy danh sách item:", error);
            throw { code: 101, message: "Server error!", data: "" };
        }
    }

    static async searchItemsInRefrigerator(groupId, keyword) {
        if (!groupId) {
            return { code: 701, message: "Vui lòng cung cấp đầy đủ thông tin", data: "" };
        }
    
        try {
            const group = await Group.findById(groupId);
            if (!group) {
                return { code: 702, message: "Nhóm không tồn tại", data: "" };
            }
    
            // Chuyển từ khóa và tên item sang chữ thường để tìm kiếm không phân biệt hoa/thường
            const lowerKeyword = keyword.toLowerCase();
            const matchedItems = group.refrigerator.filter(item => 
                item.foodName.toLowerCase().includes(lowerKeyword)
            );
    
            if (matchedItems.length === 0) {
                return {
                    code: 703,
                    message: "Không tìm thấy item nào khớp với từ khóa",
                    data: []
                };
            }
    
            return {
                code: 700,
                message: "Tìm kiếm item thành công",
                data: matchedItems
            };
        } catch (error) {
            console.error("Lỗi khi tìm kiếm item trong refrigerator:", error);
            throw { code: 101, message: "Server error!", data: "" };
        }
    }

    static async getTotalAmountByFoodName(groupId, foodName) {
        if (!groupId || !foodName) {
            return { code: 701, message: "Vui lòng cung cấp đầy đủ thông tin", data: "" };
        }
    
        try {
            const group = await Group.findById(groupId);
            if (!group) {
                return { code: 702, message: "Không tìm thấy nhóm", data: "" };
            }
            const matchedItems = group.refrigerator.filter(item => item.foodName === foodName);
    
            if (!matchedItems || matchedItems.length === 0) {
                return { code: 703, message: "Không tìm thấy item nào với foodName này", data: "" };
            }
            const totalAmount = matchedItems.reduce((total, item) => total + item.amount, 0);
    
            return { 
                code: 700, 
                message: "Lấy tổng amount thành công", 
                data: { 
                    foodName, 
                    totalAmount 
                } 
            };
        } catch (error) {
            console.error("Lỗi khi lấy tổng amount:", error);
            throw { code: 101, message: "Server error!", data: "" };
        }
    }
      
    




}

export default GroupService; 