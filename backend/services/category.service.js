import { Category } from "../models/schema.js";
class CategoryService{
    static async createCategory(categoryName,groupId){
        try {
            const createCategory = new Category({name:categoryName,group: groupId });
            return await createCategory.save();
        } catch (error) {
            return error;
        }
    }
    static async getAllCategory(groupId){
        try {
            const  categories = await Category.find({group:groupId});
            return categories;

        } catch (err) {
            return err;
        }
    }
    static async editCategory(oldName,newName){
        try {
            const category=await Category.updateOne({name:oldName},{name:newName});
            return category;
        } catch (error) {
            return error;
    }}
    static async deleteCategory(name) {
        try {
            const result = await Category.deleteOne({ name }); 
            return result
        } catch (error) {
            throw new Error(`Error deleting category: ${error.message}`);
        }
    }
}

export default CategoryService;