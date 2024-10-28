import { Router } from "express";
import unit from '../controller/unit.controller.js'
const router=Router()
router.post("/admin/unit",unit.createUnit);
router.get("/admin/unit/:groupId",unit.getAllUnit);
router.put("/admin/unit",unit.updateUnit);
router.delete('/admin/unit', unit.deleteUnit);
export default router;
