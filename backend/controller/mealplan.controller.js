import MealPlanService from "../services/mealplan.service.js";


const createMealPlan = async (req, res, next) => {
    try {
        const { date, course, recipe_ids, group_id } = req.body;
        
        if (!date || !course || !group_id || !recipe_ids) {
            return res.json({ 
                code: 701, 
                message: "Vui lòng cung cấp đầy đủ thông tin", 
                data: "" 
            });
        }

        const result = await MealPlanService.createMealPlan(date, course, recipe_ids, group_id);
        res.json(result);
    } catch (error) {
        console.error("Error in createMealPlan:", error);
        return res.json({ code: 101, message: "Server error!", data: "" });
    }
};

const updateMealPlan = async (req, res, next) => {
    try {
        const { mealplan_id, date, course, recipe_ids, group_id } = req.body;
        
        if (!date || !course || !recipe_ids || !group_id) {
            return res.json({ 
                code: 701, 
                message: "Vui lòng cung cấp đầy đủ thông tin", 
                data: "" 
            });
        }

        const result = await MealPlanService.updateMealPlan(
            mealplan_id, 
            date, 
            course, 
            recipe_ids, 
            group_id
        );
        
        res.json(result);
    } catch (error) {
        console.error("Error in updateMealPlan:", error);
        return res.json({ code: 101, message: "Server error!", data: "" });
    }
};

const deleteMealPlan = async (req, res, next) => {
    try {
        const { id } = req.body;
        const result = await MealPlanService.deleteMealPlan(id);
        res.json(result);
    } catch (error) {
        return res.json({ code: 101, message: "Server error!", data: "" });
    }
};

const getMealPlanByDate = async (req, res, next) => {
    try {
        const { group, date } = req.body;
        const result = await MealPlanService.getMealPlanByDate(group, date);
        res.json(result);
    } catch (error) {
        return res.json({ code: 101, message: "Server error!", data: "" });
    }
};

export default { createMealPlan, updateMealPlan, deleteMealPlan, getMealPlanByDate };
