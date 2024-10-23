import { ListTask } from "../models/schema.js";

class ListTaskService {
    static async createListTask(name, memberEmail, note, date, list_item, group) {
        const newListTask = new ListTask({ name, memberEmail, note, date, list_item, group });
        return await newListTask.save();
    }

    static async getListTasks(group) {
        return await ListTask.find({ group: group });
    }

    static async updateListTask(id, updateData) {
        return await ListTask.findByIdAndUpdate(id, updateData, { new: true });
    }

    static async deleteListTask(id) {
        return await ListTask.findByIdAndDelete(id);
    }
}

export default ListTaskService;