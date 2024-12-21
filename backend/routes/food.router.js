import { Router } from 'express';
import foodController from '../controller/food.controller.js';
import authMiddleware from '../middleware/auth.js';

const router = Router();

router.post("/createFood", authMiddleware, foodController.createFood);
router.post('/getAllFood', authMiddleware, foodController.getAllFood);
router.get('/getUnavailableFoods/:groupId', authMiddleware, foodController.getUnavailableFoods);
router.post("/deleteFood", authMiddleware, foodController.deleteFood);
router.post("/updateFood", authMiddleware, foodController.updateFood);
router.post("/getFoodImageByName", authMiddleware, foodController.getFoodImageByName);
router.post("/getFoodsByCategory", authMiddleware, foodController.getFoodsByCategory);

export default router;