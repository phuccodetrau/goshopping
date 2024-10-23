import { Recipe } from "../models/schema.js";

class RecipeService {
    static async createRecipe(name, description, list_item, group) {
        const createRecipe = new Recipe({ name, description, list_item, group });
        return await createRecipe.save();
    }

    static async updateRecipe(recipeName, group, newData) {
        try {
            const updatedRecipe = await Recipe.findOneAndUpdate(
                { name: recipeName, group: group },
                { $set: newData },
                { new: true }
            );

            return updatedRecipe;
        } catch (error) {
            console.error('Error updating food:', error);
            throw error;
        }
    }

    static async deleteRecipe(recipeName, group) {
        const deleted = await Recipe.findOneAndDelete({ name: recipeName, group: group });
        return deleted;
    }

    static async getRecipeByFood(foodName, group) {
        const recipes = await Recipe.find({
            group: group,
            list_item: { $elemMatch: { foodName: foodName } }
        });
        return recipes;
    }
}

export default RecipeService;
