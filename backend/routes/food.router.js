import { Router } from 'express';
import foodController from '../controller/food.controller.js';
import authMiddleware from '../middleware/auth.js';

const router = Router();

router.post("/createFood", foodController.createFood);
router.post('/getAllFood', authMiddleware, foodController.getAllFood);
router.get('/getUnavailableFoods/:groupId', foodController.getUnavailableFoods);
router.post("/deleteFood", foodController.deleteFood);
router.post("/updateFood", foodController.updateFood);
router.post("/getFoodImageByName", foodController.getFoodImageByName);
router.post("/getFoodsByCategory", foodController.getFoodsByCategory);

export default router;