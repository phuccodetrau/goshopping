import { Recipe } from "../models/schema.js";

class RecipeService {
    static async createRecipe(name, description, list_item, group) {
        if (!name || !list_item || list_item.length === 0) {
            return { code: 701, message: "Vui lòng cung cấp đầy đủ thông tin", data: "" };
        }

        const existingRecipe = await Recipe.findOne({ name: name, group: group });
        if (existingRecipe) {
            return { code: 702, message: "Recipe đã tồn tại trong group này", data: "" };
        }
        
        try {
            const createRecipe = new Recipe({ name, description, list_item, group });
            const savedRecipe = await createRecipe.save();
            return { code: 700, message: "Lưu recipe thành công", data: savedRecipe };
        } catch (error) {
            console.error("Lỗi khi tạo recipe:", error);
            throw error;
        }
    }

    static async updateRecipe(recipeName, group, newData) {
        try {
            if (newData.name) {
                const existingRecipe = await Recipe.findOne({
                    name: newData.name,
                    group: group,
                    _id: { $ne: newData._id }
                });
                
                if (existingRecipe) {
                    return { code: 704, message: "Tên recipe mới đã tồn tại trong group này", data: "" };
                }
            }

            const updatedRecipe = await Recipe.findOneAndUpdate(
                { name: recipeName, group: group },
                { $set: newData },
                { new: true }
            );
            
            if (!updatedRecipe) {
                return { code: 703, message: "Không tìm thấy recipe để cập nhật", data: "" };
            }

            return { code: 702, message: "Cập nhật recipe thành công", data: updatedRecipe };
        } catch (error) {
            console.error("Lỗi khi cập nhật recipe:", error);
            throw error;
        }
    }

    static async deleteRecipe(recipeName, group) {
        try {
            const deletedRecipe = await Recipe.findOneAndDelete({ name: recipeName, group: group });
            if (!deletedRecipe) {
                return { code: 705, message: "Không tìm thấy recipe để xóa", data: "" };
            }
            return { code: 704, message: "Xóa recipe thành công", data: deletedRecipe };
        } catch (error) {
            console.error("Lỗi khi xóa recipe:", error);
            throw error;
        }
    }

    static async getRecipeByFood(foodName, group) {
        try {
            const recipes = await Recipe.find({
                group: group,
                list_item: { $elemMatch: { foodName: foodName } }
            });
            if (!recipes || recipes.length === 0) {
                return { code: 706, message: "Không tìm thấy recipe nào với foodName này trong group", data: "" };
            }
            return { code: 707, message: "Tìm kiếm recipe thành công", data: recipes };
        } catch (error) {
            console.error("Lỗi khi tìm kiếm recipe:", error);
            throw error;
        }
    }

    static async getAllRecipe(group) {
        try {
            const recipes = await Recipe.find({ group: group }, 'name description');
            if (!recipes || recipes.length === 0) {
                return { code: 708, message: "Không tìm thấy recipe nào trong group này", data: "" };
            }
            return { code: 709, message: "Lấy danh sách recipe thành công", data: recipes };
        } catch (error) {
            console.error("Lỗi khi lấy danh sách recipe:", error);
            throw error;
        }
    }
}

export default RecipeService;
