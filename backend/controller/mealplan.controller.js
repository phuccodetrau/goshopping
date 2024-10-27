import MealPlanService from "../services/mealplan.service.js";

const createMealPlan = async (req, res, next) => {
    try {
        const { date, course, listRecipe, group } = req.body;
        let mealplanData = await MealPlanService.createMealPlan(date, course, listRecipe, group);
        res.json({ status: true, success: mealplanData });
    } catch (error) {
        console.log(error, 'err---->');
        next(error);
    }
}

const getMealPlanByDate = async (req, res, next) => {
    try {
        const { group, date } = req.body;
        let mealplanData = await MealPlanService.getMealPlanByDate(group, date);
        res.json({ status: true, success: mealplanData });
    } catch (error) {
        console.log(error, 'err---->');
        next(error);
    }
}


const deleteMealPlan = async (req, res, next) => {
    try {
        const { id } = req.body;
        let deletedData = await MealPlanService.deleteMealPlan(id);
        res.json({ status: true, success: deletedData });
    } catch (error) {
        console.log(error, 'err---->');
        next(error);
    }
}


const updateMealPlan = async (req, res, next) => {
    try {
        const { id, newData } = req.body;
        let updatedData = await MealPlanService.updateMealPlan(id, newData);
        res.json({ status: true, success: updatedData });
    } catch (error) {
        console.log(error, 'err---->');
        next(error);
    }
}

export default { createMealPlan, getMealPlanByDate, deleteMealPlan, updateMealPlan };