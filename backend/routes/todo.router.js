import { Router } from 'express';
import ToDoController from '../controller/todo.controller.js';

const router = Router();

router.post("/createToDo", ToDoController.createToDo);
router.get('/getUserTodoList', ToDoController.getToDoList);
router.post("/deleteTodo", ToDoController.deleteToDo);

export default router;
