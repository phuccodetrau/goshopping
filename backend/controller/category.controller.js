import CategoryService from "../services/category.service.js";

const createCategory = async (req, res, next) => {
    try {
        const { categoryName, groupId } = req.body;
        const result = await CategoryService.createCategory(categoryName, groupId);
        res.json(result);
    } catch (error) {
        return res.json({ code: 101, message: "Server error!", data: "" });
    }
};

const getAllCategory = async (req, res, next) => {
    try {
        const { groupId } = req.params;
        const result = await CategoryService.getAllCategory(groupId);
        res.json(result);
    } catch (error) {
        return res.json({ code: 101, message: "Server error!", data: "" });
    }
};

const updateCategory = async (req, res, next) => {
    try {
        const { oldName, newName, groupId } = req.body;
        const result = await CategoryService.editCategory(oldName, newName, groupId);
        res.json(result);
    } catch (error) {
        return res.json({ code: 101, message: "Server error!", data: "" });
    }
};

const deleteCategory = async (req, res, next) => {
    try {
        const { name, groupId } = req.body;
        const result = await CategoryService.deleteCategory(name, groupId);
        res.json(result);
    } catch (error) {
        return res.json({ code: 101, message: "Server error!", data: "" });
    }
};

export default { createCategory, getAllCategory, updateCategory, deleteCategory };
