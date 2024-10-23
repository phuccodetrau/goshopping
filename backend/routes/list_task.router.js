import { Router } from 'express';
import ListTaskController from '../controller/listTask.controller.js';

const router = Router();

router.post("/createListTask", ListTaskController.createListTask);
router.get("/getListTasks", ListTaskController.getListTasks);
router.put("/updateListTask", ListTaskController.updateListTask);
router.delete("/deleteListTask", ListTaskController.deleteListTask);

export default router;