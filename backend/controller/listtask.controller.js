import ListTaskService from "../services/listtask.service.js";

const createListTask = async (req, res) => {
    try {
        const { name, memberEmail, note, startDate, endDate, foodName, amount, unitName, state, group } = req.body;
        const result = await ListTaskService.createListTask(name, memberEmail, note, startDate, endDate, foodName, amount, unitName, state, group);
        return res.status(result.code === 700 ? 201 : 400).json(result);
    } catch (error) {
        return res.status(500).json(error);
    }
};

const updateListTaskById = async (req, res) => {
    try {
        const { listTaskId, name, memberEmail, note, startDate, endDate, foodName, amount, unitName, state, group } = req.body;
        const result = await ListTaskService.updateListTaskById(listTaskId, name, memberEmail, note, startDate, endDate, foodName, amount, unitName, state, group);
        return res.status(result.code === 200 ? 200 : 404).json(result);
    } catch (error) {
        return res.status(500).json(error);
    }
};

const deleteListTaskById = async (req, res) => {
    try {
        const { listTaskId } = req.body;
        const result = await ListTaskService.deleteListTaskById(listTaskId);
        return res.status(result.code === 200 ? 200 : 404).json(result);
    } catch (error) {
        return res.status(500).json(error);
    }
};

const getListTasksByNameAndGroup = async (req, res) => {
    try {
        const { name, group, state, startDate, endDate, page, limit } = req.body;
        const result = await ListTaskService.getListTasksByNameAndGroup(name, group, state, startDate, endDate, page, limit);
        return res.status(result.code === 200 ? 200 : 404).json(result);
    } catch (error) {
        return res.status(500).json(error);
    }
};


const getAllListTasksByGroup = async (req, res) => {
    try {
        const { group, state, startDate, endDate, page, limit } = req.body;
        const result = await ListTaskService.getAllListTasksByGroup(group, state, startDate, endDate, page, limit);
        return res.status(result.code === 200 ? 200 : 404).json(result);
    } catch (error) {
        return res.status(500).json(error);
    }
};

const createItemFromListTask = async (req, res) => {
    try {
        const { listTaskId, extraDays, note } = req.body;
        const result = await ListTaskService.createItemFromListTask(listTaskId, extraDays, note);
        return res.status(result.code === 201 ? 200 : 404).json(result);
    } catch (error) {
        return res.status(500).json(error);
    }
};



export default {createListTask, updateListTaskById, deleteListTaskById, getAllListTasksByGroup, getListTasksByNameAndGroup, createItemFromListTask}