import FoodService from "../services/food.service.js";

const createFood = async (req, res, next) => {
    try {
        const { name, categoryName, unitName, image, group } = req.body;
        let foodData = await FoodService.createFood(name, categoryName, unitName, image, group);
        res.json({ status: true, success: foodData });
    } catch (error) {
        console.log(error, 'err---->');
        next(error);
    }
}

const getAllFood = async (req, res, next) => {
    try {
        const { group } = req.body;
        let foodData = await FoodService.getAllFood(group);
        res.json({ status: true, success: foodData });
    } catch (error) {
        console.log(error, 'err---->');
        next(error);
    }
}

const deleteFood = async (req, res, next) => {
    try {
        const { foodName, group } = req.body;
        let deletedData = await FoodService.deleteFood(foodName, group);
        res.json({ status: true, success: deletedData });
    } catch (error) {
        console.log(error, 'err---->');
        next(error);
    }
}


const updateFood = async (req, res, next) => {
    try {
        const { foodName, group, newData } = req.body;
        let updatedData = await FoodService.updateFood(foodName, group, newData);
        res.json({ status: true, success: updatedData });
    } catch (error) {
        console.log(error, 'err---->');
        next(error);
    }
}

export default { createFood, getAllFood, deleteFood, updateFood };