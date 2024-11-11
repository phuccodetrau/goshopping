import { Router } from 'express';
import UserController from '../controller/user.controller.js'; 

const router = Router();

router.post("/register", UserController.register);
router.post("/login", UserController.login);
router.get("/get-user-name-by-email", UserController.getUserNameByEmail);

export default router;
