import { Router } from "express";
import unit from '../controller/unit.controller.js'
import authMiddleware from '../middleware/auth.js';
const router=Router()
router.post("/admin/unit", authMiddleware, unit.createUnit);
router.get("/admin/unit/:groupId", authMiddleware, unit.getAllUnit);
router.put("/admin/unit", authMiddleware, unit.updateUnit);
router.delete('/admin/unit', authMiddleware, unit.deleteUnit);
export default router;
