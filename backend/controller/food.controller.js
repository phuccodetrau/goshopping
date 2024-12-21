import FoodService from "../services/food.service.js";
import GroupService from "../services/group.service.js";

const createFood = async (req, res, next) => {
    try {
        const { name, categoryName, unitName, image, group } = req.body;
        

        if (!name || !categoryName || !unitName || !group) {
            
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
        const { groupId } = req.body;

        if (!groupId) {
            return res.json({ code: 601, message: "Vui lòng cung cấp groupId", data: [] });
        }

        let foodData = await FoodService.getAllFood(groupId);

        return res.json({
            code: foodData.code,
            message: foodData.message,
            data: foodData.data
        });
    } catch (error) {
        console.log(error, "err---->");
        return res.json({ code: 101, message: "Server error!", data: [] });
    }
}

const getUnavailableFoods = async (req, res, next) => {
    try {
        const { groupId } = req.params;

        let foodData = await FoodService.getUnavailableFoods(groupId);

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

const getFoodsByCategory = async (req, res) => {
    try {
        const { groupId, categoryName } = req.body;

        // Lấy danh sách foods theo groupId và categoryName
        const foodResult = await FoodService.getFoodsByCategory(groupId, categoryName);

        if (foodResult.code !== 600) {
            return res.status(404).json(foodResult); // Trả về nếu không có foods
        }

        const foods = foodResult.data;

        // Duyệt qua từng food để lấy totalAmount từ ItemService
        const foodsWithAmount = await Promise.all(
            foods.map(async (food) => {
                const itemResult = await GroupService.getTotalAmountByFoodName(groupId, food.name);
                const totalAmount = itemResult.code === 700 ? itemResult.data.totalAmount : 0;
                
                // Bổ sung trường totalAmount vào food
                return {
                    ...food.toObject(), // Chuyển mongoose document thành object
                    totalAmount
                };
            })
        );

        // Trả danh sách foods với trường totalAmount
        return res.status(200).json({
            code: 600,
            message: "Lấy danh sách thực phẩm thành công",
            data: foodsWithAmount
        });
    } catch (error) {
        console.error("Error in getFoodsByCategory:", error);
        return res.status(500).json({ code: 101, message: "Server error!", data: "" });
    }
};

const getFoodImageByName = async (req, res) => {
    try {
        const { groupId, foodName } = req.body;
        const result = await FoodService.getFoodImageByName(groupId, foodName);
        return res.status(result.code === 700? 200 : 404).json(result);
    } catch (error) {
        return res.status(500).json(error);
    }
};
export default { createFood, getAllFood, getUnavailableFoods , deleteFood, updateFood, getFoodsByCategory, getFoodImageByName };