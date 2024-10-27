import { MealPlan } from "../models/schema.js";

class MealPlanService {
    static async createMealPlan(date, course, listRecipe, group) {
        try {
            const newMealPlan = new MealPlan({ date, course, listRecipe, group });
            return await newMealPlan.save();
        } catch (error) {
            console.error("Lỗi khi tạo MealPlan:", error);
            throw error;
        }
    }    

    static async updateMealPlan(id, newData) {
        try {
            const updatedMealPlan = await MealPlan.findByIdAndUpdate(
                id,
                { $set: newData },
                { new: true, fields: { group: 0 } }
            );
    
            return updatedMealPlan;
        } catch (error) {
            console.error('Lỗi khi cập nhật MealPlan:', error);
            throw error;
        }
    }
    

    static async deleteMealPlan(id) {
        try {
            const deleted = await MealPlan.findByIdAndDelete(id);
            return deleted;
        } catch (error) {
            console.error('Lỗi khi xóa MealPlan:', error);
            throw error;
        }
    }
    

    static async getMealPlanByDate(group, date) {
        try {
            const mealPlans = await MealPlan.find({ 
                group: group, 
                date: date
            });
            return mealPlans;
        } catch (error) {
            console.error("Lỗi khi lấy MealPlans theo ngày:", error);
            throw error;
        }
    }
    
}

export default MealPlanService;
