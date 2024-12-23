import { Item } from "../models/schema.js";

class ItemService {
    static async createItem(foodName, expireDate, amount, unitName, note, group) {
        if (!expireDate || amount === undefined) {
            return { code: 701, message: "Vui lòng cung cấp đầy đủ thông tin", data: "" };
        }
        
        try {
            const newItem = new Item({ foodName, expireDate, amount, unitName, note, group });
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
                return { 
                    code: 708, 
                    message: "Không tìm thấy item nào với foodName này trong group", 
                    data: "" 
                };
            }
            
            const currentDate = new Date();
            
            // Phân loại items
            const validItems = items.filter(item => item.expireDate > currentDate);
            const expiredItems = items.filter(item => item.expireDate <= currentDate);
            
            // Tính tổng amount cho từng loại
            const totalValidAmount = validItems.reduce((total, item) => total + item.amount, 0);
            const totalExpiredAmount = expiredItems.reduce((total, item) => total + item.amount, 0);

            return { 
                code: 709, 
                message: "Tìm kiếm item thành công", 
                data: { 
                    items: items,  // Giữ lại danh sách gốc để tương thích ngược
                    validItems: validItems,  // Items còn hạn
                    expiredItems: expiredItems,  // Items hết hạn
                    totalAmount: totalValidAmount + totalExpiredAmount,  // Tổng số lượng
                    totalValidAmount: totalValidAmount,  // Tổng số lượng còn hạn
                    totalExpiredAmount: totalExpiredAmount,  // Tổng số lượng hết hạn
                    itemsByStatus: {
                        valid: validItems.map(item => ({
                            _id: item._id,
                            amount: item.amount,
                            unitName: item.unitName,
                            expireDate: item.expireDate,
                            note: item.note
                        })),
                        expired: expiredItems.map(item => ({
                            _id: item._id,
                            amount: item.amount,
                            unitName: item.unitName,
                            expireDate: item.expireDate,
                            note: item.note
                        }))
                    }
                } 
            };
        } catch (error) {
            console.error("Lỗi khi tìm kiếm item:", error);
            throw error;
        }
    }

    static async getItemDetail(foodName, group) {
        try {
            // Tìm tất cả items với foodName và group tương ứng
            const items = await Item.find({ foodName: foodName, group: group })
                .select('foodName amount unitName');

            // Nếu không tìm thấy item, trả về với totalAmount = 0
            if (!items || items.length === 0) {
                return { 
                    code: 800, 
                    message: "Lấy thông tin item thành công", 
                    data: {
                        foodName,
                        totalAmount: 0,
                        unitName: null
                    }
                };
            }

            // Tính tổng số lượng và lấy unitName từ item đầu tiên
            const totalAmount = items.reduce((sum, item) => sum + item.amount, 0);
            const unitName = items[0].unitName;

            return {
                code: 800,
                message: "Lấy thông tin item thành công",
                data: {
                    foodName,
                    totalAmount,
                    unitName
                }
            };
        } catch (error) {
            console.error("Lỗi khi lấy thông tin chi tiết item:", error);
            throw error;
        }
    }
}

export default ItemService;
