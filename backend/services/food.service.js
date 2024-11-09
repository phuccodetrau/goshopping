import { Food } from "../models/schema.js";

class FoodService {
    static async createFood(name, categoryName, unitName, image, group) {
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
        try {
            // Kiểm tra xem food với name mới trong newData đã tồn tại trong group chưa
            if (newData.name) {
                const existingFood = await Food.findOne({ name: newData.name, group });
                if (existingFood) {
                    return { code: 603, message: "Thực phẩm cần cập nhật đã tồn tại", data: "" };
                }
            }
            const updatedFood = await Food.findOneAndUpdate(
                { name: foodName, group },
                { $set: newData },
                { new: true }
            );

            return { code: 600, message: "Lưu thực phẩm thành công", data: updatedFood };
        } catch (error) {
            console.error("Error updating food:", error);
            throw error;
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

    static async getAllFood(group) {
        try {
            const foods = await Food.find({ group: group });

            if (foods.length === 0) {
                return { code: 606, message: "Không có thực phẩm nào", data: "" };
            } else {
                return { code: 607, message: "Lấy danh sách thực phẩm thành công", data: foods };
            }
        } catch (error) {
            console.error("Error fetching foods:", error);
            throw error;
        }
    }
}

export default FoodService;
