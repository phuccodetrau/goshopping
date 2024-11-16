import { Router } from 'express';
import UserController from '../controller/user.controller.js'; 
import authMiddleware from '../middleware/auth.js';
import jwt from 'jsonwebtoken';

const router = Router();

router.post("/register", UserController.register);
router.post("/login", UserController.login);
router.get('/get-user-name-by-email', authMiddleware, UserController.getUserNameByEmail);
router.put('/update-user', authMiddleware, UserController.updateUser);
export default router;
