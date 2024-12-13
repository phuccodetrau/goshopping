import ItemService from "../services/item.service.js";

const createItem = async (req, res, next) => {
    try {
        const { foodName, expireDate, amount, unitName, note, group } = req.body;
        const result = await ItemService.createItem(foodName, expireDate, amount, unitName, note, group);
        res.json(result);
    } catch (error) {
        return res.json({code: 101, message: "Server error!", data: ""})
    }
};

const updateItem = async (req, res, next) => {
    try {
        const { id, newData } = req.body;
        const result = await ItemService.updateItem(id, newData);
        res.json(result);
    } catch (error) {
        return res.json({code: 101, message: "Server error!", data: ""})
    }
};

const deleteItem = async (req, res, next) => {
    try {
        const { itemId } = req.body;
        const result = await ItemService.deleteItem(itemId);
        res.json(result);
    } catch (error) {
        return res.json({code: 101, message: "Server error!", data: ""})
    }
};

const getAllItem = async (req, res, next) => {
    try {
        const { group } = req.body;
        const result = await ItemService.getAllItem(group);
        res.json(result);
    } catch (error) {
        return res.json({code: 101, message: "Server error!", data: ""})
    }
};

const getSpecificItem = async (req, res, next) => {
    try {
        const { foodName, group } = req.body;
        if (!foodName || !group) {
            return res.json({code: 400, message: "Thiếu thông tin foodName hoặc group", data: ""});
        }
        const result = await ItemService.getSpecificItem(foodName, group);
        res.json(result);
    } catch (error) {
        return res.json({code: 101, message: "Server error!", data: ""})
    }
};

const getItemDetail = async (req, res, next) => {
    try {
        const { foodName, group } = req.body;
        
        // Validate input
        if (!foodName || !group) {
            return res.json({
                code: 802,
                message: "Thiếu thông tin foodName hoặc group",
                data: null
            });
        }

        const result = await ItemService.getItemDetail(foodName, group);
        res.json(result);
    } catch (error) {
        console.error("Lỗi trong getItemDetail controller:", error);
        return res.json({
            code: 803,
            message: "Lỗi server khi lấy thông tin item",
            data: null
        });
    }
};

export default { createItem, updateItem, deleteItem, getAllItem, getSpecificItem, getItemDetail };