import ItemService from "../services/item.service.js";
import { Group } from '../models/schema.js';

const createItem = async (req, res, next) => {
    try {
        const { foodName, expireDate, amount, unitName, note, group } = req.body;
        let itemData = await ItemService.createItem(foodName, expireDate, amount, unitName, note, group);
        return res.json(itemData);
    } catch (error) {
        return res.json({code: 101, message: "Server error!", data: ""})
    }
}

const getAllItem = async (req, res, next) => {
    try {
        const { group } = req.body;
        const result = await ItemService.getAllItem(group);
        res.json(result);
    } catch (error) {
        return res.json({code: 101, message: "Server error!", data: ""})
    }
}

const getSpecificItem = async (req, res, next) => {
    try {
        const { foodName, group } = req.body;
        const result = await ItemService.getSpecificItem(foodName, group);
        res.json(result);
    } catch (error) {
        return res.json({code: 101, message: "Server error!", data: ""})
    }
};

const deleteItem = async (req, res, next) => {
    try {
        const { id } = req.body;
        const result = await ItemService.deleteItem(id);
        res.json(result);
    } catch (error) {
        return res.json({code: 101, message: "Server error!", data: ""})
    }
}


const updateItem = async (req, res, next) => {
    try {
        const { id, newData } = req.body;
        let updatedData = await ItemService.updateItem(id, newData);
        return res.json(updatedData);
    } catch (error) {
        return res.json({code: 101, message: "Server error!", data: ""})
    }
}

const createGroup = async (req, res) => {
    try {
        const { name, listUser } = req.body;

        if (!name || !listUser || listUser.length === 0) {
            return res.status(400).json({ code: 701, message: "Vui lòng cung cấp đầy đủ thông tin", data: "" });
        }

        const newGroup = new Group({
            name,
            listUser,
            refrigerator: []
        });

        const savedGroup = await newGroup.save();

        return res.status(201).json({
            code: 700,
            message: "Tạo nhóm thành công",
            data: savedGroup
        });
    } catch (error) {
        console.error('Lỗi khi tạo nhóm:', error);
        return res.status(500).json({ code: 101, message: "Server error!", data: "" });
    }
};

const deleteGroup = async (req, res) => {
    try {
        const { groupId } = req.params;

        const deletedGroup = await Group.findByIdAndDelete(groupId);

        if (!deletedGroup) {
            return res.status(404).json({ code: 702, message: "Không tìm thấy nhóm để xóa", data: "" });
        }

        return res.status(200).json({
            code: 701,
            message: "Xóa nhóm thành công",
            data: deletedGroup
        });
    } catch (error) {
        console.error('Lỗi khi xóa nhóm:', error);
        return res.status(500).json({ code: 101, message: "Server error!", data: "" });
    }
};
const addMember = async (req, res) => {
    try {
        const { groupId, member } = req.body;

        const updatedGroup = await Group.findByIdAndUpdate(
            groupId,
            { $push: { listUser: member } },
            { new: true }
        );

        if (!updatedGroup) {
            return res.status(404).json({ code: 703, message: "Không tìm thấy nhóm để thêm thành viên", data: "" });
        }

        return res.status(200).json({
            code: 702,
            message: "Thêm thành viên thành công",
            data: updatedGroup
        });
    } catch (error) {
        console.error('Lỗi khi thêm thành viên:', error);
        return res.status(500).json({ code: 101, message: "Server error!", data: "" });
    }
};

const removeMember = async (req, res) => {
    try {
        const { groupId, email } = req.body;

        const updatedGroup = await Group.findByIdAndUpdate(
            groupId,
            { $pull: { listUser: { email: email } } },
            { new: true }
        );

        if (!updatedGroup) {
            return res.status(404).json({ code: 704, message: "Không tìm thấy nhóm để xóa thành viên", data: "" });
        }

        return res.status(200).json({
            code: 703,
            message: "Xóa thành viên thành công",
            data: updatedGroup
        });
    } catch (error) {
        console.error('Lỗi khi xóa thành viên:', error);
        return res.status(500).json({ code: 101, message: "Server error!", data: "" });
    }
};

export default { createItem, getAllItem, getSpecificItem, deleteItem, updateItem, createGroup, deleteGroup, addMember, removeMember };