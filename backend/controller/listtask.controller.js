import ListTaskService from "../services/listtask.service.js";
import { ListTask } from "../models/schema.js";
import mongoose from 'mongoose';

const createListTask = async (req, res) => {
    try {
        const { name, memberEmail, note, startDate, endDate, foodName, amount, unitName, state, group } = req.body;
        const result = await ListTaskService.createListTask(name, memberEmail, note, startDate, endDate, foodName, amount, unitName, state, group);
        return res.status(result.code === 700 ? 201 : 400).json(result);
    } catch (error) {
        return res.status(500).json(error);
    }
};

const getTaskStats = async (req, res) => {
  try {
    const { groupId, month, year } = req.body;
    
    const startDate = new Date(year, month - 1, 1);
    const endDate = new Date(year, month, 0);
    
    const groupObjectId = new mongoose.Types.ObjectId(groupId);
    
    const stats = await ListTask.aggregate([
      {
        $match: {
          group: groupObjectId,
          startDate: { 
            $gte: startDate,
            $lte: endDate
          },
          state: true
        }
      },
      {
        $group: {
          _id: {
            foodName: "$foodName",
            unitName: "$unitName"
          },
          totalAmount: { $sum: "$amount" },
          purchaseCount: { $sum: 1 },
          purchases: {
            $push: {
              memberEmail: "$memberEmail",
              amount: "$amount",
              date: "$startDate",
              note: "$note"
            }
          }
        }
      },
      {
        $project: {
          _id: 0,
          foodName: "$_id.foodName",
          unitName: "$_id.unitName",
          totalAmount: 1,
          purchaseCount: 1,
          purchases: 1
        }
      },
      {
        $sort: { totalAmount: -1 }
      }
    ]);

    res.status(200).json({
      code: 700,
      message: "Success",
      data: {
        month,
        year,
        stats
      }
    });
  } catch (error) {
    console.error('Error in getTaskStats:', error);
    res.status(500).json({
      code: 500,
      message: error.message
    });
  }
};

const getTaskStatsByFood = async (req, res) => {
    try {
        const { groupId, foodName } = req.body;
        res.status(200).json({
            code: 700,
            message: "Success",
            data: []
        });
    } catch (error) {
        res.status(500).json({
            code: 500,
            message: error.message
        });
    }
};

const getTaskStatsByDate = async (req, res) => {
    try {
        const { groupId, date } = req.body;
        res.status(200).json({
            code: 700,
            message: "Success",
            data: []
        });
    } catch (error) {
        res.status(500).json({
            code: 500,
            message: error.message
        });
    }
};

export default {
    createListTask,
    getTaskStats,
    getTaskStatsByFood,
    getTaskStatsByDate
};