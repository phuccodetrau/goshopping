import GroupService from '../services/group.service.js';

const createGroup = async (req, res) => {
    try {
        const { name, listUser } = req.body;
        const result = await GroupService.createGroup(name, listUser);
        return res.status(result.code === 700 ? 201 : 400).json(result);
    } catch (error) {
        return res.status(500).json(error);
    }
};

const deleteGroup = async (req, res) => {
    try {
        const { groupId } = req.params;
        const result = await GroupService.deleteGroup(groupId);
        return res.status(result.code === 701 ? 200 : 404).json(result);
    } catch (error) {
        return res.status(500).json(error);
    }
};

const addMember = async (req, res) => {
    try {
        const { groupId, member } = req.body;
        const result = await GroupService.addMember(groupId, member);
        return res.status(result.code === 702 ? 200 : 404).json(result);
    } catch (error) {
        return res.status(500).json(error);
    }
};

const removeMember = async (req, res) => {
    try {
        const { groupId, email } = req.body;
        const result = await GroupService.removeMember(groupId, email);
        return res.status(result.code === 703 ? 200 : 404).json(result);
    } catch (error) {
        return res.status(500).json(error);
    }
};

export default { createGroup, deleteGroup, addMember, removeMember }; 