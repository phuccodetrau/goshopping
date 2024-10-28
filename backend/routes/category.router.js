import { Router } from "express";
import category from '../controller/category.controller.js'
const router=Router()
router.post("/admin/category",category.createCategory);
router.get("/admin/category/:groupId",category.getAllCategory);
router.put("/admin/category",category.updateCategory);
router.delete('/admin/category', category.deleteCategory);
export default router;
