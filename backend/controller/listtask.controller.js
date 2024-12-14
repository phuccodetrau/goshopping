import ListTaskService from "../services/listtask.service.js";
import { ListTask } from "../models/schema.js";

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
    
    // Tạo ngày đầu và cuối tháng
    const startDate = new Date(year, month - 1, 1); // month - 1 vì tháng trong JS bắt đầu từ 0
    const endDate = new Date(year, month, 0); // ngày 0 của tháng tiếp theo = ngày cuối tháng hiện tại
    
    const stats = await ListTask.aggregate([
      {
        $match: {
          group: groupId,
          startDate: { 
            $gte: startDate,
            $lte: endDate
          }
        }
      },
      {
        $group: {
          _id: "$foodName",
          totalAmount: { $sum: "$amount" },
          unitName: { $first: "$unitName" },
          purchaseCount: { $sum: 1 },
          totalCost: { $sum: { $multiply: ["$amount", "$price"] } } // Nếu có trường price
        }
      },
      {
        $sort: { totalAmount: -1 } // Sắp xếp giảm dần theo số lượng
      }
    ]);

    res.status(200).json({
      code: 700,
      message: "Success",
      data: {
        month: month,
        year: year,
        stats: stats.map(item => ({
          foodName: item._id,
          totalAmount: item.totalAmount,
          unitName: item.unitName,
          purchaseCount: item.purchaseCount,
          totalCost: item.totalCost || 0
        }))
      }
    });
  } catch (error) {
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