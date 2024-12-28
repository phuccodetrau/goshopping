import ListTaskService from "../services/listtask.service.js";
import { ListTask, Group } from "../models/schema.js";
import mongoose from 'mongoose';

const createListTask = async (req, res) => {
    try {
        const { name, memberEmail, note, startDate, endDate, foodName, amount, unitName, state, group } = req.body;
        console.log("Received group:", group);
        
        // Gọi service để tạo task và gửi thông báo
        const result = await ListTaskService.createListTask(
            name, 
            memberEmail, 
            note, 
            startDate, 
            endDate, 
            foodName, 
            amount, 
            unitName, 
            state, 
            group
        );
        
        return res.status(result.code === 700 ? 201 : 400).json(result);
    } catch (error) {
        console.error('Error in createListTask controller:', error);
        return res.status(500).json({
            code: 500,
            message: "Server error",
            error: error.message
        });
    }
};

// ... rest of the code ... 