import { Group } from "../models/schema.js";

class GroupService {
    static async createGroup(name, listUser) {
        const newGroup = new Group({ name, listUser });
        return await newGroup.save();
    }

    static async getGroups(userId) {
        return await Group.find({ "listUser.email": userId });
    }

    static async updateGroup(id, updateData) {
        return await Group.findByIdAndUpdate(id, updateData, { new: true });
    }

    static async deleteGroup(id) {
        return await Group.findByIdAndDelete(id);
    }

    static async addUserToGroup(groupId, userData) {
        return await Group.findByIdAndUpdate(
            groupId,
            { $push: { listUser: userData } },
            { new: true }
        );
    }

    static async removeUserFromGroup(groupId, userEmail) {
        return await Group.findByIdAndUpdate(
            groupId,
            { $pull: { listUser: { email: userEmail } } },
            { new: true }
        );
    }
}

export default GroupService;