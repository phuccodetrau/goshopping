import { ListTask, Group } from "../models/schema.js";
import NotificationService from "./notification.service.js";

class ListTaskService {
    static async createListTask(name, memberEmail, note, startDate, endDate, foodName, amount, unitName, state, group) {
        const newListTask = new ListTask({
            name, memberEmail, note, startDate, endDate, foodName, amount, unitName, state, group
        });

        try {
            const savedListTask = await newListTask.save();
            
            // Lấy thông tin group
            const groupInfo = await Group.findById(group);
            
            // Gửi thông báo chi tiết cho người được giao task
            await NotificationService.createTaskNotification(memberEmail, name, 'task_assigned', {
                groupName: groupInfo ? groupInfo.name : '',
                foodName,
                amount,
                unitName,
                startDate,
                endDate,
                note
            });
            
            return { code: 700, message: "Tạo phân công thành công", data: savedListTask };
        } catch (error) {
            console.error('Lỗi khi tạo phân công:', error);
            throw { code: 101, message: "Server error!", data: "" };
        }
    }

    static async updateListTaskById(listTaskId, name, memberEmail, note, startDate, endDate, foodName, amount, unitName, state, group) {
        try {
            const listTask = await ListTask.findById(listTaskId);
            if (!listTask) {
                return { code: 404, message: "Không tìm thấy ListTask với id này!", data: null };
            }

            // Kiểm tra nếu memberEmail thay đổi hoặc các thông tin quan trọng thay đổi
            const isSignificantChange = memberEmail !== undefined && memberEmail !== listTask.memberEmail ||
                                     name !== undefined && name !== listTask.name ||
                                     startDate !== undefined && startDate !== listTask.startDate ||
                                     endDate !== undefined && endDate !== listTask.endDate;

            if (name !== undefined) listTask.name = name;
            if (memberEmail !== undefined) listTask.memberEmail = memberEmail;
            if (note !== undefined) listTask.note = note;
            if (startDate !== undefined) listTask.startDate = startDate;
            if (endDate !== undefined) listTask.endDate = endDate;
            if (foodName !== undefined) listTask.foodName = foodName;
            if (amount !== undefined) listTask.amount = amount;
            if (unitName !== undefined) listTask.unitName = unitName;
            if (state !== undefined) listTask.state = state;
            if (group !== undefined) listTask.group = group;
            
            const updatedListTask = await listTask.save();

            // Nếu có thay đổi đáng kể, gửi thông báo chi tiết
            if (isSignificantChange) {
                const groupInfo = await Group.findById(updatedListTask.group);
                await NotificationService.createTaskNotification(
                    updatedListTask.memberEmail, 
                    updatedListTask.name,
                    'task_updated',
                    {
                        groupName: groupInfo ? groupInfo.name : '',
                        foodName: updatedListTask.foodName,
                        amount: updatedListTask.amount,
                        unitName: updatedListTask.unitName,
                        startDate: updatedListTask.startDate,
                        endDate: updatedListTask.endDate,
                        note: updatedListTask.note
                    }
                );
            }

            return {
                code: 200,
                message: "Cập nhật ListTask thành công",
                data: updatedListTask,
            };
        } catch (error) {
            console.error("Lỗi khi cập nhật ListTask:", error);
            throw { code: 500, message: "Server error!", data: null };
        }
    }
    // ... rest of the code ...
}

export default ListTaskService; 