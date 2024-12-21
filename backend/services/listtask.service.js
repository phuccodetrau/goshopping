import { ListTask, Item } from "../models/schema.js";
import NotificationService from "./notification.service.js";

class ListTaskService {
    static async createListTask(name, memberEmail, note, startDate, endDate, foodName, amount, unitName, state, group) {
        const newListTask = new ListTask({
            name, memberEmail, note, startDate, endDate, foodName, amount, unitName, state, group
        });

        try {
            const savedListTask = await newListTask.save();
            
            // Gửi thông báo cho người được giao task
            await NotificationService.createTaskNotification(memberEmail, name, 'task_assigned');
            
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

            // Nếu có thay đổi đáng kể, gửi thông báo
            if (isSignificantChange) {
                await NotificationService.createTaskNotification(
                    updatedListTask.memberEmail, 
                    updatedListTask.name,
                    'task_updated'
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

    static async deleteListTaskById(listTaskId) {
        try {
            console.log("Nhận api xóa listtask");
            
            const deletedListTask = await ListTask.findByIdAndDelete(listTaskId);
            if (!deletedListTask) {
                console.log("lỗi k tìm thấy");
                
                return { code: 404, message: "Không tìm thấy ListTask với id này!", data: null };
            }
            console.log("Xóa listtask thành công");

            return {
                code: 200,
                message: "Xóa ListTask thành công",
                data: deletedListTask,
            };
            
        } catch (error) {
            console.error("Lỗi khi xóa ListTask:", error);
            throw { code: 500, message: "Server error!", data: null };
        }
    }

    static async getListTasksByNameAndGroup(name, group, state = "T��t cả", startDate = "", endDate = "", page = 1, limit = 3) {
        try {
            const filter = { name, group };
    
            // Lọc theo state
            if (state === "Chưa hoàn thành") {
                filter.state = false;
                const today = new Date();
                filter.endDate = { $gt: today }; 
            } else if (state === "Hoàn thành") {
                filter.state = true;
            } else if (state === "Quá hạn") {
                filter.state = false;
                const today = new Date();
                filter.endDate = { $lt: today }; // endDate nhỏ hơn ngày hôm nay
            }
            if (startDate != "") {
                filter.startDate = { ...filter.startDate, $gte: new Date(startDate) }; // lớn hơn hoặc bằng
            }
            if (endDate != "") {
                filter.endDate = { ...filter.endDate, $lte: new Date(endDate) }; // nhỏ hơn hoặc bằng
            }
            const skip = (page - 1) * limit;
            const listTasks = await ListTask.find(filter).skip(skip).limit(limit);
            console.log(listTasks);
            
            const totalRecords = await ListTask.countDocuments(filter);
    
            return {
                code: 200,
                message: "Truy vấn thành công",
                data: listTasks,
                // pagination: {
                //     currentPage: page,
                //     totalPages: Math.ceil(totalRecords / limit),
                //     totalRecords,
                // },
            };
        } catch (error) {
            console.error('Lỗi khi lấy danh sách phân công:', error);
            throw { code: 101, message: "Server error!", data: "" };
        }
    }
    static async getAllListTasksByGroup(group, state = "Tất cả", startDate = "", endDate = "", page = 1, limit = 3) {
        try {
            const filter = { group };
            if (state === "Chưa hoàn thành") {
                filter.state = false;
                const today = new Date();
                filter.endDate = { $gt: today }; 
            } else if (state === "Hoàn thành") {
                filter.state = true;
            } else if (state === "Quá hạn") {
                filter.state = false;
                const today = new Date();
                filter.endDate = { $lt: today };
            }
            if (startDate !== "") {
                filter.startDate = { ...filter.startDate, $gte: new Date(startDate) };
            }
            if (endDate !== "") {
                filter.endDate = { ...filter.endDate, $lte: new Date(endDate) };
            }
            const skip = (page - 1) * limit;
            const listTasks = await ListTask.find(filter).skip(skip).limit(limit);
            const totalRecords = await ListTask.countDocuments(filter);
    
            return {
                code: 200,
                message: "Truy vấn thành công",
                data: listTasks,
                // pagination: {
                //     currentPage: page,
                //     totalPages: Math.ceil(totalRecords / limit),
                //     totalRecords,
                // },
            };
        } catch (error) {
            console.error('Lỗi khi lấy danh sách phân công:', error);
            throw { code: 101, message: "Server error!", data: "" };
        }
    }

    static async createItemFromListTask(listTaskId, extraDays, note) {
        try {
            const listTask = await ListTask.findById(listTaskId);
            if (!listTask) {
                return { code: 404, message: "Không tìm thấy ListTask!", data: null };
            }
            const today = new Date();
            const expireDate = new Date(today.setDate(today.getDate() + extraDays));
            const newItem = new Item({
                foodName: listTask.foodName,
                expireDate: expireDate,
                amount: listTask.amount,
                unitName: listTask.unitName,
                note: note,
                group: listTask.group,
            });

            const savedItem = await newItem.save();
            listTask.state = true;
            await listTask.save();

            return {
                code: 201,
                message: "Tạo Item từ ListTask thành công",
                data: savedItem,
            };
        } catch (error) {
            console.error("Lỗi khi chuyển ListTask thành Item:", error);
            throw { code: 500, message: "Server error!", data: null };
        }
    }
}

export default ListTaskService; 