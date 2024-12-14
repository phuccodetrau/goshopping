import express from "express";
import ToDoRoute from "./routes/todo.router.js";
import FoodRoute from "./routes/food.router.js";
import RecipeRoute from "./routes/recipe.router.js";
import ItemRoute from "./routes/item.router.js";
import MealPlanRoute from "./routes/mealplan.router.js";
import CategoryRoute from "./routes/category.router.js"
import UnitRoute from './routes/unit.router.js'
import dotenv from 'dotenv';
import AuthRoute from './routes/auth.router.js'
import GroupRouter from './routes/group.router.js';
import ListTaskRouter from './routes/listtask.router.js';
import notificationRouter from './routes/notification.router.js';
import CronService from './services/cron.service.js';

dotenv.config();
const app = express();
app.use(express.urlencoded({ extended: true }));
app.use(express.json());

app.use("/todo", ToDoRoute);
app.use("/food", FoodRoute);
app.use("/recipe", RecipeRoute);
app.use("/item", ItemRoute);
app.use("/meal", MealPlanRoute);
app.use("/category",CategoryRoute);
app.use("/unit",UnitRoute);
app.use("/auth", AuthRoute);
app.use('/groups', GroupRouter);
app.use("/listtask", ListTaskRouter);
app.use('/api', notificationRouter);

// Initialize cron jobs
CronService.initExpirationCheck();

export default app;
