import { Router } from "express";
import adminController from '../controller/admin.controller.js'
const router=Router();
router.get("/get_all_user",adminController.getAllUser);
router.get("/get_all_group",adminController.getAllGroup);
router.post("/get_one_group",adminController.getOneGroup);
router.post("/login",adminController.login);
router.post("/register",adminController.register);
router.post("/get_one_user",adminController.getOneUser)
router.get("/get_admin_info",adminController.getAdminInfo)
export default router