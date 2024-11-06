import { Item } from "../models/schema.js";

class ItemService {
    static async createItem(foodName, expireDate, amount, note, group) {
        if (!expireDate || amount === undefined) {
            return { code: 701, message: "Vui lòng cung cấp đầy đủ thông tin", data: "" };
        }
        
        try {
            const newItem = new Item({ foodName, expireDate, amount, note, group });
            await newItem.save();
            return { code: 700, message: "Lưu item thành công", data: newItem };
        } catch (error) {
            console.error("Lỗi khi tạo item:", error);
            throw error;
        }
    }

    static async updateItem(id, newData) {
        try {
            const updatedItem = await Item.findByIdAndUpdate(
                id,
                { $set: newData },
                { new: true }
            );

            if (!updatedItem) {
                return { code: 703, message: "Item không tồn tại", data: "" }; 
            }

            return { code: 702, message: "Cập nhật item thành công", data: updatedItem };
        } catch (error) {
            console.error('Error updating item:', error);
            throw error;
        }
    }

    static async deleteItem(itemId) {
        try {
            const deletedItem = await Item.findByIdAndDelete(itemId);
            if (!deletedItem) {
                return { code: 705, message: "Không tìm thấy item để xóa", data: "" };
            }
            return { code: 704, message: "Xóa item thành công", data: deletedItem };
        } catch (error) {
            console.error("Lỗi khi xóa item:", error);
            throw error;
        }
    }

    static async getAllItem(group) {
        try {
            const items = await Item.find({ group: group });
            if (!items || items.length === 0) {
                return { code: 706, message: "Không có item nào trong group này", data: "" };
            }
            return { code: 707, message: "Lấy danh sách item thành công", data: items };
        } catch (error) {
            console.error("Lỗi khi lấy danh sách item:", error);
            throw error;
        }
    }

    static async getSpecificItem(foodName, group) {
        try {
            const items = await Item.find({ foodName: foodName, group: group });
            if (!items || items.length === 0) {
                return { code: 708, message: "Không tìm thấy item nào với foodName này trong group", data: "" };
            }
            return { code: 709, message: "Tìm kiếm item thành công", data: items };
        } catch (error) {
            console.error("Lỗi khi tìm kiếm item:", error);
            throw error;
        }
    }
}

export default ItemService;
