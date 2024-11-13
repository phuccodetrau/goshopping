import { Group } from '../models/schema.js';

class GroupService {
    static async createGroup(name, listUser) {
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


    static async addMembers(groupName, members) {
        try {
            // Find the group by name
            const group = await Group.findOne({ name: groupName });
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
            const updatedGroup = await Group.findOneAndUpdate(
                { name: groupName },
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
            // Find groups where listUser contains an object with a matching email
            const groups = await Group.find({ "listUser.email": email });
            console.log("Filtered groups:", groups); // Log các nhóm tìm thấy
    
            if (groups.length === 0) {
                return { code: 704, message: "Không tìm thấy nhóm nào với email này", data: [] };
            }
    
            const groupNames = groups.map(group => group.name);
            return { code: 700, message: "Lấy danh sách nhóm thành công", data: groupNames };
        } catch (error) {
            console.error('Lỗi khi lấy danh sách nhóm theo email:', error);
            throw { code: 101, message: "Server error!", data: "" };
        }
    }
    
    

    static async getAdminsByGroupName(groupName) {
        try {
            // Tìm nhóm dựa trên tên và chỉ lấy listUser chứa thông tin người dùng
            const group = await Group.findOne({ name: groupName });
    
            if (!group) {
                return { code: 704, message: "Không tìm thấy nhóm với tên này", data: [] };
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
            // Find the group by name
            const group = await Group.findOne({ name: groupName });
    
            if (!group) {
                return { code: 704, message: "Group not found", data: [] };
            }
    
            // Return the list of users
            return { code: 700, message: "Users retrieved successfully", data: group.listUser };
        } catch (error) {
            console.error('Error fetching users by group name:', error);
            throw { code: 101, message: "Server error!", data: "" };
        }
    }
    
    
    
    static async deleteGroup(groupName) {
        try {
            const deletedGroup = await Group.findOneAndDelete({ name: groupName });
    
            if (!deletedGroup) {
                return { code: 706, message: "Không tìm thấy nhóm để xóa", data: "" };
            }
    
            return { code: 700, message: "Xóa nhóm thành công", data: deletedGroup };
        } catch (error) {
            console.error('Lỗi khi xóa nhóm:', error);
            throw { code: 101, message: "Server error!", data: "" };
        }
    }

    static async removeMember(groupName, email) {
        try {
            const updatedGroup = await Group.findOneAndUpdate(
                { name: groupName },
                { $pull: { listUser: { email: email } } }, // Remove member with matching email
                { new: true }
            );
    
            if (!updatedGroup) {
                return { code: 706, message: "Không tìm thấy nhóm hoặc thành viên để xóa", data: "" };
            }
    
            return { code: 700, message: "Xóa thành viên thành công", data: updatedGroup };
        } catch (error) {
            console.error('Lỗi khi xóa thành viên:', error);
            throw { code: 101, message: "Server error!", data: "" };
        }
    }
    
    
      

}

export default GroupService; 