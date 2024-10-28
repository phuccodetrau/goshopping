import CategoryService from "../services/category.service.js";

const createCategory = async(req,res,next)=>{
    try{
        console.log(req.body)
        const {categoryName,groupId}=req.body;
        const category=await CategoryService.createCategory(categoryName,groupId);
        return res.json({status:true,success:category})
    }catch(err){
        return res.status(500).send({message:err});
    }
}
const getAllCategory=async(req,res,next)=>{
    try {
        const {groupId}=req.params;
    const categories=await CategoryService.getAllCategory(groupId);
    return res.json({status:true,success:categories});
    } catch (error) {
        return res.status(500).send({message:error});
    }
}
const updateCategory=async(req,res,next)=>{
    try {
        const {oldName,newName}=req.body;
        const category=await CategoryService.editCategory(oldName,newName);
        return res.json({status:true,success:category});
    } catch (error) {
        return res.status(500).send({message:error});
    }
}
const deleteCategory = async (req, res,next) => {
    try {
        const { name } = req.body;

        // Validate input
        if (!name) {
            return res.status(400).json({ message: 'Category name is required' });
        }

       
        const result = await CategoryService.deleteCategory(name);

        if (result.deletedCount === 0) {
            return res.status(404).json({ message: 'Category not found' });
        }

        return res.status(200).json({ status: true, message: 'Category deleted successfully' });
    } catch (err) {
        return res.status(500).json({ message: err.message });
    }
};

export default {createCategory,getAllCategory,updateCategory,deleteCategory};