import GroupService from '../services/group.service.js';

const createGroup = async (req, res, next) => {
    try {
        const { name, listUser } = req.body;
        let groupData = await GroupService.createGroup(name, listUser);
        res.json({ status: true, success: groupData });
    } catch (error) {
        console.log(error, 'err---->');
        next(error);
    }
}

const getGroups = async (req, res, next) => {
    try {
        const { userId } = req.query;
        let groups = await GroupService.getGroups(userId);
        res.json({ status: true, success: groups });
    } catch (error) {
        console.log(error, 'err---->');
        next(error);
    }
}

const updateGroup = async (req, res, next) => {
    try {
        const { id, updateData } = req.body;
        let updatedGroup = await GroupService.updateGroup(id, updateData);
        res.json({ status: true, success: updatedGroup });
    } catch (error) {
        console.log(error, 'err---->');
        next(error);
    }
}

const deleteGroup = async (req, res, next) => {
    try {
        const { id } = req.body;
        let deletedGroup = await GroupService.deleteGroup(id);
        res.json({ status: true, success: deletedGroup });
    } catch (error) {
        console.log(error, 'err---->');
        next(error);
    }
}

const addUserToGroup = async (req, res, next) => {
    try {
        const { groupId, userData } = req.body;
        let updatedGroup = await GroupService.addUserToGroup(groupId, userData);
        res.json({ status: true, success: updatedGroup });
    } catch (error) {
        console.log(error, 'err---->');
        next(error);
    }
}

const removeUserFromGroup = async (req, res, next) => {
    try {
        const { groupId, userEmail } = req.body;
        let updatedGroup = await GroupService.removeUserFromGroup(groupId, userEmail);
        res.json({ status: true, success: updatedGroup });
    } catch (error) {
        console.log(error, 'err---->');
        next(error);
    }
}

export default { createGroup, getGroups, updateGroup, deleteGroup, addUserToGroup, removeUserFromGroup };