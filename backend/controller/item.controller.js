import ItemService from "../services/item.service.js";

const createItem = async (req, res, next) => {
    try {
        const { foodName, expireDate, amount, note, group } = req.body;
        let itemData = await ItemService.createItem(foodName, expireDate, amount, note, group);
        return res.json(itemData);
    } catch (error) {
        return res.json({code: 101, message: "Server error!", data: ""})
    }
}

const getAllItem = async (req, res, next) => {
    try {
        const { group } = req.body;
        const result = await ItemService.getAllItem(group);
        res.json(result);
    } catch (error) {
        return res.json({code: 101, message: "Server error!", data: ""})
    }
}

const getSpecificItem = async (req, res, next) => {
    try {
        const { foodName, group } = req.body;
        const result = await ItemService.getSpecificItem(foodName, group);
        res.json(result);
    } catch (error) {
        return res.json({code: 101, message: "Server error!", data: ""})
    }
};

const deleteItem = async (req, res, next) => {
    try {
        const { id } = req.body;
        const result = await ItemService.deleteItem(id);
        res.json(result);
    } catch (error) {
        return res.json({code: 101, message: "Server error!", data: ""})
    }
}


const updateItem = async (req, res, next) => {
    try {
        const { id, newData } = req.body;
        let updatedData = await ItemService.updateItem(id, newData);
        return res.json(updatedData);
    } catch (error) {
        return res.json({code: 101, message: "Server error!", data: ""})
    }
}

export default { createItem, getAllItem, getSpecificItem, deleteItem, updateItem };