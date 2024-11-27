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


export default {createListTask}