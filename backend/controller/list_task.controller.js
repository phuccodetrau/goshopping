import ListTaskService from '../services/listTask.service.js';

const createListTask = async (req, res, next) => {
    try {
        const { name, memberEmail, note, date, list_item, group } = req.body;
        let listTaskData = await ListTaskService.createListTask(name, memberEmail, note, date, list_item, group);
        res.json({ status: true, success: listTaskData });
    } catch (error) {
        console.log(error, 'err---->');
        next(error);
    }
}

const getListTasks = async (req, res, next) => {
    try {
        const { group } = req.query;
        let listTasks = await ListTaskService.getListTasks(group);
        res.json({ status: true, success: listTasks });
    } catch (error) {
        console.log(error, 'err---->');
        next(error);
    }
}

const updateListTask = async (req, res, next) => {
    try {
        const { id, updateData } = req.body;
        let updatedListTask = await ListTaskService.updateListTask(id, updateData);
        res.json({ status: true, success: updatedListTask });
    } catch (error) {
        console.log(error, 'err---->');
        next(error);
    }
}

const deleteListTask = async (req, res, next) => {
    try {
        const { id } = req.body;
        let deletedListTask = await ListTaskService.deleteListTask(id);
        res.json({ status: true, success: deletedListTask });
    } catch (error) {
        console.log(error, 'err---->');
        next(error);
    }
}

export default { createListTask, getListTasks, updateListTask, deleteListTask };