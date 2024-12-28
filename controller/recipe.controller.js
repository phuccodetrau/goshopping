import RecipeService from "../services/recipe.service.js";

const createRecipe = async (req, res, next) => {
    try {
        const { name, description, list_item, group } = req.body;
        const result = await RecipeService.createRecipe(name, description, list_item, group);
        res.json(result);
    } catch (error) {
        return res.json({code: 101, message: "Server error!", data: ""})
    }
};

const updateRecipe = async (req, res, next) => {
    try {
        const { recipeName, group, newData } = req.body;
        const result = await RecipeService.updateRecipe(recipeName, group, newData);
        res.json(result);
    } catch (error) {
        return res.json({code: 101, message: "Server error!", data: ""})
    }
};

const deleteRecipe = async (req, res, next) => {
    try {
        const { recipeName, group } = req.body;
        const result = await RecipeService.deleteRecipe(recipeName, group);
        res.json(result);
    } catch (error) {
        return res.json({code: 101, message: "Server error!", data: ""})
    }
};

const getRecipeByFood = async (req, res, next) => {
    try {
        const { foodName, group } = req.body;
        const result = await RecipeService.getRecipeByFood(foodName, group);
        res.json(result);
    } catch (error) {
        return res.json({code: 101, message: "Server error!", data: ""})
    }
};

const getAllRecipe = async (req, res, next) => {
    try {
        const { group } = req.body;
        const result = await RecipeService.getAllRecipe(group);
        res.json(result);
    } catch (error) {
        return res.json({code: 101, message: "Server error!", data: ""})
    }
};

const getAllFoodInReceipt = async (req, res, next) => {
    try {
        const { recipeName, group } = req.body;
        const result = await RecipeService.getAllFoodInReceipt(recipeName, group);
        res.json(result);
    } catch (error) {
        return res.json({code: 101, message: "Server error!", data: ""})
    }
};

const useRecipe = async (req, res, next) => {
    try {
        const { recipeName, group } = req.body;
        if (!recipeName || !group) {
            return res.json({
                code: 701,
                message: "Vui lòng cung cấp đầy đủ thông tin",
                data: ""
            });
        }
        const result = await RecipeService.useRecipe(recipeName, group);
        res.json(result);
    } catch (error) {
        return res.json({code: 101, message: "Server error!", data: ""})
    }
};

const checkRecipeAvailability = async (req, res, next) => {
    try {
        const { recipeName, group } = req.body;
        if (!recipeName || !group) {
            return res.json({
                code: 701,
                message: "Vui lòng cung cấp đầy đủ thông tin",
                data: ""
            });
        }
        const result = await RecipeService.checkRecipeAvailability(recipeName, group);
        res.json(result);
    } catch (error) {
        return res.json({code: 101, message: "Server error!", data: ""})
    }
};

export default { createRecipe, updateRecipe, deleteRecipe, getRecipeByFood, getAllRecipe, getAllFoodInReceipt, useRecipe, checkRecipeAvailability };
