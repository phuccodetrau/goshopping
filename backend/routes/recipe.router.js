import { Router } from 'express';
import recipeController from '../controller/recipe.controller.js';

const router = Router();

router.post("/createRecipe", recipeController.createRecipe);
router.post('/getRecipeByFood', recipeController.getRecipeByFood);
router.post("/deleteRecipe", recipeController.deleteRecipe);
router.post("/updateRecipe", recipeController.updateRecipe);

export default router;
