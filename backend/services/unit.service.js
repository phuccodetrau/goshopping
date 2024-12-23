import { Unit, Food } from "../models/schema.js";

class UnitService {
    static async createUnit(unitName, groupId) {
        if (!unitName || !groupId) {
            return { code: 701, message: "Vui lòng cung cấp đầy đủ thông tin", data: "" };
        }

        const existingUnit = await Unit.findOne({ name: unitName, group: groupId });
        if (existingUnit) {
            return { code: 702, message: "Tên đơn vị đã tồn tại trong nhóm này", data: "" };
        }

        try {
            const createUnit = new Unit({ name: unitName, group: groupId });
            const savedUnit = await createUnit.save();
            return { code: 700, message: "Tạo đơn vị thành công", data: savedUnit };
        } catch (error) {
            console.error("Lỗi khi tạo đơn vị:", error);
            throw error;
        }
    }

    static async getAllUnit(groupId) {
        if (!groupId) {
            return { code: 701, message: "Vui lòng cung cấp groupId", data: "" };
        }

        try {
            const units = await Unit.find({ group: groupId });
            return { code: 700, message: "Lấy tất cả đơn vị thành công", data: units };
        } catch (err) {
            console.error("Lỗi khi lấy danh sách đơn vị:", err);
            throw err;
        }
    }

    static async editUnit(oldName, newName, groupId) {
        if (!oldName || !newName || !groupId) {
            return { code: 701, message: "Vui lòng cung cấp đầy đủ thông tin", data: "" };
        }

        const existingUnit = await Unit.findOne({
            name: newName,
            group: groupId,
            _id: { $ne: (await Unit.findOne({ name: oldName, group: groupId }))._id }
        });

        if (existingUnit) {
            return { code: 702, message: "Tên đơn vị mới đã tồn tại trong nhóm này", data: "" };
        }

        try {
            const updatedUnit = await Unit.findOneAndUpdate(
                { name: oldName, group: groupId },
                { name: newName },
                { new: true }
            );

            if (!updatedUnit) {
                return { code: 703, message: "Không tìm thấy đơn vị để cập nhật", data: "" };
            }

            return { code: 700, message: "Cập nhật đơn vị thành công", data: updatedUnit };
        } catch (error) {
            console.error("Lỗi khi cập nhật đơn vị:", error);
            throw error;
        }
    }

    static async deleteUnit(name, groupId) {
        if (!name || !groupId) {
            return { code: 701, message: "Vui lòng cung cấp đầy đủ thông tin", data: "" };
        }
    
        try {
            const foodUsingUnit = await Food.findOne({ unitName: name, group: groupId });
            if (foodUsingUnit) {
                return { code: 705, message: "Không thể xóa đơn vị vì vẫn còn thực phẩm sử dụng đơn vị này", data: "" };
            }
            const result = await Unit.deleteOne({ name: name, group: groupId });
            if (result.deletedCount === 0) {
                return { code: 404, message: "Đơn vị không tìm thấy", data: "" };
            }
    
            return { code: 700, message: "Đơn vị đã xóa thành công", data: "" };
        } catch (error) {
            console.error("Lỗi khi xóa đơn vị:", error);
            throw error;
        }
    }
}

export default UnitService;
