import { Router } from 'express';
import mealplanController from '../controller/mealplan.controller.js';

const router = Router();

router.post("/createMealPlan", mealplanController.createMealPlan);
router.post('/getMealPlanByDate', mealplanController.getMealPlanByDate);
router.post("/deleteMealPlan", mealplanController.deleteMealPlan);
router.post("/updateMealPlan", mealplanController.updateMealPlan);

export default router;
