import ItemService from "../services/item.service.js";

const createItem = async (req, res, next) => {
    try {
        const { foodName, expireDate, amount, note, group } = req.body;
        let itemData = await ItemService.createItem(foodName, expireDate, amount, note, group);
        res.json({ status: true, success: itemData });
    } catch (error) {
        console.log(error, 'err---->');
        next(error);
    }
}

const getAllItem = async (req, res, next) => {
    try {
        const { group } = req.body;
        let itemData = await ItemService.getAllItem(group);
        res.json({ status: true, success: itemData });
    } catch (error) {
        console.log(error, 'err---->');
        next(error);
    }
}

const getSpecificItem = async (req, res, next) => {
    try {
        const { foodName, group } = req.body;
        let itemData = await ItemService.getSpecificItem(foodName, group);
        res.json({ status: true, success: itemData });
    } catch (error) {
        console.log(error, 'err---->');
        next(error);
    }
}

const deleteItem = async (req, res, next) => {
    try {
        const { foodName, group } = req.body;
        let deletedData = await ItemService.deleteItem(foodName, group);
        res.json({ status: true, success: deletedData });
    } catch (error) {
        console.log(error, 'err---->');
        next(error);
    }
}


const updateItem = async (req, res, next) => {
    try {
        const { foodName, group, newData } = req.body;
        let updatedData = await ItemService.updateItem(foodName, group, newData);
        res.json({ status: true, success: updatedData });
    } catch (error) {
        console.log(error, 'err---->');
        next(error);
    }
}

export default { createItem, getAllItem, getSpecificItem, deleteItem, updateItem };