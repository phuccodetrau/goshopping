import GroupService from '../services/group.service.js';

const createGroup = async (req, res) => {
    try {
        const { name, listUser } = req.body;
        const result = await GroupService.createGroup(name, listUser);
        console.log("Create Group Payload:", req.body);

        return res.status(result.code === 700 ? 201 : 400).json(result);
    } catch (error) {
        return res.status(500).json(error);
    }
};

const addMembers = async (req, res) => {
    try {
        const { groupId, members } = req.body;
        const result = await GroupService.addMembers(groupId, members);
        console.log("Add Members Payload:", req.body);
        return res.status(result.code === 702 ? 200 : 404).json(result);
    } catch (error) {
        return res.status(500).json(error);
    }
};

const getGroupsByMemberEmail = async (req, res) => {
    try {
        const { email } = req.query;
        console.log("Received email:", email); // Kiểm tra xem email có nhận đúng không
        const result = await GroupService.getGroupsByMemberEmail(email);
        return res.status(result.code === 700 ? 200 : 404).json(result);
    } catch (error) {
        return res.status(500).json(error);
    }
};

const getAdminsByGroupId = async (req, res) => {
    try {
        const { groupId } = req.params;
        const result = await GroupService.getAdminsByGroupId(groupId);
        return res.status(result.code === 700 ? 200 : 404).json(result);
    } catch (error) {
        return res.status(500).json(error);
    }
};
const leaveGroup = async (req, res) => {
    try {
        const { groupId } = req.body;
        const userEmail = req.user.email;  // Lấy email từ token auth

        if (!groupId) {
            return res.status(400).json({ 
                code: 401, 
                message: "Thiếu groupId", 
                data: "" 
            });
        }

        // Kiểm tra xem người dùng có phải là admin cuối cùng không
        const group = await Group.findById(groupId);
        if (!group) {
            return res.status(404).json({
                code: 404,
                message: "Không tìm thấy nhóm",
                data: ""
            });
        }

        const admins = group.listUser.filter(user => user.role === 'admin');
        if (admins.length === 1 && admins[0].email === userEmail) {
            return res.status(400).json({
                code: 402,
                message: "Bạn là admin duy nhất của nhóm. Vui lòng chỉ định admin mới hoặc xóa nhóm",
                data: ""
            });
        }

        const result = await GroupService.leaveGroup(groupId, userEmail);
        return res.status(result.code === 700 ? 200 : 400).json(result);
    } catch (error) {
        console.error("Error in leaveGroup:", error);
        return res.status(500).json({ 
            code: 500, 
            message: "Lỗi server", 
            data: "" 
        });
    }
};





const getUsersByGroupName = async (req, res) => {
    try {
        const { groupName } = req.query; // Get groupName from query parameters
        console.log("Received group name:", groupName); // Debugging log
        const result = await GroupService.getUsersByGroupName(groupName);
        return res.status(result.code === 700 ? 200 : 404).json(result);
    } catch (error) {
        return res.status(500).json(error);
    }
};

const getUsersByGroupId = async (req, res) => {
    try {
        const { groupId } = req.params; // Get groupName from query parameters
        console.log("Received group name:", groupId); // Debugging log
        const result = await GroupService.getUsersByGroupId(groupId);
        return res.status(result.code === 700 ? 200 : 404).json(result);
    } catch (error) {
        return res.status(500).json(error);
    }
};






const deleteGroup = async (req, res) => {
    try {
        const { groupId } = req.body;
        const userEmail = req.user.email;

        console.log("Delete group request:", { groupId, userEmail }); // Debug log

        if (!groupId) {
            return res.status(400).json({ 
                code: 401, 
                message: "Thiếu groupId", 
                data: "" 
            });
        }

        const result = await GroupService.deleteGroup(groupId, userEmail);
        console.log("Delete group result:", result); // Debug log
        
        if (result.code === 403) {
            return res.status(403).json(result);
        }
        
        return res.status(result.code === 700 ? 200 : 400).json(result);
    } catch (error) {
        console.error("Error in deleteGroup:", error);
        return res.status(500).json({ 
            code: 500, 
            message: "Lỗi server", 
            data: "" 
        });
    }
};

const removeMember = async (req, res) => {
    try {
        const { groupName, email } = req.body;
        const result = await GroupService.removeMember(groupName, email);
        return res.status(result.code === 700 ? 200 : 404).json(result);
    } catch (error) {
        return res.status(500).json(error);
    }
};


const addItemToRefrigerator = async (req, res) => {
    try{
        const {groupId, item} = req.body;
        const result = await GroupService.addItemToRefrigerator(groupId, item);
        return res.status(result.code === 700 ? 200 : 404).json(result);
    }catch(error){
        return res.status(500).json(error);
    }
}

const getAvailableItems = async (req, res) => {
    try{
        const {groupId} = req.params;
        const result = await GroupService.getAvailableItems(groupId);
        return res.status(result.code === 700 ? 200 : 404).json(result);
    }catch(error){
        return res.status(500).json(error);
    }
}

const searchItemsInRefrigerator = async (req, res) => {
    try{
        const {groupId, keyword} = req.body;
        const result = await GroupService.searchItemsInRefrigerator(groupId, keyword);
        return res.status(result.code === 700 ? 200 : 404).json(result);
    }catch(error){
        return res.status(500).json(error);
    }
}

export default { createGroup, addMembers, getGroupsByMemberEmail, getAdminsByGroupId, getUsersByGroupId, deleteGroup, removeMember, leaveGroup, getUsersByGroupName, addItemToRefrigerator, getAvailableItems, searchItemsInRefrigerator}; 