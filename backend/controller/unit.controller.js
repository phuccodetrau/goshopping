import UnitService from "../services/unit.service.js";

const createUnit = async (req, res, next) => {
    try {
        const { unitName, groupId } = req.body;
        const result = await UnitService.createUnit(unitName, groupId);
        res.json(result);
    } catch (error) {
        return res.json({ code: 101, message: "Server error!", data: "" });
    }
};

const getAllUnit = async (req, res, next) => {
    try {
        const { groupId } = req.params;
        const result = await UnitService.getAllUnit(groupId);
        res.json(result);
    } catch (error) {
        return res.json({ code: 101, message: "Server error!", data: "" });
    }
};

const updateUnit = async (req, res, next) => {
    try {
        const { oldName, newName, groupId } = req.body;
        const result = await UnitService.editUnit(oldName, newName, groupId);
        res.json(result);
    } catch (error) {
        return res.json({ code: 101, message: "Server error!", data: "" });
    }
};

const deleteUnit = async (req, res, next) => {
    try {
        const { name, groupId } = req.body;
        const result = await UnitService.deleteUnit(name, groupId);
        res.json(result);
    } catch (error) {
        return res.json({ code: 101, message: "Server error!", data: "" });
    }
};

export default { createUnit, getAllUnit, updateUnit, deleteUnit };
