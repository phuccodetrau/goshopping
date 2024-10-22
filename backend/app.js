import express from "express";
import bodyParser from "body-parser";
import UserRoute from "./routes/user.routes.js";
import ToDoRoute from "./routes/todo.router.js";
import FoodRoute from "./routes/food.router.js"

const app = express();

app.use(bodyParser.json());

app.use("/", UserRoute);
app.use("/", ToDoRoute);
app.use("/", FoodRoute);

export default app;
