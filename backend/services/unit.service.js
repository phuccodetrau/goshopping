import { Unit} from "../models/schema.js";
class UnitService{
    static async createUnit(unitName,groupId){
        try {
            const createUnit = new Unit({name:unitName,group: groupId });
            return await createUnit.save();
        } catch (error) {
            return error;
        }
    }
    static async getAllUnit(groupId){
        try {
            const  units = await Unit.find({group:groupId});
            return units;

        } catch (err) {
            return err;
        }
    }
    static async editUnit(oldName,newName){
        try {
            const unit=await Unit.updateOne({name:oldName},{name:newName});
            return unit;
        } catch (error) {
            return error;
    }}
    static async deleteUnit(name) {
        try {
            const result = await Unit.deleteOne({ name }); 
            return result
        } catch (error) {
            throw new Error(`Error deleting category: ${error.message}`);
        }
    }
}

export default UnitService;