import express from "express";
import bodyParser from "body-parser";
import UserRoute from "./routes/user.routes.js";
import ToDoRoute from "./routes/todo.router.js";
import FoodRoute from "./routes/food.router.js";
import RecipeRoute from "./routes/recipe.router.js";
import ItemRoute from "./routes/item.router.js";
import MealPlanRoute from "./routes/mealplan.router.js";

const app = express();

app.use(bodyParser.json());

app.use("/", UserRoute);
app.use("/", ToDoRoute);
app.use("/", FoodRoute);
app.use("/", RecipeRoute);
app.use("/", ItemRoute);
app.use("/", MealPlanRoute);

export default app;
