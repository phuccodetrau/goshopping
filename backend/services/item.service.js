import { Item } from "../models/schema.js";

class ItemService {
    static async createItem(foodName, expireDate, amount, note, group) {
        try {
            const newItem = new Item({ foodName, expireDate, amount, note, group });
            return await newItem.save();
        } catch (error) {
            console.error("Lỗi khi tạo item:", error);
            throw error;
        }
    }

    static async updateItem(foodName, group, newData) {
        try {
            const updatedItem = await Item.findOneAndUpdate(
                { foodName: foodName, group: group },
                { $set: newData },
                { new: true }
            );

            return updatedItem;
        } catch (error) {
            console.error('Error updating food:', error);
            throw error;
        }
    }

    static async deleteItem(foodName, group) {
        const deleted = await Item.findOneAndDelete({ foodName: foodName, group: group });
        return deleted;
    }

    static async getAllItem(group) {
        const items = await Item.find({ group: group });
        return items;
    }

    static async getSpecificItem(foodName, group) {
        const item = await Item.findOne({ foodName: foodName, group: group });
        return item;
    }
}

export default ItemService;
