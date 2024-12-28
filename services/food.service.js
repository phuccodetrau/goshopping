import { Food, Item, ListTask, Group } from "../models/schema.js";

class FoodService {
    static async createFood(name, categoryName, unitName, image, group) {
        console.log("Nhận req");
        
        try {
            const existingFood = await Food.findOne({ name, group });
            if (existingFood) {
                return { code: 602, message: "Thực phẩm đã tồn tại", data: "" };
            }

            const createFood = new Food({ name, categoryName, unitName, image, group });
            const foodData = await createFood.save();

            return { code: 600, message: "Lưu thực phẩm thành công", data: foodData };
        } catch (error) {
            console.error("Error creating food:", error);
            throw error;
        }
    }

    static async updateFood(foodName, group, newData) {
        console.log("Gọi đến api");
        
        try {

            const updatedFood = await Food.findOneAndUpdate(
                { name: foodName, group },
                { $set: newData },
                { new: true }
            );

            if (!updatedFood) {
                return { code: 605, message: "Không tìm thấy thực phẩm cần cập nhật", data: "" };
            }

            await Item.updateMany(
                { foodName: foodName, group: group },
                { $set: { foodName: newData.name || foodName, unitName: newData.unitName || undefined } }
            );

            await ListTask.updateMany(
                { foodName: foodName, group: group },
                { $set: { foodName: newData.name || foodName, unitName: newData.unitName || undefined } }
            );

            await Group.updateMany(
                { "refrigerator.foodName": foodName, _id: group },
                { $set: { "refrigerator.$.foodName": newData.name || foodName, "refrigerator.$.unitName": newData.unitName || undefined } }
            );
            console.log("Cập nhật thực phẩm và các phụ thuộc thành công");

            return { code: 600, message: "Cập nhật thực phẩm và các phụ thuộc thành công", data: updatedFood };
        } catch (error) {
            console.error("Error updating food with dependencies:", error);
            throw { code: 101, message: "Server error!", data: "" };
        }
    }

    static async deleteFood(foodName, group) {
        try {
            const deleted = await Food.findOneAndDelete({ name: foodName, group: group });

            if (deleted) {
                return { code: 604, message: "Xóa thực phẩm thành công", data: deleted };
            } else {
                return { code: 605, message: "Thực phẩm cần xóa không tồn tại", data: "" };
            }
        } catch (error) {
            console.error("Error deleting food:", error);
            throw error;
        }
    }

    static async getAllFood(groupId) {
        try {
            const foods = await Food.find({ group: groupId })
                .select('name categoryName unitName -_id');

            if (foods.length === 0) {
                return { code: 606, message: "Không có thực phẩm nào", data: [] };
            } else {
                const foodList = foods.map(food => ({
                    name: food.name,
                    categoryName: food.categoryName,
                    unitName: food.unitName
                }));
                return { code: 607, message: "Lấy danh sách thực phẩm thành công", data: foodList };
            }
        } catch (error) {
            console.error("Error fetching foods:", error);
            throw { code: 101, message: "Server error!", data: [] };
        }
    }

    static async getFoodsByCategory(groupId, categoryName) {
        try {
            if (!groupId || !categoryName) {
                return { code: 701, message: "Vui lòng cung cấp đầy đủ thông tin", data: "" };
            }
            const foods = await Food.find({ group: groupId, categoryName });
            if (!foods || foods.length === 0) {
                return { code: 603, message: "Không tìm thấy thực phẩm nào trong danh mục này", data: "" };
            }
            return { code: 600, message: "Lấy danh sách thực phẩm thành công", data: foods };
        } catch (error) {
            console.error("Error fetching foods by category:", error);
            throw { code: 101, message: "Server error!", data: "" };
        }
    }

    static async getUnavailableFoods(groupId) {
        try {
            // Lấy group để kiểm tra refrigerator
            const group = await Group.findById(groupId);
    
            if (!group || !group.refrigerator) {
                return { code: 701, message: "Group không tồn tại hoặc không có refrigerator", data: "" };
            }
    
            // Lấy danh sách foodName đã có trong refrigerator
            const refrigeratorFoodNames = group.refrigerator.map(item => item.foodName);
    
            // Lấy các food từ bảng Food không có trong refrigerator
            const availableFoods = await Food.find({
                group: groupId,
                name: { $nin: refrigeratorFoodNames },
            }).select("name unitName image");
    
            if (!availableFoods || availableFoods.length === 0) {
                return { code: 702, message: "Không có thực phẩm khả dụng", data: "" };
            }
    
            return { code: 600, message: "Lấy danh sách thực phẩm khả dụng thành công", data: availableFoods };
        } catch (error) {
            console.error("Error fetching available foods:", error);
            throw { code: 101, message: "Server error!", data: "" };
        }
    }

    static async getFoodImageByName(groupId, foodName) {
        // Kiểm tra đầu vào
        if (!groupId || !foodName) {
            return { code: 701, message: "Vui lòng cung cấp đầy đủ thông tin", data: null };
        }

        try {
            // Tìm Group theo groupId
            const group = await Group.findById(groupId);
            if (!group) {
                return { code: 702, message: "Nhóm không tồn tại", data: null };
            }

            // Tìm Food dựa trên name
            const food = await Food.findOne({ name: foodName });
            if (!food) {
                return { code: 703, message: "Không tìm thấy món ăn với tên cung cấp", data: null };
            }

            // Trả về thông tin hình ảnh
            return {
                code: 700,
                message: "Lấy hình ảnh thành công",
                data: food.image,
            };
        } catch (error) {
            console.error("Lỗi khi lấy hình ảnh của food:", error);
            return { code: 101, message: "Server error!", data: null };
        }
    }
}

export default FoodService;
