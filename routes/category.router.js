import { Router } from "express";
import category from '../controller/category.controller.js'

import authMiddleware from '../middleware/auth.js';
const router = Router()
router.post("/admin/category", authMiddleware, category.createCategory);
router.get("/admin/category/:groupId", authMiddleware, category.getAllCategory);
router.put("/admin/category", authMiddleware, category.updateCategory);
router.delete('/admin/category', authMiddleware, category.deleteCategory);
export default router;

