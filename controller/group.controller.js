import { Group } from '../models/schema.js';
import GroupService from '../services/group.service.js';
import FoodService from '../services/food.service.js';
const createGroup = async (req, res) => {
    try {
        const { name, listUser, avatar } = req.body;
        const result = await GroupService.createGroup(name, listUser, avatar);
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

const updateGroupImage = async (req, res) => {
    try {
        const { groupId, avatar } = req.body;
        const result = await GroupService.updateGroupImage(groupId, avatar);
        console.log("Add Avatar Payload:", req.body);
        return res.status(result.code === 700 ? 200 : 404).json(result);
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
        const { groupId } = req.params;
        const userEmail = req.user.email;

        console.log("Leave group request:", { groupId, userEmail });

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
        const isUserAdmin = admins.some(admin => admin.email === userEmail);
        
        if (admins.length === 1 && isUserAdmin) {
            return res.status(400).json({
                code: 402,
                message: "Bạn là admin duy nhất của nhóm. Vui lòng chỉ định admin mới hoặc xóa nhóm",
                data: ""
            });
        }

        const result = await GroupService.leaveGroup(groupId, userEmail);
        console.log("Leave group result:", result);
        
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
        const { groupId, email } = req.body;
        
        // Kiểm tra dữ liệu đầu vào
        if (!groupId || !email) {
            return res.status(400).json({
                code: 401,
                message: "Thiếu thông tin groupId hoặc email",
                data: ""
            });
        }

        // Kiểm tra xem người gửi request có phải là admin không
        const group = await Group.findById(groupId);
        if (!group) {
            return res.status(404).json({
                code: 404,
                message: "Không tìm thấy nhóm",
                data: ""
            });
        }

        const requestUser = group.listUser.find(user => 
            user.email === req.user.email && user.role === 'admin'
        );

        if (!requestUser) {
            return res.status(403).json({
                code: 403,
                message: "Bạn không có quyền xóa thành viên",
                data: ""
            });
        }

        // Kiểm tra không cho phép xóa admin cuối cùng
        const admins = group.listUser.filter(user => user.role === 'admin');
        if (admins.length === 1 && email === admins[0].email) {
            return res.status(400).json({
                code: 400,
                message: "Không thể xóa admin cuối cùng của nhóm",
                data: ""
            });
        }

        const result = await GroupService.removeMember(groupId, email);
        return res.status(result.code === 700 ? 200 : 400).json(result);
    } catch (error) {
        console.error("Error in removeMember:", error);
        return res.status(500).json({
            code: 500,
            message: "Lỗi server",
            data: ""
        });
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

const filterItemsWithPagination = async (req, res) => {
    try{
        const {groupId, keyword, page, limit} = req.body;
        const result = await GroupService.filterItemsWithPagination(groupId, keyword, page, limit);
        const itemsWithImage = await Promise.all(
            result.data.map(async (item) => {
                const imageResult = await FoodService.getFoodImageByName(groupId, item.foodName);
                const image = imageResult.code === 700 ? imageResult.data : "";
                
                // Bổ sung trường totalAmount vào food
                return {
                    ...item.toObject(), // Chuyển mongoose document thành object
                    image
                };
            })
        );
        return res.status(200).json({
            code: 700,
            message: "Lấy danh sách item thành công",
            data: itemsWithImage
        });
    }catch(error){
        return res.status(500).json(error);
    }
}

const getEmailsByGroupId = async (req, res) => {
    try {
        const { groupId } = req.params;
        const result = await GroupService.getEmailsByGroupId(groupId);
        return res.status(result.code === 700 ? 200 : 404).json(result);
    } catch (error) {
        return res.status(500).json(error);
    }
};

export default { createGroup, addMembers, getGroupsByMemberEmail, getAdminsByGroupId, getUsersByGroupId, deleteGroup, removeMember, leaveGroup, getUsersByGroupName, addItemToRefrigerator, filterItemsWithPagination, getEmailsByGroupId, updateGroupImage }; 