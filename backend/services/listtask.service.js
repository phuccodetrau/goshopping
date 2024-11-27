import { ListTask } from "../models/schema.js";

class ListTaskService {
    static async createListTask(name, memberEmail, note, startDate, endDate, foodName, amount, unitName, state, group) {
        const newListTask = new ListTask({
            name, memberEmail, note, startDate, endDate, foodName, amount, unitName, state, group
        });

        try {
            const savedListTask = await newListTask.save();
            return { code: 700, message: "Tạo phân công thành công", data: savedListTask };
        } catch (error) {
            console.error('Lỗi khi tạo phân công:', error);
            throw { code: 101, message: "Server error!", data: "" };
        }
    }
}

export default ListTaskService; 