import { Router } from 'express';
import ToDoController from '../controller/todo.controller.js';
import authMiddleware from '../middleware/auth.js';
const router = Router();

router.post("/createToDo", authMiddleware, ToDoController.createToDo);
router.get('/getUserTodoList', authMiddleware, ToDoController.getToDoList);
router.post("/deleteTodo", authMiddleware, ToDoController.deleteToDo);

export default router;
