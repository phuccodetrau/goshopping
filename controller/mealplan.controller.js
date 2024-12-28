import MealPlanService from "../services/mealplan.service.js";
import { MealPlan } from "../models/schema.js";
import mongoose from 'mongoose';

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
    
    const startDate = new Date(year, month - 1, 1);
    const endDate = new Date(year, month, 0);
    
    const stats = await MealPlan.aggregate([
      {
        $match: {
          group: new mongoose.Types.ObjectId(groupId),
          date: { 
            $gte: startDate,
            $lte: endDate
          }
        }
      },
      {
        $lookup: {
          from: 'recipes',
          localField: 'listRecipe',
          foreignField: '_id',
          as: 'recipes'
        }
      },
      {
        $unwind: "$recipes"
      },
      {
        $group: {
          _id: {
            recipeName: "$recipes.name",
            week: { $week: "$date" }
          },
          useCount: { $sum: 1 },
          ingredients: { $first: "$recipes.list_item" },
          description: { $first: "$recipes.description" }
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
          ingredients: { $first: "$ingredients" },
          description: { $first: "$description" }
        }
      },
      {
        $sort: { totalUseCount: -1 }
      }
    ]);

    const foodConsumption = {};
    stats.forEach(recipe => {
      recipe.ingredients.forEach(ingredient => {
        const foodName = ingredient.foodName;
        const amountPerUse = ingredient.amount;
        const totalAmount = amountPerUse * recipe.totalUseCount;

        if (!foodConsumption[foodName]) {
          foodConsumption[foodName] = {
            totalAmount: 0,
            usedInRecipes: []
          };
        }
        foodConsumption[foodName].totalAmount += totalAmount;
        foodConsumption[foodName].usedInRecipes.push({
          recipeName: recipe._id,
          amountPerUse: amountPerUse,
          useCount: recipe.totalUseCount
        });
      });
    });

    res.status(200).json({
      code: 700,
      message: "Success",
      data: {
        month,
        year,
        recipeStats: stats.map(item => ({
          recipeName: item._id,
          description: item.description,
          totalUseCount: item.totalUseCount,
          weeklyStats: item.weeklyStats,
          ingredients: item.ingredients
        })),
        foodConsumption: Object.entries(foodConsumption).map(([foodName, data]) => ({
          foodName,
          totalAmount: data.totalAmount,
          usedInRecipes: data.usedInRecipes
        }))
      }
    });
  } catch (error) {
    console.error('Error in getMealPlanStats:', error);
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
