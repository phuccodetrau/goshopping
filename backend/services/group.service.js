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

    static async deleteGroup(groupId) {
        try {
            const deletedGroup = await Group.findByIdAndDelete(groupId);
            if (!deletedGroup) {
                return { code: 702, message: "Không tìm thấy nhóm để xóa", data: "" };
            }
            return { code: 701, message: "Xóa nhóm thành công", data: deletedGroup };
        } catch (error) {
            console.error('Lỗi khi xóa nhóm:', error);
            throw { code: 101, message: "Server error!", data: "" };
        }
    }
    static async addMembers(groupName, members) {
        try {
            const updatedGroup = await Group.findOneAndUpdate(
                { name: groupName },
                { $addToSet: { listUser: { $each: members } } }, // Sử dụng $each để thêm nhiều phần tử
                { new: true }
            );
    
            if (!updatedGroup) {
                return { code: 703, message: "Không tìm thấy nhóm để thêm thành viên", data: "" };
            }
    
            return { code: 702, message: "Thêm danh sách thành viên thành công", data: updatedGroup };
        } catch (error) {
            console.error('Lỗi khi thêm danh sách thành viên:', error);
            throw { code: 101, message: "Server error!", data: "" };
        }
    }

    static async removeMember(groupId, email) {
        try {
            const updatedGroup = await Group.findByIdAndUpdate(
                groupId,
                { $pull: { listUser: { email: email } } },
                { new: true }
            );

            if (!updatedGroup) {
                return { code: 704, message: "Không tìm thấy nhóm để xóa thành viên", data: "" };
            }

            return { code: 703, message: "Xóa thành viên thành công", data: updatedGroup };
        } catch (error) {
            console.error('Lỗi khi xóa thành viên:', error);
            throw { code: 101, message: "Server error!", data: "" };
        }
    }


    static async getGroupsByMemberEmail(email) {
        try {
            const groups = await Group.find({}); // Lấy tất cả nhóm
            console.log("All groups:", groups); // Log tất cả các nhóm tìm thấy
    
            if (groups.length === 0) {
                return { code: 704, message: "Không tìm thấy nhóm nào", data: [] };
            }
    
            // Lấy tên của tất cả các nhóm
            const groupNames = groups.map(group => group.name);
            return { code: 700, message: "Lấy danh sách tất cả nhóm thành công", data: groupNames };
        } catch (error) {
            console.error('Lỗi khi lấy danh sách tất cả nhóm:', error);
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
    
    
    
      

}

export default GroupService; 