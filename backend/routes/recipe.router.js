import { Router } from 'express';
import recipeController from '../controller/recipe.controller.js';
import authMiddleware from '../middleware/auth.js';

const router = Router();

router.post("/createRecipe", authMiddleware, recipeController.createRecipe);
router.post('/getRecipeByFood', recipeController.getRecipeByFood);
router.post("/deleteRecipe", recipeController.deleteRecipe);
router.post("/updateRecipe", recipeController.updateRecipe);
router.post("/getAllRecipe",authMiddleware, recipeController.getAllRecipe);

export default router;