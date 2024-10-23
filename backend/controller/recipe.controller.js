import RecipeService from "../services/recipe.service.js";

const createRecipe = async (req, res, next) => {
    try {
        const { name, description, list_item, group } = req.body;
        let recipeData = await RecipeService.createRecipe(name, description, list_item, group);
        res.json({ status: true, success: recipeData });
    } catch (error) {
        console.log(error, 'err---->');
        next(error);
    }
}

const getRecipeByFood = async (req, res, next) => {
    try {
        const { foodName, group } = req.body;
        let recipeData = await RecipeService.getRecipeByFood(foodName, group);
        res.json({ status: true, success: recipeData });
    } catch (error) {
        console.log(error, 'err---->');
        next(error);
    }
}

const deleteRecipe = async (req, res, next) => {
    try {
        const { recipeName, group } = req.body;
        let deletedData = await RecipeService.deleteRecipe(recipeName, group);
        res.json({ status: true, success: deletedData });
    } catch (error) {
        console.log(error, 'err---->');
        next(error);
    }
}


const updateRecipe = async (req, res, next) => {
    try {
        const { recipeName, group, newData } = req.body;
        let updatedData = await RecipeService.updateRecipe(recipeName, group, newData);
        res.json({ status: true, success: updatedData });
    } catch (error) {
        console.log(error, 'err---->');
        next(error);
    }
}

export default { createRecipe, getRecipeByFood, deleteRecipe, updateRecipe };