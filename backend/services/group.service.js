import { Group } from '../models/schema.js';

class GroupService {
    static async createGroup(name, listUser) {
        console.log("Name:", name);
        console.log("ListUser:", listUser);


        if (!name || !listUser || listUser.length === 0) {
            return { code: 701, message: "Vui lòng cung cấp đầy đủ thông tin", data: "" };
        }

        const newGroup = new Group({
            name,
            listUser,
            refrigerator: []
        });

        try {
            const savedGroup = await newGroup.save();
            return { code: 700, message: "Tạo nhóm thành công", data: savedGroup };
        } catch (error) {
            console.error('Lỗi khi tạo nhóm:', error);
            throw { code: 101, message: "Server error!", data: "" };
        }
    }


    static async addMembers(groupId, members) {
        try {
            // Find the group by ID
            const group = await Group.findById(groupId);
            if (!group) {
                return { code: 703, message: "Không tìm thấy nhóm để thêm thành viên", data: "" };
            }

            // Filter out members who are already in the group
            const newMembers = members.filter(member =>
                !group.listUser.some(existingMember => existingMember.email === member.email)
            );

            // If no new members to add, return a message
            if (newMembers.length === 0) {
                return { code: 706, message: "Tất cả thành viên đã có trong nhóm", data: "" };
            }

            // Add only the new members
            const updatedGroup = await Group.findByIdAndUpdate(
                groupId,
                { $addToSet: { listUser: { $each: newMembers } } },
                { new: true }
            );

            return { code: 702, message: "Thêm thành viên thành công", data: updatedGroup };
        } catch (error) {
            console.error('Lỗi khi thêm danh sách thành viên:', error);
            throw { code: 101, message: "Server error!", data: "" };
        }
    }



    static async getGroupsByMemberEmail(email) {
        try {
            // Tìm các nhóm mà listUser chứa một object có email khớp
            const groups = await Group.find({ "listUser.email": email }, "name _id"); // Chỉ lấy trường `name` và `_id`
            console.log("Filtered groups:", groups); // Log các nhóm tìm thấy

            if (groups.length === 0) {
                return { code: 704, message: "Không tìm thấy nhóm nào với email này", data: [] };
            }

            // Tạo danh sách chứa `name` và `_id` của các nhóm
            const groupDetails = groups.map(group => ({
                id: group._id,
                name: group.name,
            }));

            return { code: 700, message: "Lấy danh sách nhóm thành công", data: groupDetails };
        } catch (error) {
            console.error('Lỗi khi lấy danh sách nhóm theo email:', error);
            throw { code: 101, message: "Server error!", data: "" };
        }
    }




    static async getAdminsByGroupId(groupId) {
        try {
            // Tìm nhóm bằng `groupId`
            const group = await Group.findById(groupId); // Sử dụng `_id` trong MongoDB
    
            if (!group) {
                return { code: 704, message: "Không tìm thấy nhóm với ID này", data: [] };
            }
    
            // Lọc ra danh sách người dùng có role là "admin"
            const admins = group.listUser
                .filter(user => user.role === "admin")
                .map(admin => admin.name); // Chỉ lấy tên của admin
    
            if (admins.length === 0) {
                return { code: 705, message: "Không có admin trong nhóm này", data: [] };
            }
    
            return { code: 700, message: "Lấy danh sách admin thành công", data: admins };
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
                return { code: 706, message: "Không tìm thấy nhóm để xóa", data: "" };
            }
    
            // Kiểm tra nếu userEmail là admin
            const isAdmin = group.listUser.some(
                user => user.email === userEmail && user.role === "admin"
            );
    
            if (!isAdmin) {
                return { code: 403, message: "Bạn không có quyền xóa nhóm này", data: "" };
            }
    
            const deletedGroup = await Group.findByIdAndDelete(groupId);
            return { code: 700, message: "Xóa nhóm thành công", data: deletedGroup };
        } catch (error) {
            console.error('Lỗi khi xóa nhóm:', error);
            throw { code: 101, message: "Server error!", data: "" };
        }
    }
    

    static async leaveGroup(groupId, userEmail) {
        try {
            const updatedGroup = await Group.findByIdAndUpdate(
                groupId,
                { $pull: { listUser: { email: userEmail } } },
                { new: true }
            );
    
            if (!updatedGroup) {
                return { code: 706, message: "Không tìm thấy nhóm hoặc thành viên để xóa", data: "" };
            }
    
            return { code: 700, message: "Rời nhóm thành công", data: updatedGroup };
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