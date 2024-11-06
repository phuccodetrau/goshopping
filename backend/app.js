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
import FoodRoute from "./routes/food.router.js";
import listTaskRouter from './routes/listTask.router.js';
import groupRouter from './routes/group.router.js';


const app = express();
app.use(express.urlencoded({ extended: true }));
app.use(bodyParser.json());

app.use("/user", UserRoute);
app.use("/todo", ToDoRoute);
app.use("/food", FoodRoute);
app.use("/recipe", RecipeRoute);
app.use("/item", ItemRoute);
app.use("/meal", MealPlanRoute);
app.use("/category",CategoryRoute);
app.use("/unit",UnitRoute);
app.use("/auth",AuthRoute);
app.use('/listTask', listTaskRouter);
app.use('/group', groupRouter);

export default app;
