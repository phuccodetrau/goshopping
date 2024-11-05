import MealPlanService from "../services/mealplan.service.js";

const createMealPlan = async (req, res, next) => {
    try {
        const { date, course, listRecipe, group } = req.body;
        const result = await MealPlanService.createMealPlan(date, course, listRecipe, group);
        res.json(result);
    } catch (error) {
        return res.json({ code: 101, message: "Server error!", data: "" });
    }
};

const updateMealPlan = async (req, res, next) => {
    try {
        const { id, newData, group } = req.body;
        const result = await MealPlanService.updateMealPlan(id, newData, group);
        res.json(result);
    } catch (error) {
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
