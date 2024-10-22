import { Food } from "../models/schema.js";

class FoodService {
    static async createFood(name, categoryName, unitName, image, group) {
        const createFood = new Food({ name, categoryName, unitName, image, group });
        return await createFood.save();
    }

    static async updateFood(foodName, group, newData) {
        try {
            const updatedFood = await Food.findOneAndUpdate(
                { name: foodName, group: group },
                { $set: newData },
                { new: true }
            );

            return updatedFood;
        } catch (error) {
            console.error('Error updating food:', error);
            throw error;
        }
    }

    static async deleteFood(foodName, group) {
        const deleted = await Food.findOneAndDelete({ name: foodName, group: group });
        return deleted;
    }

    static async getAllFood(group) {
        const foods = await Food.find({ group: group });
        return foods;
    }
}

export default FoodService;
