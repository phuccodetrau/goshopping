import { Router } from 'express';
import foodController from '../controller/food.controller.js';

const router = Router();

router.post("/createFood", foodController.createFood);
router.post('/getFoodInGroup', foodController.getAllFood);
router.post("/deleteFood", foodController.deleteFood);
router.post("/updateFood", foodController.updateFood);

export default router;
