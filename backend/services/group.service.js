import { Group, User } from '../models/schema.js';
import NotificationService from './notification.service.js';

class GroupService {
    static async createGroup(name, listUser, avatar) {
        try {
            // Validate đầu vào
            if (!name || !listUser || !Array.isArray(listUser) || listUser.length === 0) {
                return { 
                    code: 400, 
                    message: "Vui lòng cung cấp tên nhóm và danh sách thành viên hợp lệ", 
                    data: "" 
                };
            }

            const newGroup = new Group({
                name,
                listUser: listUser.map(user => ({
                    ...user,
                    role: user.role || 'member'
                })),
                refrigerator: [],
                avatar: avatar
            });

            const savedGroup = await newGroup.save();

            // Tìm users và gửi thông báo trong try-catch riêng
            try {
                const emails = listUser.map(user => user.email);
                const users = await User.find({ email: { $in: emails } });
                
                if (users.length > 0) {
                    await NotificationService.createNotificationForMany(
                        users.map(user => user._id),
                        'group_created',
                        `Bạn đã được thêm vào nhóm "${name}"`
                    );
                }
            } catch (error) {
                console.error('Lỗi khi gửi thông báo:', error);
                // Không throw error ở đây để vẫn return group đã tạo
            }

            return { 
                code: 700, 
                message: "Tạo nhóm thành công", 
                data: savedGroup 
            };
        } catch (error) {
            console.error('Lỗi khi tạo nhóm:', error);
            throw { 
                code: 101, 
                message: "Lỗi server khi tạo nhóm", 
                data: "" 
            };
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
            
            // Tìm users trong database
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
                { name: 1, listUser: 1, avatar: 1 } // Lấy name và listUser
            );

            if (groups.length === 0) {
                return { code: 704, message: "Không tìm thấy nhóm nào với email này", data: [] };
            }

            // Tạo danh sách với đầy đủ thông tin cần thiết
            const groupDetails = groups.map(group => ({
                id: group._id,
                name: group.name,
                listUser: group.listUser,
                avatar: group.avatar
            }));
            console.log(groups);
            

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
                return { code: 404, message: "Không tìm thấy nhóm", data: "" };
            }

            // Lấy danh sách user IDs trước khi xóa nhóm
            const users = await User.find({ 
                email: { $in: group.listUser.map(u => u.email) } 
            });
            const userIds = users.map(user => user._id);

            // Gửi thông báo cho tất cả thành viên
            await NotificationService.createNotificationForMany(
                userIds,
                'group_deleted',
                `Nhóm "${group.name}" đã bị xóa bởi admin ${userEmail}`
            );

            // Xóa nhóm
            await Group.findByIdAndDelete(groupId);

            return { code: 700, message: "Xóa nhóm thành công", data: group };
        } catch (error) {
            console.error('Error deleting group:', error);
            throw error;
        }
    }
    
    static async leaveGroup(groupId, userEmail) {
        try {
            console.log("Service leaveGroup:", { groupId, userEmail });
            
            const group = await Group.findById(groupId);
            if (!group) {
                return { 
                    code: 704, 
                    message: "Không tìm thấy nhóm", 
                    data: "" 
                };
            }

            // Tìm thông tin người rời nhóm trước khi xóa
            const leavingMember = group.listUser.find(user => user.email === userEmail);
            if (!leavingMember) {
                return { 
                    code: 705, 
                    message: "Bạn không phải thành viên của nhóm này", 
                    data: "" 
                };
            }

            // Xóa thành viên khỏi nhóm
            group.listUser = group.listUser.filter(user => user.email !== userEmail);
            await group.save();

            // Lấy danh sách user IDs của các thành viên còn lại
            const remainingUsers = await User.find({
                email: { 
                    $in: group.listUser.map(u => u.email)
                }
            });
            const remainingUserIds = remainingUsers.map(user => user._id);

            // Tìm user đã rời nhóm để gửi thông báo
            const leavingUser = await User.findOne({ email: userEmail });
            if (leavingUser) {
                // Gửi thông báo cho người rời nhóm
                await NotificationService.createNotification(
                    leavingUser._id,
                    'left_group',
                    `Bạn đã rời khỏi nhóm "${group.name}"`
                );
            }

            // Gửi thông báo cho các thành viên còn lại
            if (remainingUserIds.length > 0) {
                await NotificationService.createNotificationForMany(
                    remainingUserIds,
                    'member_left_group',
                    `${leavingMember.name} (${leavingMember.email}) đã rời khỏi nhóm "${group.name}"`
                );
            }

            return { 
                code: 700, 
                message: "Rời nhóm thành công", 
                data: group 
            };
        } catch (error) {
            console.error('Lỗi khi rời nhóm:', error);
            throw { 
                code: 101, 
                message: "Lỗi server khi rời nhóm", 
                data: "" 
            };
        }
    }
    
    static async getUsersByGroupId(groupId) {
        try {
            // Tìm nhóm theo ID
            const group = await Group.findById(groupId);
    
            if (!group) {
                return { code: 704, message: "Group not found", data: [] };
            }
            const userEmails = group.listUser.map(user => user.email);

            const users = await User.find({ email: { $in: userEmails } });

            const result = group.listUser.map(groupUser => {
                const user = users.find(u => u.email === groupUser.email);
                return {
                    name: groupUser.name,
                    email: groupUser.email,
                    role: groupUser.role,
                    avatar: user ? user.avatar : "",
                };
            });
    
            return { code: 700, message: "Users retrieved successfully", data: result };
        } catch (error) {
            console.error('Error fetching users by group ID:', error);
            throw { code: 101, message: "Server error!", data: "" };
        }
    }
    
    static async addItemToRefrigerator(groupId, item) {
        try {
            console.log("Nhận api add item vào fridge");
            
            // Tìm group theo groupId
            const group = await Group.findById(groupId);
            if (!group) {
                return { code: 704, message: "Không tìm thấy nhóm", data: "" };
            }
    
            // Thêm item vào refrigerator
            group.refrigerator.push(item);
    
            // Lưu group sau khi cập nhật
            const updatedGroup = await group.save();
            console.log("Thêm thành công");
    
            return { code: 700, message: "Thêm item vào tủ lạnh thành công", data: updatedGroup };
        } catch (error) {
            console.error('Lỗi khi thêm item vào tủ lạnh:', error);
            throw { code: 101, message: "Server error!", data: "" };
        }
    }

    static async filterItemsWithPagination(groupId, keyword = "", page = 1, limit = 3) {
        if (!groupId) {
            return { code: 701, message: "Vui lòng cung cấp đầy đủ thông tin", data: "" };
        }
    
        try {
            const group = await Group.findById(groupId);
            if (!group) {
                return { code: 702, message: "Nhóm không tồn tại", data: "" };
            }
            const lowerKeyword = keyword.toLowerCase();
            const today = new Date();
            const matchedItems = group.refrigerator.filter(item => {
                const isKeywordMatched =
                    lowerKeyword === "" || item.foodName.toLowerCase().includes(lowerKeyword);
                const isNotExpired =
                    item.expireDate && new Date(item.expireDate) > today; // Kiểm tra expireDate
                
                return isKeywordMatched && isNotExpired;
            });

            const totalItems = matchedItems.length;
            const totalPages = Math.ceil(totalItems / limit);
            const startIndex = (page - 1) * limit;
            const paginatedItems = matchedItems.slice(startIndex, startIndex + limit)
                     
    
            return {
                code: 700,
                message: "Lấy danh sách item thành công",
                data: paginatedItems,
            };
        } catch (error) {
            console.error("Lỗi khi lấy item trong refrigerator:", error);
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

    static async getEmailsByGroupId(groupId) {
        try {
            // Kiểm tra groupId
            if (!groupId) {
                return { 
                    code: 701, 
                    message: "Vui lòng cung cấp groupId", 
                    data: [] 
                };
            }

            // Tìm nhóm theo ID
            const group = await Group.findById(groupId);

            if (!group) {
                return { 
                    code: 704, 
                    message: "Không tìm thấy nhóm", 
                    data: [] 
                };
            }

            // Lấy danh sách email từ listUser
            const emails = group.listUser.map(user => user.email);

            return { 
                code: 700, 
                message: "Lấy danh sách email thành công", 
                data: emails 
            };
        } catch (error) {
            console.error('Lỗi khi lấy danh sách email:', error);
            throw { 
                code: 101, 
                message: "Lỗi server", 
                data: [] 
            };
        }
    }
      
    static async removeMember(groupId, email) {
        try {
            const group = await Group.findById(groupId);
            if (!group) {
                return { 
                    code: 704, 
                    message: "Không tìm thấy nhóm", 
                    data: "" 
                };
            }

            // Kiểm tra xem thành viên có tồn tại trong nhóm không
            const memberIndex = group.listUser.findIndex(user => user.email === email);
            if (memberIndex === -1) {
                return { 
                    code: 705, 
                    message: "Không tìm thấy thành viên trong nhóm", 
                    data: "" 
                };
            }

            // Lưu thông tin người bị xóa trước khi xóa
            const removedMember = group.listUser[memberIndex];

            // Xóa thành viên khỏi nhóm
            group.listUser.splice(memberIndex, 1);
            await group.save();

            // Lấy danh sách user IDs của tất cả thành viên còn lại trong nhóm
            const remainingUsers = await User.find({
                email: { 
                    $in: group.listUser.map(u => u.email)
                }
            });
            const remainingUserIds = remainingUsers.map(user => user._id);

            // Tìm user bị xóa để gửi thông báo
            const removedUser = await User.findOne({ email: email });
            if (removedUser) {
                // Gửi thông báo cho người bị xóa
                await NotificationService.createNotification(
                    removedUser._id,
                    'member_removed',
                    `Bạn đã bị xóa khỏi nhóm "${group.name}"`
                );
            }

            // Gửi thông báo cho các thành viên còn lại
            if (remainingUserIds.length > 0) {
                await NotificationService.createNotificationForMany(
                    remainingUserIds,
                    'member_removed_from_group',
                    `Thành viên ${removedMember.name} (${removedMember.email}) đã bị xóa khỏi nhóm "${group.name}"`
                );
            }

            return { 
                code: 700, 
                message: "Xóa thành viên thành công", 
                data: group 
            };
        } catch (error) {
            console.error('Lỗi khi xóa thành viên:', error);
            throw { 
                code: 101, 
                message: "Lỗi server khi xóa thành viên", 
                data: "" 
            };
        }
    }
    static async updateGroupImage(groupId, avatar) {
        try {
            // Kiểm tra groupId và image
            if (!groupId || !avatar) {
                return {
                    code: 701,
                    message: "Vui lòng cung cấp groupId và image",
                    data: null,
                };
            }
    
            // Tìm nhóm theo ID
            const group = await Group.findById(groupId);
    
            if (!group) {
                return {
                    code: 704,
                    message: "Không tìm thấy nhóm",
                    data: null,
                };
            }
    
            // Cập nhật image
            group.avatar = avatar;
            await group.save();
    
            return {
                code: 700,
                message: "Cập nhật ảnh nhóm thành công",
                data: {
                    groupId: group._id,
                    avatar: group.avatar,
                },
            };
        } catch (error) {
            console.error("Lỗi khi cập nhật ảnh nhóm:", error);
            throw {
                code: 101,
                message: "Lỗi server",
                data: null,
            };
        }
    }

}

export default GroupService; 