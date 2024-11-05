import FoodService from "../services/food.service.js";

const createFood = async (req, res, next) => {
    try {
        const { name, categoryName, unitName, image, group } = req.body;

        if (!name || !categoryName || !unitName || !image || !group) {
            return res.json({ code: 601, message: "Vui lòng cung cấp đầy đủ thông tin", data: "" });
        }

        let foodData = await FoodService.createFood(name, categoryName, unitName, image, group);

        return res.json({
            code: foodData.code,
            message: foodData.message,
            data: foodData.data
        });
    } catch (error) {
        return res.json({code: 101, message: "Server error!", data: ""})
    }
}

const getAllFood = async (req, res, next) => {
    try {
        const { group } = req.body;

        let foodData = await FoodService.getAllFood(group);

        return res.json({
            code: foodData.code,
            message: foodData.message,
            data: foodData.data
        });
    } catch (error) {
        console.log(error, "err---->");
        next(error);
    }
}

const deleteFood = async (req, res, next) => {
    try {
        const { foodName, group } = req.body;

        let deletedData = await FoodService.deleteFood(foodName, group);

        return res.json({
            code: deletedData.code,
            message: deletedData.message,
            data: deletedData.data
        });
    } catch (error) {
        return res.json({code: 101, message: "Server error!", data: ""})
    }
}


const updateFood = async (req, res, next) => {
    try {
        const { foodName, group, newData } = req.body;

        let updatedData = await FoodService.updateFood(foodName, group, newData);

        return res.json({
            code: updatedData.code,
            message: updatedData.message,
            data: updatedData.data
        });
    } catch (error) {
        return res.json({code: 101, message: "Server error!", data: ""})
    }
}

export default { createFood, getAllFood, deleteFood, updateFood };