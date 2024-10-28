import UnitService from "../services/unit.service.js";

const createUnit = async(req,res,next)=>{
    try{
        console.log(req.body)
        const {unitName,groupId}=req.body;
        const unit=await UnitService.createUnit(unitName,groupId);
        return res.json({status:true,success:unit})
    }catch(err){
        return res.status(500).send({message:err});
    }
}
const getAllUnit=async(req,res,next)=>{
    try {
        const {groupId}=req.params;
    const units=await UnitService.getAllUnit(groupId);
    return res.json({status:true,success:units});
    } catch (error) {
        return res.status(500).send({message:error});
    }
}
const updateUnit=async(req,res,next)=>{
    try {
        const {oldName,newName}=req.body;
        const unit=await UnitService.editUnit(oldName,newName);
        return res.json({status:true,success:unit});
    } catch (error) {
        return res.status(500).send({message:error});
    }
}
const deleteUnit= async (req, res,next) => {
    try {
        const { name } = req.body;

        // Validate input
        if (!name) {
            return res.status(400).json({ message: 'Category name is required' });
        }

       
        const result = await UnitService.deleteUnit(name);

        if (result.deletedCount === 0) {
            return res.status(404).json({ message: 'Unit not found' });
        }

        return res.status(200).json({ status: true, message: 'Unit deleted successfully' });
    } catch (err) {
        return res.status(500).json({ message: err.message });
    }
};

export default {createUnit,getAllUnit,updateUnit,deleteUnit};