import { MealPlan, Group, Recipe } from "../models/schema.js";

class MealPlanService {
    static async createMealPlan(date, course, recipe_ids, group_id) {
        try {
            // Validate required fields
            if (!date || !course || !group_id || !recipe_ids) {
                return { code: 701, message: "Vui lòng cung cấp đầy đủ thông tin", data: "" };
            }

            // Check if group exists
            const group = await Group.findById(group_id);
            if (!group) {
                return { code: 703, message: "Group không tồn tại", data: "" };
            }

            // Check if all recipes exist
            const recipes = await Recipe.find({ _id: { $in: recipe_ids } });
            if (recipes.length !== recipe_ids.length) {
                return { code: 704, message: "Một số công thức không tồn tại", data: "" };
            }

            // Check if mealplan already exists for this date and course
            const existingMealPlan = await MealPlan.findOne({ 
                date: date, 
                course: course, 
                group: group_id 
            });
            
            if (existingMealPlan) {
                return { code: 702, message: "MealPlan đã tồn tại trong group này", data: "" };
            }
            
            // Create new mealplan
            const newMealPlan = new MealPlan({ 
                date, 
                course, 
                listRecipe: recipe_ids,
                group: group_id 
            });
            
            const savedMealPlan = await newMealPlan.save();
            
            // Populate recipe details for response
            const populatedMealPlan = await MealPlan.findById(savedMealPlan._id)
                .populate('listRecipe', 'name description');

            return { 
                code: 700, 
                message: "Lưu MealPlan thành công", 
                data: populatedMealPlan 
            };
        } catch (error) {
            console.error("Lỗi khi tạo MealPlan:", error);
            throw { code: 601, message: "Lỗi khi lưu MealPlan", data: "" };
        }
    }

    static async updateMealPlan(mealplan_id, date, course, recipe_ids, group_id) {
        try {
            // Validate required fields (except mealplan_id)
            if (!date || !course || !recipe_ids || !group_id) {
                return { code: 701, message: "Vui lòng cung cấp đầy đủ thông tin", data: "" };
            }

            // Check if group exists
            const group = await Group.findById(group_id);
            if (!group) {
                return { code: 703, message: "Group không tồn tại", data: "" };
            }

            // Check if all recipes exist
            const recipes = await Recipe.find({ _id: { $in: recipe_ids } });
            if (recipes.length !== recipe_ids.length) {
                return { code: 704, message: "Một số công thức không tồn tại", data: "" };
            }

            // Check if there's a duplicate meal plan (same date and course)
            const duplicateQuery = {
                date: date,
                course: course,
                group: group_id
            };

            // If updating existing meal plan, exclude it from duplicate check
            if (mealplan_id) {
                duplicateQuery._id = { $ne: mealplan_id };
            }

            const duplicateMealPlan = await MealPlan.findOne(duplicateQuery);
            if (duplicateMealPlan) {
                return { code: 706, message: "Đã tồn tại MealPlan khác vào ngày và buổi này", data: "" };
            }

            let updatedMealPlan;

            if (!mealplan_id) {
                // Create new meal plan if no ID provided
                const newMealPlan = new MealPlan({
                    date,
                    course,
                    listRecipe: recipe_ids,
                    group: group_id
                });
                updatedMealPlan = await newMealPlan.save();
                updatedMealPlan = await MealPlan.findById(updatedMealPlan._id)
                    .populate('listRecipe', 'name description');

                return {
                    code: 700,
                    message: "Tạo mới MealPlan thành công",
                    data: updatedMealPlan
                };
            } else {
                // Update existing meal plan
                const existingMealPlan = await MealPlan.findById(mealplan_id);
                if (!existingMealPlan) {
                    // If specified ID not found, create new
                    const newMealPlan = new MealPlan({
                        date,
                        course,
                        listRecipe: recipe_ids,
                        group: group_id
                    });
                    updatedMealPlan = await newMealPlan.save();
                    updatedMealPlan = await MealPlan.findById(updatedMealPlan._id)
                        .populate('listRecipe', 'name description');

                    return {
                        code: 700,
                        message: "Tạo mới MealPlan thành công",
                        data: updatedMealPlan
                    };
                }

                // Update existing meal plan
                updatedMealPlan = await MealPlan.findByIdAndUpdate(
                    mealplan_id,
                    {
                        date: date,
                        course: course,
                        listRecipe: recipe_ids,
                        group: group_id
                    },
                    { new: true }
                ).populate('listRecipe', 'name description');

                return {
                    code: 700,
                    message: "Cập nhật MealPlan thành công",
                    data: updatedMealPlan
                };
            }
        } catch (error) {
            console.error("Lỗi khi cập nhật/tạo mới MealPlan:", error);
            throw { code: 101, message: "Server error!", data: "" };
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
            }).populate('listRecipe', 'name description');

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
