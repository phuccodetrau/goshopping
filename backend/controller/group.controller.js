import GroupService from '../services/group.service.js';
import FoodService from '../services/food.service.js';
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
        const { groupId } = req.query; // Nhận groupId từ query
        console.log("Received group ID:", groupId); // Debug
        const result = await GroupService.getAdminsByGroupId(groupId);
        return res.status(result.code === 700 ? 200 : 404).json(result);
    } catch (error) {
        return res.status(500).json(error);
    }
};
const leaveGroup = async (req, res) => {
    try {
        // In ra request body để xem có groupId hay không
        console.log("Request body:", req.body);

        const { groupId } = req.body;  // Lấy groupId từ body
        const userEmail = req.user.email;  // Lấy email từ token

        console.log("User email:", userEmail, "Leave Group ID:", groupId);  // Kiểm tra giá trị

        if (!groupId) {
            return res.status(400).json({ message: "groupId is required" });
        }

        const result = await GroupService.leaveGroup(groupId, userEmail);
        return res.status(result.code === 700 ? 200 : 404).json(result);
    } catch (error) {
        console.error("Error:", error);  // In ra lỗi nếu có
        return res.status(500).json(error);
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
        const { groupName } = req.body;
        const result = await GroupService.deleteGroup(groupName);
        return res.status(result.code === 700 ? 200 : 404).json(result);
    } catch (error) {
        return res.status(500).json(error);
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


export default { createGroup, addMembers, getGroupsByMemberEmail, getAdminsByGroupId, getUsersByGroupId, deleteGroup, removeMember, leaveGroup, getUsersByGroupName, addItemToRefrigerator, filterItemsWithPagination}; 