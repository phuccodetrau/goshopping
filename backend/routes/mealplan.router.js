import { Router } from 'express';
import mealplanController from '../controller/mealplan.controller.js';
import authMiddleware from '../middleware/auth.js';

const router = Router();

router.post("/createMealPlan", authMiddleware, mealplanController.createMealPlan);
router.post('/getMealPlanByDate', authMiddleware, mealplanController.getMealPlanByDate);
router.post("/deleteMealPlan", authMiddleware, mealplanController.deleteMealPlan);
router.post("/updateMealPlan", authMiddleware, mealplanController.updateMealPlan);

export default router;
