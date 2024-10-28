import express from "express";
import bodyParser from "body-parser";
import UserRoute from "./routes/user.routes.js";
import ToDoRoute from "./routes/todo.router.js";
import FoodRoute from "./routes/food.router.js";
import RecipeRoute from "./routes/recipe.router.js";
import ItemRoute from "./routes/item.router.js";
import MealPlanRoute from "./routes/mealplan.router.js";
import CategoryRoute from "./routes/category.router.js"
import UnitRoute from './routes/unit.router.js'
import dotenv from 'dotenv';
import AuthRoute from './routes/auth.router.js'
dotenv.config();
const app = express();
app.use(express.urlencoded({ extended: true }));
app.use(bodyParser.json());

app.use("/", UserRoute);
app.use("/", ToDoRoute);
app.use("/", FoodRoute);
app.use("/", RecipeRoute);
app.use("/", ItemRoute);
app.use("/", MealPlanRoute);
app.use("/",CategoryRoute);
app.use("/",UnitRoute);
app.use("/",AuthRoute);
export default app;
