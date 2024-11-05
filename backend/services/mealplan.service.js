import { MealPlan } from "../models/schema.js";

class MealPlanService {
    static async createMealPlan(date, course, listRecipe, group) {
        if (!date || !course) {
            return { code: 701, message: "Vui lòng cung cấp đầy đủ thông tin", data: "" };
        }

        const existingMealPlan = await MealPlan.findOne({ date: date, course: course, group: group });
        if (existingMealPlan) {
            return { code: 702, message: "MealPlan đã tồn tại trong group này", data: "" };
        }
        
        try {
            const newMealPlan = new MealPlan({ date, course, listRecipe, group });
            const savedMealPlan = await newMealPlan.save();
            return { code: 700, message: "Lưu MealPlan thành công", data: savedMealPlan };
        } catch (error) {
            console.error("Lỗi khi tạo MealPlan:", error);
            throw { code: 601, message: "Lỗi khi lưu MealPlan", data: "" };
        }
    }

    static async updateMealPlan(id, newData, group) {
        try {
            const existingMealPlan = await MealPlan.findOne({ date: newData.date, course: newData.course, group: group, _id: { $ne: id } });
            if (existingMealPlan) {
                return { code: 704, message: "MealPlan mới đã tồn tại trong group này", data: "" };
            }

            const updatedMealPlan = await MealPlan.findByIdAndUpdate(
                id,
                { $set: newData },
                { new: true, fields: { group: 0 } }
            );
            
            if (!updatedMealPlan) {
                return { code: 703, message: "Không tìm thấy MealPlan để cập nhật", data: "" };
            }

            return { code: 702, message: "Cập nhật MealPlan thành công", data: updatedMealPlan };
        } catch (error) {
            console.error('Lỗi khi cập nhật MealPlan:', error);
            throw { code: 601, message: "Lỗi khi cập nhật MealPlan", data: "" };
        }
    }

    static async deleteMealPlan(id) {
        try {
            const deleted = await MealPlan.findByIdAndDelete(id);
            if (!deleted) {
                return { code: 705, message: "Không tìm thấy MealPlan để xóa", data: "" };
            }
            return { code: 704, message: "Xóa MealPlan thành công", data: deleted };
        } catch (error) {
            console.error('Lỗi khi xóa MealPlan:', error);
            throw { code: 601, message: "Lỗi khi xóa MealPlan", data: "" };
        }
    }

    static async getMealPlanByDate(group, date) {
        try {
            const mealPlans = await MealPlan.find({ 
                group: group, 
                date: date
            });

            if (!mealPlans || mealPlans.length === 0) {
                return { code: 608, message: "Không tìm thấy MealPlan nào cho ngày và nhóm này", data: [] };
            }

            return { code: 700, message: "Lấy MealPlan thành công", data: mealPlans };
        } catch (error) {
            console.error("Lỗi khi lấy MealPlans theo ngày:", error);
            throw { code: 601, message: "Lỗi khi lấy MealPlans", data: "" };
        }
    }
}

export default MealPlanService;
