import { Category, Food } from "../models/schema.js";

class CategoryService {
    static async createCategory(categoryName, groupId) {
        if (!categoryName || !groupId) {
            return { code: 701, message: "Vui lòng cung cấp đầy đủ thông tin", data: "" };
        }

        const existingCategory = await Category.findOne({ name: categoryName, group: groupId });
        if (existingCategory) {
            return { code: 702, message: "Danh mục đã tồn tại trong nhóm này", data: "" };
        }

        try {
            const createCategory = new Category({ name: categoryName, group: groupId });
            const savedCategory = await createCategory.save();
            return { code: 700, message: "Tạo danh mục thành công", data: savedCategory };
        } catch (error) {
            console.error("Lỗi khi tạo danh mục:", error);
            throw error;
        }
    }

    static async getAllCategory(groupId) {
        try {
            const categories = await Category.find({ group: groupId });
            if (!categories || categories.length === 0) {
                return { code: 706, message: "Không tìm thấy danh mục nào", data: "" };
            }
            return { code: 707, message: "Tìm kiếm danh mục thành công", data: categories };
        } catch (error) {
            console.error("Lỗi khi lấy danh mục:", error);
            throw error;
        }
    }

    static async editCategory(oldName, newName, groupId) {
        if (!oldName || !newName || !groupId) {
            return { code: 701, message: "Vui lòng cung cấp đầy đủ thông tin", data: "" };
        }
        const existingCategory = await Category.findOne({
            name: newName,
            group: groupId,
            _id: { $ne: (await Category.findOne({ name: oldName, group: groupId }))._id }
        });

        if (existingCategory) {
            return { code: 702, message: "Tên danh mục mới đã tồn tại trong nhóm này", data: "" };
        }

        try {
            const updatedCategory = await Category.findOneAndUpdate(
                { name: oldName, group: groupId },
                { name: newName },
                { new: true }
            );

            if (!updatedCategory) {
                return { code: 703, message: "Không tìm thấy danh mục để cập nhật", data: "" };
            }

            return { code: 700, message: "Cập nhật danh mục thành công", data: updatedCategory };
        } catch (error) {
            console.error("Lỗi khi cập nhật danh mục:", error);
            throw error;
        }
    }


    static async deleteCategory(name, groupId) {
        try {
            const foodUsingCategory = await Food.findOne({ categoryName: name, group: groupId });
            if (foodUsingCategory) {
                return { code: 705, message: "Không thể xóa danh mục vì còn thực phẩm sử dụng danh mục này", data: "" };
            }
            const deletedCategory = await Category.deleteOne({ name: name, group: groupId });
            if (deletedCategory.deletedCount === 0) {
                return { code: 706, message: "Không tìm thấy danh mục để xóa", data: "" };
            }
    
            return { code: 704, message: "Xóa danh mục thành công", data: deletedCategory };
        } catch (error) {
            console.error("Lỗi khi xóa danh mục:", error);
            throw error;
        }
    }
}

export default CategoryService;
