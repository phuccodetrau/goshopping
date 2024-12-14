import MealPlanService from "../services/mealplan.service.js";
import { MealPlan } from "../models/schema.js";

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

const getMealPlanStats = async (req, res) => {
  try {
    const { groupId, month, year } = req.body;
    
    // Tạo ngày đầu và cuối tháng
    const startDate = new Date(year, month - 1, 1);
    const endDate = new Date(year, month, 0);
    
    const stats = await MealPlan.aggregate([
      {
        $match: {
          group: groupId,
          date: { 
            $gte: startDate,
            $lte: endDate
          }
        }
      },
      {
        $unwind: "$listRecipe"
      },
      {
        $group: {
          _id: {
            recipeName: "$listRecipe.name",
            week: { $week: "$date" } // Nhóm theo tuần trong tháng
          },
          useCount: { $sum: 1 },
          ingredients: { $first: "$listRecipe.ingredients" }
        }
      },
      {
        $group: {
          _id: "$_id.recipeName",
          weeklyStats: {
            $push: {
              week: "$_id.week",
              useCount: "$useCount"
            }
          },
          totalUseCount: { $sum: "$useCount" },
          ingredients: { $first: "$ingredients" }
        }
      },
      {
        $sort: { totalUseCount: -1 }
      }
    ]);

    res.status(200).json({
      code: 700,
      message: "Success",
      data: {
        month: month,
        year: year,
        stats: stats.map(item => ({
          recipeName: item._id,
          totalUseCount: item.totalUseCount,
          weeklyStats: item.weeklyStats,
          ingredients: item.ingredients
        }))
      }
    });
  } catch (error) {
    res.status(500).json({
      code: 500,
      message: error.message
    });
  }
};

const getMealPlanStatsByRecipe = async (req, res) => {
    try {
        const { groupId, recipeName } = req.body;
        res.status(200).json({
            code: 700,
            message: "Success",
            data: []
        });
    } catch (error) {
        res.status(500).json({
            code: 500,
            message: error.message
        });
    }
};

const getMealPlanStatsByDate = async (req, res) => {
    try {
        const { groupId, date } = req.body;
        res.status(200).json({
            code: 700,
            message: "Success",
            data: []
        });
    } catch (error) {
        res.status(500).json({
            code: 500,
            message: error.message
        });
    }
};

export default { 
    createMealPlan, 
    updateMealPlan, 
    deleteMealPlan, 
    getMealPlanByDate, 
    getMealPlanStats,
    getMealPlanStatsByRecipe,
    getMealPlanStatsByDate
};
