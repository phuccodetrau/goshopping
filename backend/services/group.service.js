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

    static async addMember(groupId, member) {
        try {
            const updatedGroup = await Group.findByIdAndUpdate(
                groupId,
                { $push: { listUser: member } },
                { new: true }
            );

            if (!updatedGroup) {
                return { code: 703, message: "Không tìm thấy nhóm để thêm thành viên", data: "" };
            }

            return { code: 702, message: "Thêm thành viên thành công", data: updatedGroup };
        } catch (error) {
            console.error('Lỗi khi thêm thành viên:', error);
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
}

export default GroupService; 